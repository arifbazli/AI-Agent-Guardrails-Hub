# ===========================================================================
# Unit Tests — Pi Guardrail Workflow Gate Policies
# Package: pi.guardrails.workflow_test
# Covers:  PI-004, PI-005, PI-010
# Run with: opa test policies/pi/
# ===========================================================================

package pi.guardrails.workflow_test

import data.pi.guardrails.workflow

# ---------------------------------------------------------------------------
# PI-004 — Tests must pass before PR can be opened
# ---------------------------------------------------------------------------

test_pi004_pass_tests_before_pr {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-004"]) == 0
}

test_pi004_violation_pr_before_tests {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-004"]) > 0
}

test_pi004_violation_tests_failed {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "fail", "tests_passed": false, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-004"]) > 0
}

test_pi004_violation_no_test_step {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:00:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-004"]) > 0
}

# ---------------------------------------------------------------------------
# PI-005 — Human approval gate must be completed before PR is opened
# ---------------------------------------------------------------------------

test_pi005_pass_approval_completed {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-005"]) == 0
}

test_pi005_violation_approval_not_completed {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": false,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-005"]) > 0
}

test_pi005_violation_approval_missing {
    result := workflow.violation with input as {
        "pi_agent": {
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-005"]) > 0
}

# ---------------------------------------------------------------------------
# PI-010 — All Pi agent workflow steps must be logged
# ---------------------------------------------------------------------------

test_pi010_pass_all_fields_present {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-010"]) == 0
}

test_pi010_violation_missing_timestamp {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-010"]) > 0
}

test_pi010_violation_missing_outcome {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-010"]) > 0
}

test_pi010_violation_missing_action {
    result := workflow.violation with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
    count([v | v := result[_]; v.rule == "PI-010"]) > 0
}

# ---------------------------------------------------------------------------
# ALLOW
# ---------------------------------------------------------------------------

test_allow_passes_fully_compliant_workflow {
    workflow.allow with input as {
        "pi_agent": {
            "human_approval_completed": true,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
}

test_allow_fails_no_human_approval {
    not workflow.allow with input as {
        "pi_agent": {
            "human_approval_completed": false,
            "workflow_steps": [
                {"action": "pytest", "outcome": "pass", "tests_passed": true, "timestamp": "2026-06-08T07:00:00Z"},
                {"action": "gh pr create", "outcome": "pass", "timestamp": "2026-06-08T07:01:00Z"},
            ],
        },
    }
}
