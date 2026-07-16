# ============================================================
# Pi Guardrail — Workflow Gate Policies
# Package: pi.guardrails.workflow
# Version: 1.0.0
# Last Updated: 2026-06-08
#
# Enforces workflow ordering gates, human approval requirements,
# and audit logging for Pi coding agent (pi.dev) workflows.
# Tests must pass before a PR can be opened, and a human approval
# gate must be completed before any automated PR submission.
# ============================================================

package pi.guardrails.workflow

import future.keywords.if
import future.keywords.in
import future.keywords.contains
import future.keywords.every

# ---------------------------------------------------------------------------
# DEFAULTS
# ---------------------------------------------------------------------------

default allow = false
default violation_count = 0

# ---------------------------------------------------------------------------
# REQUIRED LOG FIELDS
# ---------------------------------------------------------------------------

required_log_fields := {"timestamp", "action", "outcome"}

# ---------------------------------------------------------------------------
# RULE: PI-004 — Tests must pass before PR can be opened
# Severity: HIGH
# The Pi agent workflow must execute and pass all tests (exit code 0)
# before the gh pr create step is permitted. Opening a PR without
# a passing test run is a workflow gate violation.
# ---------------------------------------------------------------------------

violation contains msg if {
    not tests_completed_before_pr
    msg := {
        "rule":     "PI-004",
        "severity": "HIGH",
        "issue":    "Pi agent workflow attempted to open a PR before tests were executed and passed. Tests must run and exit with code 0 before any PR can be opened.",
        "fix":      "Reorder the Pi agent workflow steps so that 'pytest' (or equivalent test runner) runs and passes before 'gh pr create'. Do not proceed to PR creation if the test step fails.",
        "docs":     "docs/violation-remediation.md#pi-004",
    }
}

tests_completed_before_pr if {
    steps := input.pi_agent.workflow_steps
    test_indices  := [i | steps[i].action == "pytest"]
    pr_indices    := [i | steps[i].action == "gh pr create"]
    count(test_indices) > 0
    count(pr_indices) > 0
    last_test_index := max(test_indices)
    first_pr_index  := min(pr_indices)
    last_test_index < first_pr_index
    steps[last_test_index].outcome == "pass"
    steps[last_test_index].tests_passed == true
}

get_step_index(steps, action) := index if {
    some index
    steps[index].action == action
}

# ---------------------------------------------------------------------------
# RULE: PI-005 — Human approval gate must be completed before PR is opened
# Severity: HIGH
# No Pi agent may open a PR automatically without a human having reviewed
# and approved the proposed changes. The human_approval_completed flag
# must be true before the PR creation step executes.
# ---------------------------------------------------------------------------

violation contains msg if {
    not input.pi_agent.human_approval_completed
    msg := {
        "rule":     "PI-005",
        "severity": "HIGH",
        "issue":    "Pi agent attempted to open a PR without a completed human approval gate. Human review and sign-off is mandatory before any automated PR submission.",
        "fix":      "Add a human approval step to the Pi agent workflow before 'gh pr create'. The approving human must explicitly mark the review as complete (human_approval_completed: true) before the PR gate will open.",
        "docs":     "docs/violation-remediation.md#pi-005",
    }
}

# ---------------------------------------------------------------------------
# RULE: PI-010 — All Pi agent workflow steps must be logged
# Severity: LOW
# Every Pi agent workflow step must emit a structured log entry containing
# at minimum: timestamp, action, and outcome. Missing or incomplete log
# entries break the audit trail.
# ---------------------------------------------------------------------------

violation contains msg if {
    step := input.pi_agent.workflow_steps[_]
    field := required_log_fields[_]
    not step[field]
    step_action := object.get(step, "action", "unknown")
    msg := {
        "rule":     "PI-010",
        "severity": "LOW",
        "step":     step_action,
        "field":    field,
        "issue":    sprintf("Pi agent workflow step '%v' is missing required log field '%v'. All steps must log timestamp, action, and outcome.", [step_action, field]),
        "fix":      "Update the Pi agent workflow configuration to emit structured log entries for every step. Each entry must include: timestamp (ISO 8601), action (step name), and outcome (pass/fail).",
        "docs":     "docs/violation-remediation.md#pi-010",
    }
}

# ---------------------------------------------------------------------------
# ALLOW — All workflow gates pass when no violations exist
# ---------------------------------------------------------------------------

allow if {
    count(violation) == 0
}

violation_count := count(violation)

# ---------------------------------------------------------------------------
# SUMMARY — Aggregated compliance report
# ---------------------------------------------------------------------------

summary := {
    "allow":           allow,
    "violation_count": violation_count,
    "violations":      violation,
    "policies_evaluated": [
        "PI-004: Tests must pass (exit code 0) before PR can be opened",
        "PI-005: Human approval gate must be completed before PR is opened",
        "PI-010: All Pi agent workflow steps must be logged with timestamp, action, and outcome",
    ],
}
