#!/usr/bin/env python3
"""
Loop Engine — AI Auto-Fix Pipeline
===================================
Implements a retry loop for OPA / test / scan evaluations across Harness,
Pi, and Research pipelines.  On each FAIL the appropriate AutoFixer rewrites
the offending file, then the evaluator re-runs.  After MAX_ATTEMPTS the
LoopNotifier escalates to a human via a GitHub Issue and PR comment.

Usage
-----
python scripts/loop_engine.py \
    --pipeline  harness|pi|research \
    --max-attempts 3 \
    --auto-fix true

Environment variables (GitHub Actions context)
----------------------------------------------
GITHUB_TOKEN          – required for GitHub Issue / PR comment creation
GITHUB_REPOSITORY     – owner/repo  e.g. arifbazli/AI-Agent-Guardrails-Hub
GITHUB_REF_NAME       – current branch name
PR_NUMBER             – open PR number (optional; used for PR comment)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import textwrap
import urllib.request
import urllib.parse
import urllib.error
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# OPA binary path — resolved once at import time so every subprocess call
# uses the same binary whether running locally or in GitHub Actions.
# ---------------------------------------------------------------------------
OPA_PATH = os.environ.get("OPA_PATH", "/usr/local/bin/opa")

# ---------------------------------------------------------------------------
# Enums / result types
# ---------------------------------------------------------------------------

class LoopResult(str, Enum):
    PASS      = "PASS"
    FAIL      = "FAIL"
    ESCALATED = "ESCALATED"


@dataclass
class Violation:
    rule_id:     str
    severity:    str
    file:        str
    description: str
    line:        int = 0


@dataclass
class EvalResult:
    passed:     bool
    violations: list[Violation] = field(default_factory=list)
    raw_output: str = ""


@dataclass
class FixRecord:
    attempt:     int
    violations:  list[Violation]
    fix_applied: str
    result:      LoopResult

# ---------------------------------------------------------------------------
# Fix-target helpers
# ---------------------------------------------------------------------------

def _unwrap_stage(stage_entry: Any) -> Any:
    """Unwrap a Harness ``{"stage": {...}}`` entry to the flat stage dict.

    Real Harness pipeline YAML nests each stage under a ``stage:`` key,
    e.g. ``stages: [{"stage": {"name": ..., "type": ..., "spec": ...}}]``
    (see docs/policy-guide.md and test-inputs/human-pr-test.yaml). But
    policies/opa/pipeline-guardrails.rego reads stage fields directly off
    each ``input.pipeline.stages[_]`` entry (``stage.type``, ``stage.spec``,
    ``stage.timeout``). Left un-unwrapped, every stage-level rule (PG-001,
    PG-002, PG-003, PG-005, PG-006, PG-007) silently sees no matching field
    and never fires — the pipeline evaluates as compliant regardless of its
    actual contents.
    """
    if isinstance(stage_entry, dict) and isinstance(stage_entry.get("stage"), dict):
        return stage_entry["stage"]
    return stage_entry


def yaml_to_opa_input(pipeline_yaml: dict) -> dict:
    """Convert pipeline YAML to OPA input JSON.

    Wraps the yaml content in the expected input structure for
    ``data.harness.pipeline.guardrails``.  If the document already contains a
    top-level ``pipeline`` key it is used as-is; otherwise the whole
    document is treated as the pipeline body and wrapped accordingly. Each
    stage entry is also unwrapped from Harness's ``stage:`` nesting (see
    :func:`_unwrap_stage`) so stage-level rules see the real fields
    regardless of whether the source YAML uses the wrapped or flat form.
    """
    if isinstance(pipeline_yaml, dict) and "pipeline" in pipeline_yaml:
        doc = pipeline_yaml
    else:
        doc = {"pipeline": pipeline_yaml}

    pipeline = doc.get("pipeline")
    if isinstance(pipeline, dict) and isinstance(pipeline.get("stages"), list):
        pipeline["stages"] = [_unwrap_stage(s) for s in pipeline["stages"]]

    return doc


def get_pr_yaml_files(pr_branch: str = "") -> list[str]:
    """Find all non-policy YAML files changed in this PR branch.

    Returns a list of file paths relative to the repository root.
    Falls back to ``test-inputs/`` YAML files when no PR-changed files are
    found (e.g. running locally or without a PR branch).
    """
    base = f"origin/{pr_branch}" if pr_branch else "origin/main"
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", f"{base}...HEAD"],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except subprocess.TimeoutExpired:
        print(f"[get_pr_yaml_files] git diff timed out against {base} — falling back to test-inputs/", file=sys.stderr)
        result = subprocess.CompletedProcess(args=[], returncode=1, stdout="", stderr="timeout")
    changed = result.stdout.strip().split("\n")

    yaml_files: list[str] = []
    for f in changed:
        if not f:
            continue
        # Never evaluate policy files — only pipeline YAML
        if "policies/" in f:
            continue
        if f.endswith((".yaml", ".yml")) and os.path.exists(f):
            yaml_files.append(f)

    # Fallback: test-inputs/ folder yaml files
    if not yaml_files:
        for root, _dirs, files in os.walk("test-inputs"):
            for fname in files:
                if fname.endswith((".yaml", ".yml")):
                    yaml_files.append(os.path.join(root, fname))

    return yaml_files


def get_pr_changed_files(pr_branch: str = "") -> list[str]:
    """Get list of files changed in this PR branch relative to origin/main.

    Parameters
    ----------
    pr_branch:
        Optional branch name.  When provided the diff is computed against
        ``origin/<pr_branch>``; otherwise ``origin/main`` is used as the base.
    """
    base = f"origin/{pr_branch}" if pr_branch else "origin/main"
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", f"{base}...HEAD"],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except subprocess.TimeoutExpired:
        print(f"[get_pr_changed_files] git diff timed out against {base}", file=sys.stderr)
        return []
    raw = result.stdout.strip()
    if not raw:
        return []
    return raw.split("\n")


def get_fix_target(violation: "Violation", pr_branch: str = "") -> str:
    """
    Find the correct file to fix.
    Never fix .rego policy files.
    Always fix the pipeline YAML that contains the violation.

    Priority order:
    1. If violation.file is already a non-policy YAML, use it directly.
    2. Any .yaml/.yml file in the PR diff that is NOT in policies/ folder.
    3. test-inputs/ folder yaml files.
    4. The specific file path from the violation message (last resort).
    """
    target = violation.file

    # If the target is not a .rego policy file, use it as-is
    if not (target.endswith(".rego") or "policies/" in target):
        return target

    # Never fix policy files — search for the pipeline YAML instead
    changed_files = get_pr_changed_files(pr_branch)
    for f in changed_files:
        if f.endswith((".yaml", ".yml")) and "policies/" not in f:
            return f

    # Fallback: test-inputs/ folder yaml files
    test_input_yamls = sorted(
        list(Path("test-inputs").glob("*.yaml")) + list(Path("test-inputs").glob("*.yml"))
    )
    if test_input_yamls:
        return str(test_input_yamls[0])

    return target


# ---------------------------------------------------------------------------
# LoopLogger
# ---------------------------------------------------------------------------

LOG_PATH = Path("policies/research/loop-log.md")


class LoopLogger:
    """Appends one entry per attempt to policies/research/loop-log.md."""

    @staticmethod
    def log(
        pipeline:    str,
        rule_id:     str,
        attempt:     int,
        violation:   str,
        fix_applied: str,
        result:      LoopResult,
    ) -> None:
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
        entry = (
            f"\n| {now} | {pipeline} | {rule_id} | {attempt} "
            f"| {violation[:80]} | {fix_applied[:80]} | {result.value} |"
        )
        if LOG_PATH.exists():
            with LOG_PATH.open("a") as fh:
                fh.write(entry + "\n")
        else:
            LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
            with LOG_PATH.open("w") as fh:
                fh.write(
                    "# Loop Engine — Auto-Fix History\n\n"
                    "| Date | Pipeline | Rule | Attempt | Violation | Fix Applied | Result |\n"
                    "|---|---|---|---|---|---|---|\n"
                )
                fh.write(entry + "\n")

# ---------------------------------------------------------------------------
# Approved image registry prefixes — single source of truth, mirroring
# policies/opa/pipeline-guardrails.rego's approved_registries. Previously
# _fix_registry() and _fix_pg_003() each hardcoded their own divergent list.
# ---------------------------------------------------------------------------

APPROVED_REGISTRY_PREFIXES = (
    "gcr.io/deloitte-",
    "us-docker.pkg.dev/deloitte-",
    "eu-docker.pkg.dev/deloitte-",
    "index.docker.io/deloitteinternal/",
    "ghcr.io/deloitte-global-cloud-services/",
)

# ---------------------------------------------------------------------------
# HarnessAutoFixer
# ---------------------------------------------------------------------------

class HarnessAutoFixer:
    """Auto-fix logic for Harness OPA violations (PG-001 … PG-009)."""

    def generate_fix(self, violations: list[Violation]) -> str:
        summaries = []
        for v in violations:
            target = get_fix_target(v)
            summaries.append(f"Apply fix for {v.rule_id} in {target}")
        return "; ".join(summaries) if summaries else "no-op"

    def apply_fix(self, violations: list[Violation], pr_branch: str = "") -> None:
        for v in violations:
            # Resolve the correct pipeline YAML target — never fix .rego files
            resolved_target = get_fix_target(v, pr_branch)
            if resolved_target != v.file:
                print(
                    f"[HarnessAutoFixer] Redirecting fix for {v.rule_id} "
                    f"from {v.file!r} → {resolved_target!r}",
                    file=sys.stderr,
                )
                v.file = resolved_target
            method = getattr(self, f"_fix_{v.rule_id.lower().replace('-', '_')}", None)
            if method:
                try:
                    method(v)
                except Exception as exc:  # noqa: BLE001
                    print(f"[HarnessAutoFixer] WARNING: fix for {v.rule_id} raised: {exc}", file=sys.stderr)

    def apply_fixes(self, violations: list[Violation], yaml_file: str) -> None:
        """Apply fixes to the yaml file on disk using YAML-dict manipulation.

        Each fix modifies the file in place so the next OPA evaluation sees the
        change.  This method is the dict-based counterpart to :meth:`apply_fix`
        which uses regex-based text replacement.
        """
        import yaml as _yaml  # noqa: PLC0415
        try:
            with open(yaml_file) as fh:
                content = _yaml.safe_load(fh) or {}
        except Exception as exc:  # noqa: BLE001
            print(f"[HarnessAutoFixer] Cannot load {yaml_file!r}: {exc}", file=sys.stderr)
            return

        modified = False
        for v in violations:
            rule = v.rule_id

            if "APPROVED_REGISTRIES" in rule or "PG-003" in rule:
                content = self._fix_registry(content)
                modified = True

            if "SECRET_KEY_PATTERNS" in rule or "PG-002" in rule:
                content = self._fix_secrets(content)
                modified = True

            if "REQUIRED_TAGS" in rule or "PG-009" in rule:
                content = self._fix_tags(content)
                modified = True

            if "PG-001" in rule:
                content = self._fix_approval(content)
                modified = True

            if "PG-004" in rule:
                content = self._fix_timeout(content)
                modified = True

            if "PG-005" in rule:
                content = self._fix_delegate(content)
                modified = True

            if "PG-007" in rule:
                content = self._fix_rollback(content)
                modified = True

            if "PG-008" in rule:
                content = self._fix_description(content)
                modified = True

        if modified:
            with open(yaml_file, "w") as fh:
                _yaml.dump(content, fh, default_flow_style=False, allow_unicode=True)

    @staticmethod
    def _fix_registry(content: dict) -> dict:
        """Replace unapproved image registry with gcr.io/deloitte-gcs/."""
        approved_prefix = "gcr.io/deloitte-gcs/"
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s     = stage.get("stage", stage)
            steps = s.get("spec", {}).get("execution", {}).get("steps", [])
            for step in steps:
                st    = step.get("step", step)
                spec  = st.get("spec", {})
                image = spec.get("image", "")
                if image and not any(image.startswith(r) for r in APPROVED_REGISTRY_PREFIXES):
                    parts = image.split("/")
                    if len(parts) > 1 and ("." in parts[0] or ":" in parts[0]):
                        image_name = "/".join(parts[1:])
                    else:
                        image_name = image
                    spec["image"] = approved_prefix + image_name
        return content

    @staticmethod
    def _fix_secrets(content: dict) -> dict:
        """Replace plaintext secret values with Harness secret references."""
        secret_key_re = re.compile(
            r"(?i)(password|passwd|pwd|secret|token|api.?key|access.?key)"
        )
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s     = stage.get("stage", stage)
            steps = s.get("spec", {}).get("execution", {}).get("steps", [])
            for step in steps:
                st  = step.get("step", step)
                env = st.get("spec", {}).get("envVariables", {})
                for key in list(env.keys()):
                    if secret_key_re.search(key):
                        val = str(env[key])
                        if not val.startswith("<+secrets"):
                            env[key] = f'<+secrets.getValue("{key.lower()}")>'
        return content

    @staticmethod
    def _fix_tags(content: dict) -> dict:
        """Add required owner and cost-centre tags."""
        pipeline = content.get("pipeline", content)
        if "tags" not in pipeline:
            pipeline["tags"] = {}
        tags = pipeline["tags"]
        if "owner" not in tags:
            tags["owner"] = "platform-team"
        if "cost-centre" not in tags:
            tags["cost-centre"] = "CC-TBD"
        return content

    @staticmethod
    def _fix_description(content: dict) -> dict:
        """Add pipeline description when blank."""
        pipeline = content.get("pipeline", content)
        if not pipeline.get("description"):
            pipeline["description"] = (
                "Auto-fixed by Loop Engine — please update before merge"
            )
        return content

    @staticmethod
    def _fix_timeout(content: dict) -> dict:
        """Add 1h timeout to stages that lack one."""
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s = stage.get("stage", stage)
            if "timeout" not in s:
                s["timeout"] = "1h"
        return content

    @staticmethod
    def _fix_delegate(content: dict) -> dict:
        """Add org-approved delegate selector when delegateSelectors is empty."""
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s          = stage.get("stage", stage)
            spec       = s.get("spec", {})
            infra      = spec.get("infrastructure", {})
            infra_spec = infra.get("spec", {})
            if not infra_spec.get("delegateSelectors"):
                infra_spec["delegateSelectors"] = ["org-approved"]
                infra["spec"]          = infra_spec
                spec["infrastructure"] = infra
                s["spec"]              = spec
        return content

    @staticmethod
    def _fix_approval(content: dict) -> dict:
        """Insert a HarnessApproval step at the front of production stage steps."""
        approval_step = {
            "step": {
                "name": "approval-gate",
                "type": "HarnessApproval",
                "spec": {
                    "approvalMessage": "Approve deployment",
                    "approvers": {
                        "userGroups": ["org._organization_all_users"],
                        "minimumCount": 1,
                    },
                },
            }
        }
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s        = stage.get("stage", stage)
            env_type = s.get("spec", {}).get("environment", {}).get("type", "")
            if env_type.lower() == "production":
                steps        = s.get("spec", {}).get("execution", {}).get("steps", [])
                has_approval = any(
                    step.get("step", step).get("type") == "HarnessApproval"
                    for step in steps
                )
                if not has_approval:
                    steps.insert(0, approval_step)
        return content

    @staticmethod
    def _fix_rollback(content: dict) -> dict:
        """Add HelmRollback rollbackSteps to production stages."""
        stages = content.get("pipeline", content).get("stages", [])
        for stage in stages:
            s        = stage.get("stage", stage)
            env_type = s.get("spec", {}).get("environment", {}).get("type", "")
            if env_type.lower() == "production":
                execution = s.get("spec", {}).get("execution", {})
                if not execution.get("rollbackSteps"):
                    execution["rollbackSteps"] = [{
                        "step": {
                            "name": "rollback",
                            "type": "HelmRollback",
                            "spec": {},
                        }
                    }]
        return content

    # ---- individual fixes (regex / text-based) --------------------------------------------------

    def _fix_pg_001(self, v: Violation) -> None:
        """Insert HarnessApproval step before the first execution step."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()

        # Skip if an approval step is already present
        if re.search(r'type:\s*(HarnessApproval|JiraApproval|ServiceNowApproval)', text):
            return

        approval_block = textwrap.dedent("""\
            - step:
                name: approval-gate
                type: HarnessApproval
                spec: {}
            """)

        # First try to insert before a K8s/Helm/TerraformApply deploy step
        pattern = r"(- step:\n\s+name:.*\n\s+type:\s*(?:K8sRollingDeploy|HelmDeploy|TerraformApply))"
        new_text, n = re.subn(pattern, approval_block + r"\1", text, count=1)
        if n:
            path.write_text(new_text)
            return

        # Fallback: insert approval as the first step in any steps list
        def _insert_approval(match: re.Match) -> str:
            steps_header = match.group(1)  # "steps:\n"
            indent = match.group(2)        # leading whitespace of first "- step:"
            first_step = match.group(3)    # "- step:"
            approval = (
                f"{indent}- step:\n"
                f"{indent}    name: approval-gate\n"
                f"{indent}    type: HarnessApproval\n"
                f"{indent}    spec: {{}}\n"
                f"{indent}"
            )
            return steps_header + approval + first_step

        new_text, n = re.subn(
            r'(steps:\s*\n)(\s*)(- step:)',
            _insert_approval,
            text,
            count=1,
        )
        if n:
            path.write_text(new_text)

    def _fix_pg_002(self, v: Violation) -> None:
        """Replace plaintext secret values with Harness secret references."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()

        # Match keys that contain secret-related words, aligning with OPA
        # is_plaintext_secret() which checks the KEY against secret_key_patterns.
        secret_key_pattern = (
            r"password|passwd|pwd|secret|token|api[_-]?key"
            r"|access[_-]?key|private[_-]?key|credential|auth[_-]?token"
        )

        def _replace_secret(match: re.Match) -> str:
            key   = match.group(1)
            value = match.group(2).strip()
            # Skip values that are already secret references or empty
            if (value.startswith("<+secrets")
                    or value.startswith("<+pipeline.variables")
                    or not value):
                return match.group(0)
            slug = re.sub(r"[^a-zA-Z0-9_-]", "-", key).lower()
            return f'{key}: <+secrets.getValue("auto-migrated-{slug}")>  # AUTO-FIXED by Loop Engine'

        new_text = re.sub(
            rf'(\w*(?:{secret_key_pattern})\w*):\s*([^#\n<][^\n]*)',
            _replace_secret,
            text,
            flags=re.IGNORECASE,
        )
        path.write_text(new_text)

    def _fix_pg_003(self, v: Violation) -> None:
        """Replace unapproved registry prefix with gcr.io/deloitte-gcs/."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()

        def _fix_image(match: re.Match) -> str:
            prefix = match.group(1)   # "image: " or "image:"
            image_ref = match.group(2)  # full image reference
            # Skip images already from an approved registry
            for approved in APPROVED_REGISTRY_PREFIXES:
                if image_ref.startswith(approved):
                    return match.group(0)
            # Strip the unapproved registry host (first path component that
            # contains a '.' or ':') and keep only the image name + tag.
            parts = image_ref.split("/")
            if len(parts) > 1 and ("." in parts[0] or ":" in parts[0]):
                image_name = "/".join(parts[1:])
            else:
                image_name = image_ref
            return f"{prefix}gcr.io/deloitte-gcs/{image_name}"

        new_text = re.sub(
            r'(image:\s*)([\w.:/@-]+(?:/[\w.:@-]+)*)',
            _fix_image,
            text,
        )
        path.write_text(new_text)

    def _fix_pg_004(self, v: Violation) -> None:
        """Add timeout: 1h to stage definition."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        # Add timeout after 'type: Deployment' if missing
        new_text = re.sub(
            r'(type:\s*Deployment\n)(?!.*timeout)',
            r'\1  timeout: 1h\n',
            text,
        )
        path.write_text(new_text)

    def _fix_pg_005(self, v: Violation) -> None:
        """Add org-approved to empty delegateSelectors."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        new_text = re.sub(
            r'(delegateSelectors:\s*\[\s*\])',
            'delegateSelectors:\n              - org-approved',
            text,
        )
        path.write_text(new_text)

    def _fix_pg_007(self, v: Violation) -> None:
        """Add default HelmRollback rollbackSteps block."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        rollback_block = textwrap.dedent("""\
          rollbackSteps:
            - step:
                type: HelmRollback
                name: auto-rollback
                spec: {}
        """)
        # Append rollbackSteps after execution block if missing
        if "rollbackSteps" not in text:
            new_text = re.sub(
                r'(execution:.*?steps:.*?(?:\n\s+- step:.*?)+)',
                r'\1\n' + rollback_block,
                text,
                flags=re.DOTALL,
                count=1,
            )
            path.write_text(new_text)

    def _fix_pg_008(self, v: Violation) -> None:
        """Add auto-generated description if blank."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        new_text = re.sub(
            r'(description:\s*["\']?\s*["\']?)',
            'description: "Auto-generated description - please update before merge"',
            text,
            count=1,
        )
        path.write_text(new_text)

    def _fix_pg_009(self, v: Violation) -> None:
        """Add placeholder owner and cost-centre tags."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        if "tags:" not in text:
            new_text = re.sub(
                r'(pipeline:\n)',
                'pipeline:\n  tags:\n    owner: please-update\n    cost-centre: please-update\n',
                text,
                count=1,
            )
        else:
            placeholder = ""
            if "owner:" not in text:
                placeholder += "\n    owner: please-update"
            if "cost-centre:" not in text:
                placeholder += "\n    cost-centre: please-update"
            new_text = re.sub(r'(tags:)', r'\1' + placeholder, text, count=1)
        path.write_text(new_text)

# ---------------------------------------------------------------------------
# PiAutoFixer
# ---------------------------------------------------------------------------

class PiAutoFixer:
    """Auto-fix logic for Pi coding agent OPA violations (PI-001 … PI-008)."""

    def generate_fix(self, violations: list[Violation]) -> str:
        summaries = [f"Apply fix for {v.rule_id} in {v.file}" for v in violations]
        return "; ".join(summaries) if summaries else "no-op"

    def apply_fix(self, violations: list[Violation]) -> None:
        for v in violations:
            method = getattr(self, f"_fix_{v.rule_id.lower().replace('-', '_')}", None)
            if method:
                try:
                    method(v)
                except Exception as exc:  # noqa: BLE001
                    print(f"[PiAutoFixer] WARNING: fix for {v.rule_id} raised: {exc}", file=sys.stderr)

    # ---- individual fixes --------------------------------------------------

    def _fix_pi_001(self, v: Violation) -> None:
        self._upgrade_bash_level(v.file)

    def _fix_pi_002(self, v: Violation) -> None:
        self._upgrade_bash_level(v.file)

    @staticmethod
    def _upgrade_bash_level(filepath: str) -> None:
        """Set bash_security_level to L4 in the pi_agent config file."""
        path = Path(filepath)
        if not path.exists():
            return
        text = path.read_text()
        new_text = re.sub(
            r'(bash_security_level:\s*)["\']?L[1-3]["\']?',
            r'\1L4  # AUTO-FIXED: upgraded to L4',
            text,
        )
        path.write_text(new_text)

    def _fix_pi_003(self, v: Violation) -> None:
        """Remove blocked bash command from bash_commands list."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        # Heuristic: remove lines containing known high-risk commands
        blocked = [r"rm\s+-rf", r"curl\s+.*\|\s*sh", r"wget\s+.*\|\s*sh", r"chmod\s+777"]
        new_text = text
        for pat in blocked:
            new_text = re.sub(rf"^\s*-\s+.*{pat}.*\n", "", new_text, flags=re.MULTILINE | re.IGNORECASE)
        path.write_text(new_text)

    def _fix_pi_004(self, v: Violation) -> None:
        """Add pytest step before gh pr create in workflow config."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        if "pytest" not in text:
            new_text = re.sub(
                r'(gh pr create)',
                'pytest\n        - run: gh pr create',
                text,
                count=1,
            )
            path.write_text(new_text)

    def _fix_pi_005(self, v: Violation) -> None:
        """PI-005 (human approval gate) can never be auto-fixed.

        Flipping human_approval_completed to true here would let the Loop
        Engine grant its own approval — exactly the bypass
        docs/violation-remediation.md prohibits ("No fully automated PR
        submissions are permitted under any circumstances"). This is
        intentionally a no-op: the violation persists until a human sets
        the field themselves, so the loop escalates instead of self-approving.
        """
        print(
            f"[PiAutoFixer] PI-005 requires a real human approval and cannot "
            f"be auto-fixed — leaving {v.file} unchanged.",
            file=sys.stderr,
        )

    def _fix_pi_006(self, v: Violation) -> None:
        """Run autopep8 on the failing Python file."""
        try:
            subprocess.run(
                ["autopep8", "--in-place", "--aggressive", v.file],
                check=True,
                capture_output=True,
                timeout=60,
            )
        except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired) as exc:
            print(f"[PiAutoFixer] autopep8 unavailable or failed: {exc}", file=sys.stderr)

    def _fix_pi_007(self, v: Violation) -> None:
        """Replace hardcoded secret patterns with os.environ.get() calls."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()

        def _replace_secret(match: re.Match) -> str:
            key = match.group(1)
            env_key = key.upper().replace("-", "_")
            return f'{key} = os.environ.get("{env_key}")'

        new_text = re.sub(
            r'(\w*(?:secret|token|key|password|api_key|credential)\w*)\s*=\s*["\'][A-Za-z0-9+/]{16,}["\']',
            _replace_secret,
            text,
            flags=re.IGNORECASE,
        )
        if "import os" not in new_text and new_text != text:
            new_text = "import os\n" + new_text
        path.write_text(new_text)

    def _fix_pi_008(self, v: Violation) -> None:
        """Generate minimal unit test for each function without a test."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        funcs = re.findall(r'^def (\w+)\(', text, re.MULTILINE)
        test_path = Path(str(path).replace(".py", "_test.py"))
        existing_tests: set[str] = set()
        if test_path.exists():
            existing_tests = set(re.findall(r'^def (test_\w+)\(', test_path.read_text(), re.MULTILINE))
        new_tests = []
        for func in funcs:
            test_name = f"test_{func}"
            if test_name not in existing_tests:
                new_tests.append(
                    f"\ndef {test_name}():\n"
                    f"    # TODO: Implement test for {func}\n"
                    f"    pass\n"
                )
        if new_tests:
            with test_path.open("a") as fh:
                fh.write("\n".join(new_tests))

# ---------------------------------------------------------------------------
# ResearchAutoFixer
# ---------------------------------------------------------------------------

class ResearchAutoFixer:
    """Auto-fix logic for Research Agent .rego syntax and duplicate rule IDs."""

    def generate_fix(self, violations: list[Violation]) -> str:
        summaries = [f"Research fix for {v.rule_id} in {v.file}" for v in violations]
        return "; ".join(summaries) if summaries else "no-op"

    def apply_fix(self, violations: list[Violation]) -> None:
        for v in violations:
            if "syntax" in v.description.lower():
                self._fix_rego_syntax(v)
            elif "duplicate" in v.description.lower():
                self._fix_duplicate_rule_id(v)

    @staticmethod
    def _fix_rego_syntax(v: Violation) -> None:
        """Apply common OPA syntax fixes then validate with `opa check`."""
        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        lines = text.splitlines()

        # Fix 1 — ensure file ends with a newline
        if lines and lines[-1].strip():
            lines.append("")

        # Fix 2 — missing closing brace at EOF
        open_braces  = text.count("{")
        close_braces = text.count("}")
        if open_braces > close_braces:
            lines.append("}" * (open_braces - close_braces))

        # Fix 3 — invalid operator := outside of rule head (e.g. package-level assignment)
        # Only replaces := when it appears as a standalone assignment statement
        # (not inside [ ] or { } where it is valid Rego syntax).
        fixed_lines = []
        inside_comprehension = 0
        for line in lines:
            inside_comprehension += line.count("[") - line.count("]")
            inside_comprehension += line.count("{") - line.count("}")
            if inside_comprehension <= 0:
                fixed_lines.append(re.sub(r'(?<![=!<>]):=', "=", line))
            else:
                fixed_lines.append(line)

        path.write_text("\n".join(fixed_lines))

        # Validate
        try:
            result = subprocess.run(
                [OPA_PATH, "check", str(path)],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode != 0:
                print(f"[ResearchAutoFixer] opa check still failing: {result.stderr}", file=sys.stderr)
        except FileNotFoundError:
            print("[ResearchAutoFixer] opa binary not found — skipping validation", file=sys.stderr)
        except subprocess.TimeoutExpired:
            print("[ResearchAutoFixer] opa check timed out after 30s — skipping validation", file=sys.stderr)

    @staticmethod
    def _fix_duplicate_rule_id(v: Violation) -> None:
        """Auto-increment duplicate rule ID to next available ID."""
        policy_dirs = [Path("policies/opa"), Path("policies/pi"), Path("policies/research")]
        all_ids: list[int] = []
        for d in policy_dirs:
            for rego in d.glob("*.rego"):
                if rego.name.endswith("_test.rego"):
                    continue
                # Real rule headers use "# RULE:" (all caps) — see e.g.
                # pipeline-guardrails.rego — not the mixed-case "# Rule:"
                # this previously matched, which found zero real rule IDs.
                for m in re.finditer(r'#\s*RULE:\s*[A-Z]+-(\d+)', rego.read_text(), re.IGNORECASE):
                    all_ids.append(int(m.group(1)))
        next_num = (max(all_ids) + 1) if all_ids else 1

        path = Path(v.file)
        if not path.exists():
            return
        text = path.read_text()
        # Replace the first duplicate occurrence
        new_text = re.sub(
            r'(#\s*RULE:\s*[A-Z]+-)(\d+)',
            lambda m, nn=next_num: f"{m.group(1)}{nn:03d}",
            text,
            count=1,
            flags=re.IGNORECASE,
        )
        path.write_text(new_text)

# ---------------------------------------------------------------------------
# LoopNotifier
# ---------------------------------------------------------------------------

class LoopNotifier:
    """Creates a GitHub Issue and posts a PR comment when escalation is needed."""

    def __init__(self, pipeline: str, rule_id: str, max_attempts: int = 3) -> None:
        self.pipeline    = pipeline
        self.rule_id     = rule_id
        self.max_attempts = max_attempts
        self.repo        = os.environ.get("GITHUB_REPOSITORY", "")
        self.token       = os.environ.get("GITHUB_TOKEN", "")
        self.pr_number   = os.environ.get("PR_NUMBER", "")

    def escalate_to_human(self, loop_history: list[FixRecord]) -> None:
        body = self._build_issue_body(loop_history)
        issue_url = self._create_github_issue(body)
        self._post_pr_comment(issue_url, loop_history)

    def _build_issue_body(self, loop_history: list[FixRecord]) -> str:
        attempts_md = ""
        for rec in loop_history:
            violations_str = "; ".join(v.description for v in rec.violations)
            attempts_md += (
                f"**Attempt {rec.attempt}:** {violations_str} "
                f"→ {rec.fix_applied} → {rec.result.value}\n\n"
            )
        return textwrap.dedent(f"""\
            ## Loop History

            {attempts_md}

            ## Manual Action Required

            The loop engine could not auto-fix this violation after {self.max_attempts} attempt(s).
            Please review and fix manually.

            ## Violation Details

            - **Pipeline:** `{self.pipeline}`
            - **Rule:** `{self.rule_id}`

            See `docs/violation-remediation.md` for fix guidance.
        """)

    def _create_github_issue(self, body: str) -> str:
        if not self.token or not self.repo:
            print("[LoopNotifier] GITHUB_TOKEN or GITHUB_REPOSITORY not set — skipping issue creation", file=sys.stderr)
            return ""
        payload = json.dumps({
            "title": f"Loop Engine: Auto-fix failed after {self.max_attempts} attempt(s) — {self.pipeline} {self.rule_id}",
            "body":  body,
            "labels": ["loop-engine-escalation", "needs-human-review"],
        }).encode()
        url = f"https://api.github.com/repos/{self.repo}/issues"
        req = urllib.request.Request(
            url,
            data=payload,
            headers={
                "Authorization": f"token {self.token}",
                "Accept":        "application/vnd.github+json",
                "Content-Type":  "application/json",
                "X-GitHub-Api-Version": "2022-11-28",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
                issue_url = data.get("html_url", "")
                print(f"[LoopNotifier] Issue created: {issue_url}")
                return issue_url
        except Exception as exc:  # noqa: BLE001
            print(f"::error::[LoopNotifier] Failed to create escalation issue: {exc}", file=sys.stderr)
            return ""

    def notify_secret_masked(self, violations: list[Violation]) -> None:
        """PG-002 auto-fix only masks the plaintext value in YAML — it does
        not rotate the underlying credential. docs/violation-remediation.md
        requires escalating to Security immediately whenever a secret may
        have been exposed, so this fires unconditionally whenever PG-002 is
        auto-fixed, independent of whether the loop ultimately PASSes.
        """
        if not self.token or not self.repo:
            print(
                "[LoopNotifier] GITHUB_TOKEN or GITHUB_REPOSITORY not set — "
                "skipping PG-002 security notification",
                file=sys.stderr,
            )
            return
        details = "; ".join(sorted({v.description for v in violations})) or "unknown field"
        body = textwrap.dedent(f"""\
            ## 🔐 Possible Credential Exposure — Manual Rotation Required

            The Loop Engine auto-fixer replaced a plaintext secret value with a
            Harness Secret Manager reference (rule PG-002), but this does NOT
            rotate the underlying credential.

            **Pipeline:** `{self.pipeline}`
            **Details:** {details}

            ## Action Required
            Per docs/violation-remediation.md, PG-002 permits no exceptions:
            rotate the exposed credential in the source system immediately,
            then confirm the new secret is registered in Harness Secret Manager.
        """)
        payload = json.dumps({
            "title": f"🔐 Loop Engine: possible credential exposure — {self.pipeline} PG-002",
            "body":  body,
            "labels": ["needs-human-review"],
        }).encode()
        url = f"https://api.github.com/repos/{self.repo}/issues"
        req = urllib.request.Request(
            url,
            data=payload,
            headers={
                "Authorization": f"token {self.token}",
                "Accept":        "application/vnd.github+json",
                "Content-Type":  "application/json",
                "X-GitHub-Api-Version": "2022-11-28",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
                print(f"[LoopNotifier] Security notification issue created: {data.get('html_url', '')}")
        except Exception as exc:  # noqa: BLE001
            print(f"::error::[LoopNotifier] Failed to create security notification issue: {exc}", file=sys.stderr)

    def _post_pr_comment(self, issue_url: str, loop_history: list[FixRecord]) -> None:
        if not self.token or not self.repo or not self.pr_number:
            return
        body_lines = [
            f"## ⚠️ Loop Engine — Escalation Required",
            "",
            f"The auto-fix loop for **{self.pipeline} / {self.rule_id}** exhausted all "
            f"{self.max_attempts} attempts without resolving the violation.",
            "",
        ]
        for rec in loop_history:
            body_lines.append(f"- Attempt {rec.attempt}: {rec.fix_applied} → **{rec.result.value}**")
        if issue_url:
            body_lines += ["", f"📋 GitHub Issue: {issue_url}"]
        body_lines.append("\nPlease fix manually. See `docs/violation-remediation.md`.")
        payload = json.dumps({"body": "\n".join(body_lines)}).encode()
        url = f"https://api.github.com/repos/{self.repo}/issues/{self.pr_number}/comments"
        req = urllib.request.Request(
            url,
            data=payload,
            headers={
                "Authorization": f"token {self.token}",
                "Accept":        "application/vnd.github+json",
                "Content-Type":  "application/json",
                "X-GitHub-Api-Version": "2022-11-28",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
                print(f"[LoopNotifier] PR comment posted: {data.get('html_url', '')}")
        except Exception as exc:  # noqa: BLE001
            print(f"::error::[LoopNotifier] Failed to post PR comment: {exc}", file=sys.stderr)

# ---------------------------------------------------------------------------
# LoopEngine
# ---------------------------------------------------------------------------

class LoopEngine:
    """
    Orchestrates evaluate → fix → re-evaluate cycles for a given pipeline type.

    Parameters
    ----------
    pipeline_type : str
        One of ``harness``, ``pi``, ``research``.
    context : dict
        Violation details and relevant file paths passed in from the caller.
    max_attempts : int
        Maximum number of fix attempts before escalating (default 3).
    """

    MAX_ATTEMPTS = 3

    def __init__(self, pipeline_type: str, context: dict[str, Any], max_attempts: int = 3) -> None:
        self.pipeline_type = pipeline_type
        self.context       = context
        self.max_attempts  = max_attempts
        self.loop_history: list[FixRecord] = []

    # ------------------------------------------------------------------

    def _severity_attempt_budget(self, violations: list[Violation]) -> int:
        """Map the worst severity among current violations to an auto-fix
        attempt budget, per Benchmark-agent.md's documented policy:
        CRITICAL/HIGH get the full retry budget, MEDIUM gets exactly one
        attempt, LOW is advisory only (no auto-fix loop at all).
        """
        severities = {v.severity.upper() for v in violations}
        if "CRITICAL" in severities or "HIGH" in severities:
            return self.max_attempts
        if "MEDIUM" in severities:
            return 1
        if "LOW" in severities:
            return 0
        return self.max_attempts

    def run(self, evaluator: "BaseEvaluator", fixer: "BaseFixer") -> LoopResult:
        notifier = LoopNotifier(
            pipeline=self.pipeline_type,
            rule_id=self.context.get("rule_id", "UNKNOWN"),
            max_attempts=self.max_attempts,
        )

        result = evaluator.evaluate()
        if result.passed:
            LoopLogger.log(
                pipeline=self.pipeline_type,
                rule_id=self.context.get("rule_id", "UNKNOWN"),
                attempt=1,
                violation="",
                fix_applied="none",
                result=LoopResult.PASS,
            )
            print("[LoopEngine] PASS on attempt 1")
            return LoopResult.PASS

        max_attempts = self._severity_attempt_budget(result.violations)

        if max_attempts == 0:
            for v in result.violations:
                LoopLogger.log(
                    pipeline=self.pipeline_type,
                    rule_id=v.rule_id,
                    attempt=0,
                    violation=v.description,
                    fix_applied="advisory only — LOW severity is not auto-fixed",
                    result=LoopResult.FAIL,
                )
            print("[LoopEngine] LOW-severity violations only — advising, no auto-fix loop")
            # Advisory-only: never auto-fixed, so there is nothing to escalate
            # to a human either — escalating here would be a fresh GitHub
            # Issue/PR comment for something the loop was never asked to fix.
            return LoopResult.FAIL

        for attempt in range(1, max_attempts + 1):
            if attempt > 1:
                result = evaluator.evaluate()
                if result.passed:
                    LoopLogger.log(
                        pipeline=self.pipeline_type,
                        rule_id=self.context.get("rule_id", "UNKNOWN"),
                        attempt=attempt,
                        violation="",
                        fix_applied="none",
                        result=LoopResult.PASS,
                    )
                    print(f"[LoopEngine] PASS on attempt {attempt}")
                    return LoopResult.PASS

            fix_description = fixer.generate_fix(result.violations)
            fixer.apply_fix(result.violations)

            record = FixRecord(
                attempt=attempt,
                violations=result.violations,
                fix_applied=fix_description,
                result=LoopResult.FAIL,
            )
            self.loop_history.append(record)

            for v in result.violations:
                LoopLogger.log(
                    pipeline=self.pipeline_type,
                    rule_id=v.rule_id,
                    attempt=attempt,
                    violation=v.description,
                    fix_applied=fix_description,
                    result=LoopResult.FAIL,
                )
            print(f"[LoopEngine] Attempt {attempt} FAIL — fix applied: {fix_description}")

        # The fix applied on the FINAL attempt above was never checked by the
        # loop (only attempts 2..max_attempts re-evaluate the PRIOR attempt's
        # fix) — without this, a MEDIUM-severity violation (budget=1) would
        # escalate unconditionally even when its one fix attempt worked.
        final_result = evaluator.evaluate()
        if final_result.passed:
            LoopLogger.log(
                pipeline=self.pipeline_type,
                rule_id=self.context.get("rule_id", "UNKNOWN"),
                attempt=max_attempts,
                violation="",
                fix_applied="none",
                result=LoopResult.PASS,
            )
            print(f"[LoopEngine] PASS after final fix attempt {max_attempts}")
            return LoopResult.PASS

        # Attempt budget exhausted — escalate
        notifier.max_attempts = max_attempts
        notifier.escalate_to_human(self.loop_history)
        LoopLogger.log(
            pipeline=self.pipeline_type,
            rule_id=self.context.get("rule_id", "UNKNOWN"),
            attempt=max_attempts,
            violation="max attempts reached",
            fix_applied="escalated to human",
            result=LoopResult.ESCALATED,
        )
        print(f"[LoopEngine] ESCALATED — {max_attempts} attempt(s) exhausted")
        return LoopResult.ESCALATED

# ---------------------------------------------------------------------------
# Evaluators
# ---------------------------------------------------------------------------

class BaseEvaluator:
    def evaluate(self) -> EvalResult:
        raise NotImplementedError


class BaseFixer:
    def generate_fix(self, violations: list[Violation]) -> str:
        raise NotImplementedError

    def apply_fix(self, violations: list[Violation]) -> None:
        raise NotImplementedError


class OpaEvaluator(BaseEvaluator):
    """Runs `opa eval` against a policy file and input document."""

    def __init__(self, policy_path: str, input_path: str, query: str, target_file: str = "", yaml_source: str = "") -> None:
        self.policy_path = policy_path
        self.input_path  = input_path
        self.query       = query
        # target_file is the pipeline YAML being evaluated (not the .rego policy).
        # Violations will reference this file so auto-fixers modify the correct YAML.
        self.target_file = target_file or policy_path
        # yaml_source: if set, re-read and re-serialise this YAML file on every
        # evaluate() call so that auto-fixes applied between attempts are reflected.
        self.yaml_source = yaml_source

    def evaluate(self) -> EvalResult:
        # Re-read from yaml_source on every call so that fixes applied between
        # loop attempts are picked up by the next evaluation.
        input_path     = self.input_path
        tmp_to_delete  = ""
        if self.yaml_source:
            try:
                import yaml as _yaml  # noqa: PLC0415
                with open(self.yaml_source) as fh:
                    raw_doc   = _yaml.safe_load(fh) or {}
                input_doc = yaml_to_opa_input(raw_doc)
                with tempfile.NamedTemporaryFile(
                    mode="w", suffix=".json", prefix="loop_engine_eval_", delete=False
                ) as tmp:
                    json.dump(input_doc, tmp)
                    input_path    = tmp.name
                    tmp_to_delete = tmp.name
            except Exception as exc:  # noqa: BLE001
                print(
                    f"[OpaEvaluator] Failed to reload yaml_source {self.yaml_source!r}: {exc}"
                    " — falling back to initial input file",
                    file=sys.stderr,
                )

        cmd = [
            OPA_PATH, "eval",
            "--data",   self.policy_path,
            "--input",  input_path,
            "--format", "json",
            self.query,
        ]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, check=False, timeout=60)
            raw = proc.stdout
            data = json.loads(raw) if raw else {}
        except (FileNotFoundError, json.JSONDecodeError, subprocess.TimeoutExpired) as exc:
            return EvalResult(passed=False, raw_output=str(exc), violations=[
                Violation(rule_id="OPA-ERROR", severity="CRITICAL", file=self.target_file, description=str(exc))
            ])
        finally:
            if tmp_to_delete:
                try:
                    os.unlink(tmp_to_delete)
                except OSError:
                    pass

        violations: list[Violation] = []
        results = data.get("result", [])
        for r in results:
            exprs = r.get("expressions", [])
            for expr in exprs:
                val = expr.get("value", {})
                if isinstance(val, list):
                    # Response from data.harness.pipeline.guardrails.violation:
                    # a list/set of violation objects, each with "rule", "severity",
                    # "issue" (and other) fields.
                    for item in val:
                        if isinstance(item, dict) and "rule" in item:
                            violations.append(Violation(
                                rule_id=item.get("rule", "UNKNOWN"),
                                severity=item.get("severity", "MEDIUM"),
                                file=self.target_file,
                                description=item.get("issue", item.get("message", "")),
                                line=item.get("line", 0),
                            ))
                        elif isinstance(item, str):
                            violations.append(Violation(
                                rule_id="UNKNOWN",
                                severity="MEDIUM",
                                file=self.target_file,
                                description=item,
                            ))
                elif isinstance(val, dict):
                    for rule_id, details in val.items():
                        if isinstance(details, list) and details:
                            for detail in details:
                                if isinstance(detail, dict):
                                    violations.append(Violation(
                                        rule_id=rule_id.upper(),
                                        severity=detail.get("severity", "MEDIUM"),
                                        file=self.target_file,
                                        description=detail.get("message", ""),
                                        line=detail.get("line", 0),
                                    ))
                                else:
                                    # OPA policy returns plain strings as violation messages
                                    violations.append(Violation(
                                        rule_id=rule_id.upper(),
                                        severity="MEDIUM",
                                        file=self.target_file,
                                        description=str(detail),
                                    ))

        return EvalResult(passed=len(violations) == 0, violations=violations, raw_output=raw)


class RegoSyntaxEvaluator(BaseEvaluator):
    """Validates .rego file syntax using `opa check`."""

    def __init__(self, rego_dir: str) -> None:
        self.rego_dir = rego_dir

    def evaluate(self) -> EvalResult:
        violations: list[Violation] = []
        for rego_file in Path(self.rego_dir).rglob("*.rego"):
            if rego_file.name.endswith("_test.rego"):
                continue
            try:
                proc = subprocess.run(
                    [OPA_PATH, "check", str(rego_file)],
                    capture_output=True, text=True, check=False, timeout=30,
                )
            except subprocess.TimeoutExpired:
                violations.append(Violation(
                    rule_id="REGO-SYNTAX",
                    severity="HIGH",
                    file=str(rego_file),
                    description="opa check timed out after 30s",
                ))
                continue
            if proc.returncode != 0:
                violations.append(Violation(
                    rule_id="REGO-SYNTAX",
                    severity="HIGH",
                    file=str(rego_file),
                    description=f"OPA syntax error: {proc.stderr.strip()[:200]}",
                ))
        return EvalResult(passed=len(violations) == 0, violations=violations)

# ---------------------------------------------------------------------------
# Pipeline runners
# ---------------------------------------------------------------------------

def _run_harness_loop(max_attempts: int) -> LoopResult:
    """Run the Harness OPA loop over all pipeline YAML files in the repo.

    Pipeline YAML files are resolved in this priority order:
    1. Non-policy YAML files changed in the current PR branch (git diff).
    2. YAML files in ``policies/pipeline/`` and ``test-inputs/`` as a fallback.
    """
    pr_branch = os.environ.get("GITHUB_REF_NAME", "")

    # Primary: PR-changed yaml files (excludes policies/)
    yaml_files = [Path(f) for f in get_pr_yaml_files(pr_branch)]

    # Fallback to well-known directories when running outside a PR context
    if not yaml_files:
        for search_dir in [Path("policies/pipeline"), Path("test-inputs")]:
            if search_dir.exists():
                yaml_files += list(search_dir.glob("*.yaml")) + list(search_dir.glob("*.yml"))

    if not yaml_files:
        print("[harness-loop] No pipeline YAML files found — PASS")
        return LoopResult.PASS

    worst = LoopResult.PASS
    for yaml_file in yaml_files:
        input_doc: dict = {"pipeline": {}}  # minimal stub; replaced by actual file content
        try:
            import yaml as _yaml  # noqa: PLC0415
            with yaml_file.open() as fh:
                raw_doc   = _yaml.safe_load(fh) or {}
            input_doc = yaml_to_opa_input(raw_doc)
        except Exception:  # noqa: BLE001
            pass

        # Write input to a secure temp file for OPA
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".json", prefix="loop_engine_", delete=False
        ) as tmp:
            json.dump(input_doc, tmp)
            input_tmp_path = tmp.name

        policy_file = "policies/opa/pipeline-guardrails.rego"
        evaluator = OpaEvaluator(
            policy_path=policy_file,
            input_path=input_tmp_path,
            query="data.harness.pipeline.guardrails.violation",
            target_file=str(yaml_file),
            yaml_source=str(yaml_file),
        )
        fixer   = HarnessAutoFixer()
        context = {"rule_id": "PG-*", "file": str(yaml_file)}
        engine  = LoopEngine("harness", context, max_attempts)
        try:
            result = engine.run(evaluator, fixer)
        finally:
            try:
                os.unlink(input_tmp_path)
            except OSError:
                pass

        pg002_fixes = [v for rec in engine.loop_history for v in rec.violations if v.rule_id == "PG-002"]
        if pg002_fixes:
            LoopNotifier(pipeline="harness", rule_id="PG-002", max_attempts=max_attempts).notify_secret_masked(pg002_fixes)

        if result == LoopResult.ESCALATED:
            worst = LoopResult.ESCALATED
        elif result == LoopResult.FAIL and worst == LoopResult.PASS:
            worst = LoopResult.FAIL
    return worst


def _run_pi_loop(max_attempts: int) -> LoopResult:
    """Run the Pi OPA loop over policies/pi/ .rego files."""
    evaluator = RegoSyntaxEvaluator("policies/pi")
    fixer     = PiAutoFixer()
    context   = {"rule_id": "PI-*"}
    engine    = LoopEngine("pi", context, max_attempts)
    return engine.run(evaluator, fixer)


def _run_research_loop(max_attempts: int) -> LoopResult:
    """Run the Research loop — OPA syntax validation of all policy files."""
    evaluator = RegoSyntaxEvaluator("policies")
    fixer     = ResearchAutoFixer()
    context   = {"rule_id": "REGO-SYNTAX"}
    engine    = LoopEngine("research", context, max_attempts)
    return engine.run(evaluator, fixer)

# ---------------------------------------------------------------------------
# post-report helper
# ---------------------------------------------------------------------------

def post_compliance_report(pr_number: str, pipeline: str) -> None:
    """Post a compliance summary as a PR comment."""
    token = os.environ.get("GITHUB_TOKEN", "") or os.environ.get("GH_TOKEN", "")
    repo  = os.environ.get("GITHUB_REPOSITORY", "")

    if not token:
        print("[post-report] GITHUB_TOKEN not set — skipping report")
        return
    if not pr_number:
        print("[post-report] PR number not provided — skipping report")
        return
    if not repo:
        print("[post-report] GITHUB_REPOSITORY not set — skipping report")
        return

    log_content = ""
    if LOG_PATH.exists():
        lines = LOG_PATH.read_text().splitlines()
        log_content = "\n".join(lines[-20:])

    pipeline_label = pipeline.title() if pipeline else "Unknown"
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    report = (
        f"## 🛡️ {pipeline_label} Compliance Report\n\n"
        f"**Pipeline:** {pipeline_label}  \n"
        f"**PR:** #{pr_number}  \n"
        f"**Date:** {now}\n\n"
        "### Loop Engine Results\n"
        "Check the Actions tab for detailed violation reports and auto-fix history.\n\n"
        "### Recent Loop Activity\n\n"
        f"```\n{log_content}\n```\n"
    )

    url  = f"https://api.github.com/repos/{repo}/issues/{pr_number}/comments"
    data = json.dumps({"body": report}).encode()
    req  = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"token {token}",
            "Content-Type":  "application/json",
            "Accept":        "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        method="POST",
    )
    try:
        urllib.request.urlopen(req, timeout=30)
        print(f"[post-report] Posted compliance report to PR #{pr_number}")
    except urllib.error.HTTPError as exc:
        print(f"[post-report] HTTP error posting report: {exc.code} {exc.reason}", file=sys.stderr)
    except urllib.error.URLError as exc:
        print(f"[post-report] URL error posting report: {exc.reason}", file=sys.stderr)


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description="Loop Engine — AI Auto-Fix Pipeline")
    parser.add_argument(
        "--pipeline",
        choices=["harness", "pi", "research"],
        help="Pipeline type to evaluate",
    )
    parser.add_argument("--max-attempts", type=int, default=LoopEngine.MAX_ATTEMPTS,
                        help="Maximum fix attempts")
    parser.add_argument("--auto-fix",     type=str, default="true",
                        help="Enable auto-fix (true/false)")
    parser.add_argument("--pr-branch",    type=str, default="",
                        help="PR branch name")
    parser.add_argument("--pr-number",    type=str, default="",
                        help="PR number")
    parser.add_argument(
        "--action",
        type=str,
        default="evaluate",
        choices=["evaluate", "post-report"],
        help="Action to perform",
    )
    args = parser.parse_args()

    if args.max_attempts < 1:
        print(f"Error: --max-attempts must be >= 1 (got {args.max_attempts})", file=sys.stderr)
        return 1

    # Propagate pr_number so LoopNotifier can read it via env var
    if args.pr_number:
        os.environ["PR_NUMBER"] = args.pr_number

    if args.action == "post-report":
        post_compliance_report(pr_number=args.pr_number, pipeline=args.pipeline or "")
        return 0

    # --pipeline is required for the evaluate action
    if not args.pipeline:
        print("Error: --pipeline is required for the evaluate action", file=sys.stderr)
        return 1

    runners = {
        "harness":  _run_harness_loop,
        "pi":       _run_pi_loop,
        "research": _run_research_loop,
    }

    runner = runners[args.pipeline]
    result = runner(args.max_attempts)

    print(f"\n[LoopEngine] Final result for pipeline '{args.pipeline}': {result.value}")

    if result == LoopResult.PASS:
        return 0
    elif result == LoopResult.ESCALATED:
        return 2
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())
