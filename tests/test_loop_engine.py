"""Specs for the Loop Engine's fail-closed and protected-path behavior.

Run from the repository root:  python3 -m unittest discover -s tests -v
OPA-backed specs run when the `opa` binary is available (OPA_PATH or PATH).
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))
os.environ.setdefault("OPA_PATH", shutil.which("opa") or "/usr/local/bin/opa")

import loop_engine as le  # noqa: E402

HAS_OPA = Path(le.OPA_PATH).exists()


def completed(returncode=0, stdout="", stderr=""):
    return subprocess.CompletedProcess(args=[], returncode=returncode, stdout=stdout, stderr=stderr)


class InRepoRoot(unittest.TestCase):
    def setUp(self):
        self._cwd = os.getcwd()
        os.chdir(REPO_ROOT)

    def tearDown(self):
        os.chdir(self._cwd)


class when_opa_eval_fails(InRepoRoot):
    def evaluate(self, proc):
        with patch.object(le.subprocess, "run", return_value=proc):
            return le.OpaEvaluator("p.rego", "in.json", "data.x.violation", target_file="pipe.yaml").evaluate()

    def test_should_fail_on_non_zero_exit(self):
        result = self.evaluate(completed(2, '{"errors":[{"message":"bad"}]}'))
        self.assertFalse(result.passed)
        self.assertEqual(result.violations[0].rule_id, "OPA-ERROR")

    def test_should_fail_on_errors_payload(self):
        self.assertFalse(self.evaluate(completed(0, '{"errors":[{"message":"bad"}]}')).passed)

    def test_should_fail_when_query_is_undefined(self):
        self.assertFalse(self.evaluate(completed(0, "{}")).passed)

    def test_should_pass_on_an_empty_violation_set(self):
        self.assertTrue(self.evaluate(completed(0, '{"result":[{"expressions":[{"value":[]}]}]}')).passed)


class when_computing_changed_files(unittest.TestCase):
    def test_should_diff_against_the_pr_base_branch(self):
        with patch.object(le.subprocess, "run", return_value=completed(0, "a.yaml\n")) as run:
            self.assertEqual(le.get_pr_changed_files("main"), ["a.yaml"])
        self.assertEqual(run.call_args.args[0][-1], "origin/main...HEAD")

    def test_should_default_to_github_base_ref(self):
        with patch.dict(os.environ, {"GITHUB_BASE_REF": "release"}, clear=False), \
             patch.object(le.subprocess, "run", return_value=completed(0, "")) as run:
            le.get_pr_changed_files()
        self.assertEqual(run.call_args.args[0][-1], "origin/release...HEAD")

    def test_should_raise_when_git_diff_fails(self):
        with patch.object(le.subprocess, "run", return_value=completed(128, "", "unknown revision")):
            with self.assertRaises(le.GitDiffError):
                le.get_pr_changed_files("main")

    def test_should_never_select_protected_yaml(self):
        changed = [
            "test-inputs/human-pr-test.yaml",
            "policies/pipeline/stage-gates.yaml",
            ".github/workflows/loop-engine.yml",
            "pipelines/deploy.yaml",
        ]
        with patch.object(le, "get_pr_changed_files", return_value=changed), \
             patch.object(le.os.path, "exists", return_value=True):
            self.assertEqual(le.get_pr_yaml_files("main"), ["pipelines/deploy.yaml"])


class when_a_pr_changes_no_pipeline_yaml(InRepoRoot):
    def test_should_pass_without_evaluating_or_touching_fixtures(self):
        fixtures = {p: p.read_bytes() for p in Path("test-inputs").glob("*.yaml")}
        with patch.object(le, "get_pr_changed_files", return_value=["README.md"]), \
             patch.object(le, "OpaEvaluator", side_effect=AssertionError("must not evaluate")):
            self.assertEqual(le._run_harness_loop(3, "main"), le.LoopResult.PASS)
        self.assertEqual(fixtures, {p: p.read_bytes() for p in fixtures})

    def test_should_fail_when_the_diff_cannot_be_computed(self):
        with patch.object(le, "get_pr_changed_files", side_effect=le.GitDiffError("boom")):
            self.assertEqual(le._run_harness_loop(3, "main"), le.LoopResult.FAIL)
            self.assertEqual(le._run_pi_loop(3, "main"), le.LoopResult.FAIL)

    def test_should_not_use_the_pi_fixture_as_activity(self):
        with patch.object(le, "get_pr_changed_files", return_value=["test-inputs/pi-agent-activity.yaml"]):
            self.assertIsNone(le.find_pi_activity_file("main"))


class when_auto_fixing(unittest.TestCase):
    def setUp(self):
        self._cwd = os.getcwd()
        self.tmp = tempfile.TemporaryDirectory()
        os.chdir(self.tmp.name)
        Path("test-inputs").mkdir()
        self.fixture = Path("test-inputs/bad.yaml")
        self.fixture.write_text("pipeline:\n  stages: []\nimage: bad.registry.io/app:latest\n")

    def tearDown(self):
        os.chdir(self._cwd)
        self.tmp.cleanup()

    def test_harness_fixer_should_not_modify_protected_files(self):
        before = self.fixture.read_text()
        violation = le.Violation("PG-003", "HIGH", str(self.fixture), "unapproved registry")
        with patch.object(le, "get_pr_changed_files", return_value=[]):
            le.HarnessAutoFixer().apply_fix([violation], "main")
        self.assertEqual(self.fixture.read_text(), before)

    def test_pi_fixer_should_not_modify_protected_files(self):
        before = self.fixture.read_text()
        le.PiAutoFixer().apply_fix([le.Violation("PI-007", "HIGH", str(self.fixture), "secret")])
        self.assertEqual(self.fixture.read_text(), before)


class when_severity_is_low_only(unittest.TestCase):
    def test_should_pass_as_advisory(self):
        class LowOnly(le.BaseEvaluator):
            def evaluate(self):
                return le.EvalResult(False, [le.Violation("PG-008", "LOW", "p.yaml", "no description")])

        with patch.object(le.LoopLogger, "log"):
            result = le.LoopEngine("harness", {}, 3).run(LowOnly(), le.HarnessAutoFixer())
        self.assertEqual(result, le.LoopResult.PASS)


class when_checking_rego_syntax(unittest.TestCase):
    def test_should_fail_when_there_are_no_policy_files(self):
        with tempfile.TemporaryDirectory() as empty:
            self.assertFalse(le.RegoSyntaxEvaluator(empty).evaluate().passed)


@unittest.skipUnless(HAS_OPA, "opa binary not available")
class when_evaluating_with_real_opa(InRepoRoot):
    def evaluate(self, doc, query="data.harness.pipeline.guardrails.violation"):
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as tmp:
            json.dump(doc, tmp)
        try:
            return le.OpaEvaluator("policies/opa/pipeline-guardrails.rego", tmp.name, query, "p.yaml").evaluate()
        finally:
            os.unlink(tmp.name)

    def test_should_report_violations_for_a_known_bad_pipeline(self):
        import yaml
        doc = yaml.safe_load(Path("test-inputs/human-pr-test.yaml").read_text())
        result = self.evaluate(le.yaml_to_opa_input(doc))
        self.assertFalse(result.passed)
        self.assertNotIn("OPA-ERROR", {v.rule_id for v in result.violations})

    def test_should_fail_closed_on_a_wrong_package(self):
        result = self.evaluate({"pipeline": {}}, query="data.no.such.package.violation")
        self.assertEqual([v.rule_id for v in result.violations], ["OPA-ERROR"])


if __name__ == "__main__":
    unittest.main()
