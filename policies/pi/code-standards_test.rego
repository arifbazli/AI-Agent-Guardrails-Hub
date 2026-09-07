# ===========================================================================
# Unit Tests — Pi Guardrail Code Standards Policies
# Package: pi.guardrails.code_test
# Covers:  PI-006, PI-007, PI-008, PI-009
# Run with: opa test policies/pi/
# ===========================================================================

package pi.guardrails.code_test

import data.pi.guardrails.code

# ---------------------------------------------------------------------------
# PI-006 — Pi-generated code must pass linting
# ---------------------------------------------------------------------------

test_pi006_pass_lint_status_pass {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "app.py", "lint_status": "pass", "lint_errors": [], "content": "", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-006"]) == 0
}

test_pi006_violation_lint_status_fail {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "app.py", "lint_status": "fail", "lint_errors": [], "content": "", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-006"]) > 0
}

test_pi006_violation_syntax_error_in_lint_errors {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "app.py", "lint_status": "pass", "lint_errors": ["SyntaxError: invalid syntax"], "content": "", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-006"]) > 0
}

# ---------------------------------------------------------------------------
# PI-007 — No hardcoded secrets, API keys, passwords, or tokens
# ---------------------------------------------------------------------------

test_pi007_pass_clean_content {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "app.py", "lint_status": "pass", "lint_errors": [], "content": "def hello():\n    return 'world'", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-007"]) == 0
}

test_pi007_violation_hardcoded_api_key {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "config.py", "lint_status": "pass", "lint_errors": [], "content": "api_key = 'sk-abcXYZ1234567890longkey'", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-007"]) > 0
}

test_pi007_violation_hardcoded_password {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{"path": "config.py", "lint_status": "pass", "lint_errors": [], "content": "password = 'mysupersecret'", "functions": [], "tests": []}],
    }
    count([v | v := result[_]; v.rule == "PI-007"]) > 0
}

# ---------------------------------------------------------------------------
# PI-008 — Pi-generated code must include at minimum one unit test per function
# ---------------------------------------------------------------------------

test_pi008_pass_function_has_test {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{
            "path": "utils.py",
            "lint_status": "pass",
            "lint_errors": [],
            "content": "",
            "functions": [{"name": "add"}],
            "tests": [{"name": "test_add"}],
        }],
    }
    count([v | v := result[_]; v.rule == "PI-008"]) == 0
}

test_pi008_violation_function_no_test {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{
            "path": "utils.py",
            "lint_status": "pass",
            "lint_errors": [],
            "content": "",
            "functions": [{"name": "calculate_total"}],
            "tests": [],
        }],
    }
    count([v | v := result[_]; v.rule == "PI-008"]) > 0
}

test_pi008_no_false_positive_partial_name_match {
    # 'add' should NOT match 'test_add_user' — requires exact function name boundary
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{
            "path": "utils.py",
            "lint_status": "pass",
            "lint_errors": [],
            "content": "",
            "functions": [{"name": "add"}],
            "tests": [{"name": "test_add_user"}],
        }],
    }
    # test_add_user does not match test_add exactly — violation expected
    count([v | v := result[_]; v.rule == "PI-008"]) > 0
}

# ---------------------------------------------------------------------------
# PI-009 — Approved Pi agent versions only
# ---------------------------------------------------------------------------

test_pi009_pass_approved_version {
    result := code.violation with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [],
    }
    count([v | v := result[_]; v.rule == "PI-009"]) == 0
}

test_pi009_pass_another_approved_version {
    result := code.violation with input as {
        "pi_agent": {"version": "1.0.0"},
        "files": [],
    }
    count([v | v := result[_]; v.rule == "PI-009"]) == 0
}

test_pi009_violation_unapproved_version {
    result := code.violation with input as {
        "pi_agent": {"version": "3.0.0-beta"},
        "files": [],
    }
    count([v | v := result[_]; v.rule == "PI-009"]) > 0
}

test_pi009_violation_unknown_version {
    result := code.violation with input as {
        "pi_agent": {"version": "99.99.99"},
        "files": [],
    }
    count([v | v := result[_]; v.rule == "PI-009"]) > 0
}

test_pi009_violation_missing_version_field {
    # version := input.pi_agent.version previously went undefined (no
    # violation) when the field was absent entirely — must fail closed.
    result := code.violation with input as {
        "pi_agent": {},
        "files": [],
    }
    count([v | v := result[_]; v.rule == "PI-009"]) > 0
}

test_pi009_violation_empty_input {
    result := code.violation with input as {"files": []}
    count([v | v := result[_]; v.rule == "PI-009"]) > 0
}

# ---------------------------------------------------------------------------
# ALLOW
# ---------------------------------------------------------------------------

test_allow_passes_clean_input {
    code.allow with input as {
        "pi_agent": {"version": "2.1.0"},
        "files": [{
            "path": "app.py",
            "lint_status": "pass",
            "lint_errors": [],
            "content": "def hello():\n    return 'world'",
            "functions": [{"name": "hello"}],
            "tests": [{"name": "test_hello"}],
        }],
    }
}
