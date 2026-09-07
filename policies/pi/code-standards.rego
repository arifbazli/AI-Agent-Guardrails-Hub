# ============================================================
# Pi Guardrail — Code Standards Policies
# Package: pi.guardrails.code
# Version: 1.0.0
# Last Updated: 2026-06-08
#
# Enforces code quality, secret detection, test coverage, and
# Pi agent version compliance for all Pi-generated code submitted
# via Pi coding agent (pi.dev) workflows.
# ============================================================

package pi.guardrails.code

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
# CONFIGURATION
# ---------------------------------------------------------------------------

approved_pi_versions := {
    "1.0.0",
    "1.1.0",
    "1.2.0",
    "2.0.0",
    "2.1.0",
}

secret_patterns := [
    `(?i)(api[_-]?key|apikey)\s*[:=]\s*["']?[A-Za-z0-9+/._\-]{16,}["']?`,
    `(?i)(access[_-]?token|auth[_-]?token)\s*[:=]\s*["']?[A-Za-z0-9+/._\-]{20,}["']?`,
    `(?i)(password|passwd|pwd)\s*[:=]\s*["'][^"']{4,}["']`,
    `(?i)(secret[_-]?key|private[_-]?key)\s*[:=]\s*["']?[A-Za-z0-9+/._\-]{16,}["']?`,
    `(?i)(AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}`,
    `(?i)Bearer\s+[A-Za-z0-9\-._~+/]+=*`,
]

lint_error_patterns := [
    `(?i)SyntaxError`,
    `(?i)IndentationError`,
    `(?i)TabError`,
    `(?i)E[0-9]{3,}`,
]

# ---------------------------------------------------------------------------
# RULE: PI-006 — Pi-generated code must pass linting
# Severity: MEDIUM
# All Pi-generated source files must pass linting with no syntax errors
# and must be PEP8 compliant for Python files.
# ---------------------------------------------------------------------------

violation contains msg if {
    file := input.files[_]
    file.lint_status != "pass"
    msg := {
        "rule":     "PI-006",
        "severity": "MEDIUM",
        "file":     file.path,
        "issue":    sprintf("Pi-generated file '%v' failed linting (status: %v). Fix all syntax errors and PEP8 violations before opening a PR.", [file.path, file.lint_status]),
        "fix":      "Run 'flake8 <file>' and 'pylint <file>' locally. Resolve all reported errors. Ensure no syntax errors or indentation issues remain.",
        "docs":     "docs/violation-remediation.md#pi-006",
    }
}

violation contains msg if {
    file := input.files[_]
    error := file.lint_errors[_]
    pattern := lint_error_patterns[_]
    regex.match(pattern, error)
    msg := {
        "rule":     "PI-006",
        "severity": "MEDIUM",
        "file":     file.path,
        "error":    error,
        "issue":    sprintf("Pi-generated file '%v' contains lint error: %v", [file.path, error]),
        "fix":      "Resolve the reported lint error. For PEP8 violations, run 'autopep8 --in-place <file>' or fix manually.",
        "docs":     "docs/violation-remediation.md#pi-006",
    }
}

# ---------------------------------------------------------------------------
# RULE: PI-007 — No hardcoded secrets, API keys, passwords, or tokens
# Severity: MEDIUM
# Pi-generated code must not contain hardcoded credentials of any kind.
# All secrets must be injected via environment variables or a secrets manager.
# ---------------------------------------------------------------------------

violation contains msg if {
    file := input.files[_]
    pattern := secret_patterns[_]
    regex.match(pattern, file.content)
    msg := {
        "rule":     "PI-007",
        "severity": "MEDIUM",
        "file":     file.path,
        "issue":    sprintf("Pi-generated file '%v' appears to contain a hardcoded secret, API key, password, or token.", [file.path]),
        "fix":      "Remove the hardcoded credential immediately. Rotate the exposed secret in the external system. Store secrets in Harness Secret Manager and reference them via environment variables or <+secrets.getValue(\"name\")>.",
        "docs":     "docs/violation-remediation.md#pi-007",
    }
}

# ---------------------------------------------------------------------------
# RULE: PI-008 — Pi-generated code must include at minimum one unit test
#               per function
# Severity: MEDIUM
# Every function defined in Pi-generated code must have at least one
# corresponding unit test to ensure basic coverage.
# ---------------------------------------------------------------------------

violation contains msg if {
    file := input.files[_]
    function := file.functions[_]
    not function_has_test(function, file)
    msg := {
        "rule":     "PI-008",
        "severity": "MEDIUM",
        "file":     file.path,
        "function": function.name,
        "issue":    sprintf("Pi-generated function '%v' in '%v' has no corresponding unit test.", [function.name, file.path]),
        "fix":      "Add at least one unit test for the function. Create a test file named 'test_<module>.py' and add a test case that exercises the function's primary logic path.",
        "docs":     "docs/violation-remediation.md#pi-008",
    }
}

function_has_test(function, file) if {
    test := file.tests[_]
    regex.match(sprintf("^test_%v$", [function.name]), test.name)
}

function_has_test(function, _) if {
    test_file := input.files[_]
    startswith(test_file.path, "test_")
    test := test_file.tests[_]
    regex.match(sprintf("^test_%v$", [function.name]), test.name)
}

# ---------------------------------------------------------------------------
# RULE: PI-009 — Approved Pi agent versions only
# Severity: MEDIUM
# The Pi agent version must be on the organisation-approved list.
# Unapproved versions may contain unvetted capabilities or security flaws.
# ---------------------------------------------------------------------------

violation contains msg if {
    version := object.get(input, ["pi_agent", "version"], "MISSING")
    not version in approved_pi_versions
    msg := {
        "rule":     "PI-009",
        "severity": "MEDIUM",
        "version":  version,
        "issue":    sprintf("Pi agent version '%v' is not on the organisation-approved versions list.", [version]),
        "fix":      "Upgrade or downgrade to an approved Pi agent version. Contact the platform team to request approval for a new version. Approved versions: 1.0.0, 1.1.0, 1.2.0, 2.0.0, 2.1.0.",
        "docs":     "docs/violation-remediation.md#pi-009",
    }
}

# ---------------------------------------------------------------------------
# ALLOW — All code standards pass when no violations exist
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
        "PI-006: Pi-generated code must pass linting (no syntax errors, PEP8 compliant for Python)",
        "PI-007: No hardcoded secrets, API keys, passwords, or tokens in generated code",
        "PI-008: Pi-generated code must include at minimum one unit test per function",
        "PI-009: Approved Pi agent versions only",
    ],
}
