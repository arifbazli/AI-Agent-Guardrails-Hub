# Cloud-AI-Agent-Guardrails

A self-healing guardrail system for Harness CI/CD pipelines and Pi coding-agent
workflows. Policies are written in [OPA/Rego](https://www.openpolicyagent.org/);
a multi-agent hub interprets results, auto-fixes what it can, and escalates
what it can't.

## How it works

1. **Benchmark Agent** — single entry point for developers (PR review, Q&A),
   orchestrates the other agents.
2. **Guardrail Enforcement Agent** — runs the 34 Harness OPA rules against
   pipeline, connector, delegate, and code input.
3. **Pi Guardrail Agent** — runs the 10 Pi rules against coding-agent
   bash/workflow/code input.
4. **Research Agent** — weekly scan of NVD + CISA KEV for threats with no
   matching rule; flags gaps for manual review (no auto-drafting or PR
   creation — see [GitHub Enterprise Cloud note](#github-enterprise-cloud-note)).
5. **Loop Engine** — on FAIL, auto-fixes the violation and re-evaluates, up to
   a severity-gated retry budget, then escalates.

| Severity | Retry budget |
|---|---|
| CRITICAL / HIGH | Full retry loop (default 3 attempts) |
| MEDIUM | 1 attempt, then advise |
| LOW | Advisory only — no auto-fix |

Full diagram: [`docs/assets/architecture.svg`](docs/assets/architecture.svg).

## Repository layout

| Path | Contents |
|---|---|
| `.github/agents/` | The 4 agent specs above (Markdown prompts) |
| `.github/workflows/` | The 3 GitHub Actions workflows below |
| `policies/opa/` | Harness OPA policies (5 `.rego` + matching `_test.rego`) |
| `policies/pi/` | Pi coding-agent OPA policies (3 `.rego` + matching `_test.rego`) |
| `policies/pipeline/` | `approval-rules.yaml` / `stage-gates.yaml` — Harness-native gate config |
| `policies/research/` | Research Agent logs (`update-log.md`, `loop-log.md`, `current-scan-summary.md`) and `threat-feed.yaml` |
| `scripts/` | `loop_engine.py`, `research_agent.py`, `scan_health_check.py` |
| `test-inputs/` | Sample pipeline YAML fixtures used by the Loop Engine |
| `docs/` | Policy-writing guide, per-rule remediation reference, maintenance runbook |

Full tree: [`docs/assets/file-structure.svg`](docs/assets/file-structure.svg).

## Policies

44 enforced rules across 8 files, plus 31 draft rules pending review.

| File | Package | Rules | Covers |
|---|---|---|---|
| `pipeline-guardrails.rego` | `harness.pipeline.guardrails` | PG-001–009 | Approvals, secrets, registries, timeouts, delegates, rollback |
| `code-security.rego` | `harness.code.security` | CS-001–009 | Hardcoded secrets, insecure functions, branch protection, SAST |
| `connector-compliance.rego` | `harness.connector.compliance` | CC-001–008 | Secret refs, credential expiry, auth type, naming |
| `delegate-validation.rego` | `harness.delegate.validation` | DV-001–008 | Connectivity, version, root/privileged, resource limits |
| `bash-security.rego` | `pi.guardrails.bash` | PI-001–003 | Bash security level, command whitelist/blocklist |
| `workflow-gates.rego` | `pi.guardrails.workflow` | PI-004, 005, 010 | Test-before-PR, human approval, audit logging |
| `code-standards.rego` | `pi.guardrails.code` | PI-006–009 | Lint, hardcoded secrets, test coverage, agent version |
| `research-proposals.rego` | `harness.research.proposals` | RRP-001–031 (DRAFT) | Threat-driven proposals awaiting promotion |

Per-rule detail and fix guidance: [`docs/policy-guide.md`](docs/policy-guide.md) ·
[`docs/violation-remediation.md`](docs/violation-remediation.md).

## Automation (GitHub Actions)

| Workflow | Trigger | Purpose |
|---|---|---|
| `loop-engine.yml` | PR opened/updated against `main` (human actors only) | Evaluate → auto-fix → re-evaluate → escalate |
| `research-agent.yml` | Monday 08:00 UTC, or manual dispatch | Threat scan, gap analysis, Issue on findings |
| `health-check.yml` | Every 12 hours, or manual dispatch | Policy files present, `opa test` passes, activity log |

Bot actors (`github-actions[bot]`, `copilot-swe-agent[bot]`, `dependabot[bot]`)
are excluded from triggering the Loop Engine.

## Getting started

```bash
# Run the policy test suites locally
opa test policies/opa/ -v
opa test policies/pi/ -v

# Evaluate a pipeline YAML manually
opa eval -d policies/opa/pipeline-guardrails.rego \
  -i your-pipeline.json "data.harness.pipeline.guardrails.violation"
```

Opening a PR against `main` triggers the Loop Engine automatically — no
extra setup required. Watch it under **Actions → Loop Engine — Auto-Fix
Pipeline**; results post back as a PR comment.

## GitHub Enterprise Cloud note

GHE org policy blocks Actions from opening PRs directly. The Research Agent
therefore files a GitHub Issue (labels `research-proposal`,
`needs-human-review`) instead of a PR — a human drafts the rule and opens
the PR after reviewing the Issue.

## Contributing

1. Branch as `policy/`, `fix/`, `docs/`, `feat/`, or `test/`.
2. New rule: add the `.rego` file, a matching `_test.rego`, and an entry in
   `docs/violation-remediation.md`.
3. Open a PR — the Loop Engine validates it automatically.
4. Policy exception: open an issue with the `policy-exception` label (see
   `docs/violation-remediation.md` for the process and per-rule limits).

## Docs

- [`docs/policy-guide.md`](docs/policy-guide.md) — how to write/read a policy
- [`docs/violation-remediation.md`](docs/violation-remediation.md) — fix guidance per rule ID
- [`docs/MAINTENANCE.md`](docs/MAINTENANCE.md) — runbook, common failures, escalation
