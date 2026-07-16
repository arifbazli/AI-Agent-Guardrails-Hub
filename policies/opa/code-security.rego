# ============================================================
# Code Security Policies
# Package: harness.code.security
# Version: 1.0.0
# Last Updated: 2026-06-05
#
# Enforces code security guardrails including secret detection,
# branch protection, SAST scanning, and coding hygiene rules
# for all repositories connected to Harness pipelines.
# ============================================================

package harness.code.security

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
# RULE: CS-001 — No hardcoded API keys or tokens in code
# Severity: CRITICAL
# Source files must not contain hardcoded API keys, tokens, or similar
# credentials. All secrets must be referenced via a secrets manager.
# ---------------------------------------------------------------------------

api_key_patterns := [
    `(?i)(api[_-]?key|apikey)\s*[:=]\s*["']?[A-Za-z0-9+/]{16,}["']?`,
    `(?i)(access[_-]?token|auth[_-]?token)\s*[:=]\s*["']?[A-Za-z0-9+/._\-]{20,}["']?`,
    `(?i)Bearer\s+[A-Za-z0-9\-._~+/]+=*`,
    `(?i)(AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}`,
]

violation contains msg if {
    file := input.files[_]
    pattern := api_key_patterns[_]
    regex.match(pattern, file.content)
    msg := {
        "rule":     "CS-001",
        "severity": "CRITICAL",
        "file":     file.path,
        "issue":    sprintf("File '%v' appears to contain a hardcoded API key or token.", [file.path]),
        "fix":      "Remove the hardcoded credential and replace it with a reference to Harness Secret Manager: <+secrets.getValue(\"secret-name\")>.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-002 — No hardcoded passwords or credentials
# Severity: CRITICAL
# Source files must not contain hardcoded passwords or credential literals.
# ---------------------------------------------------------------------------

password_patterns := [
    `(?i)(password|passwd|pwd)\s*[:=]\s*["'][^"']{4,}["']`,
    `(?i)(db[_-]?pass|database[_-]?password)\s*[:=]\s*["'][^"']{4,}["']`,
    `(?i)(secret[_-]?key|client[_-]?secret)\s*[:=]\s*["'][^"']{8,}["']`,
    `(?i)(private[_-]?key)\s*[:=]\s*["']-----BEGIN`,
]

violation contains msg if {
    file := input.files[_]
    pattern := password_patterns[_]
    regex.match(pattern, file.content)
    msg := {
        "rule":     "CS-002",
        "severity": "CRITICAL",
        "file":     file.path,
        "issue":    sprintf("File '%v' appears to contain a hardcoded password or credential.", [file.path]),
        "fix":      "Remove the hardcoded credential and store it in a secure secrets manager. Reference via environment variable or Harness secret expression.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-003 — No use of deprecated or insecure functions
# Severity: HIGH
# Code must not call known deprecated or cryptographically insecure
# functions such as MD5, SHA1 (for security), eval(), or exec().
# ---------------------------------------------------------------------------

insecure_function_patterns := [
    `(?i)\beval\s*\(`,
    `(?i)\bexec\s*\(`,
    `(?i)\bSystem\.exit\s*\(`,
    `(?i)\bMD5\s*\(`,
    `(?i)\bSHA1\s*\(`,
    `(?i)\bDES\s*\(`,
    `(?i)\bRC4\s*\(`,
    `(?i)\bpickle\.loads?\s*\(`,
    `(?i)\bdeserialize\s*\(`,
]

violation contains msg if {
    file := input.files[_]
    pattern := insecure_function_patterns[_]
    regex.match(pattern, file.content)
    msg := {
        "rule":     "CS-003",
        "severity": "HIGH",
        "file":     file.path,
        "issue":    sprintf("File '%v' contains a call to a deprecated or insecure function.", [file.path]),
        "fix":      "Replace deprecated or insecure functions with approved equivalents (e.g. use SHA-256 instead of MD5/SHA1, avoid eval/exec, use safe deserialisation).",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-004 — No direct commits to main/master branch
# Severity: HIGH
# Changes must not be pushed directly to main or master. All changes
# must go through a pull request and code review process.
# ---------------------------------------------------------------------------

violation contains msg if {
    input.commit.branch == "main"
    not input.commit.is_merge_commit
    msg := {
        "rule":     "CS-004",
        "severity": "HIGH",
        "branch":   input.commit.branch,
        "issue":    "Direct commit to 'main' branch detected (non-merge commit).",
        "fix":      "Create a feature branch, raise a pull request, and merge via the standard review process. Direct pushes to 'main' are prohibited.",
    }
}

violation contains msg if {
    input.commit.branch == "master"
    not input.commit.is_merge_commit
    msg := {
        "rule":     "CS-004",
        "severity": "HIGH",
        "branch":   input.commit.branch,
        "issue":    "Direct commit to 'master' branch detected (non-merge commit).",
        "fix":      "Create a feature branch, raise a pull request, and merge via the standard review process. Direct pushes to 'master' are prohibited.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-005 — Branch protection rules must be enabled
# Severity: HIGH
# The default branch must have protection rules that require pull
# request reviews and status checks before merging.
# ---------------------------------------------------------------------------

violation contains msg if {
    repo := input.repository
    not repo.branch_protection.enabled
    msg := {
        "rule":     "CS-005",
        "severity": "HIGH",
        "repo":     repo.name,
        "issue":    sprintf("Repository '%v' does not have branch protection rules enabled on the default branch.", [repo.name]),
        "fix":      "Enable branch protection rules for the default branch: require pull request reviews, require status checks to pass, and disallow force pushes.",
    }
}

violation contains msg if {
    repo := input.repository
    repo.branch_protection.enabled
    not repo.branch_protection.require_pull_request_reviews
    msg := {
        "rule":     "CS-005",
        "severity": "HIGH",
        "repo":     repo.name,
        "issue":    sprintf("Repository '%v' branch protection does not require pull request reviews.", [repo.name]),
        "fix":      "Update branch protection rules to require at least one approving review before merging.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-006 — Code must pass SAST scan before merge
# Severity: MEDIUM
# All pull requests must have a successful Static Application Security
# Testing (SAST) scan result before they can be merged.
# ---------------------------------------------------------------------------

violation contains msg if {
    pr := input.pull_request
    not pr.checks.sast.passed
    msg := {
        "rule":     "CS-006",
        "severity": "MEDIUM",
        "pr":       pr.number,
        "issue":    sprintf("Pull request #%v has not passed the required SAST security scan.", [pr.number]),
        "fix":      "Ensure the SAST pipeline check completes successfully. Review and remediate any findings reported by the scanner before merging.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-007 — No sensitive data in environment variables
# Severity: MEDIUM
# Environment variable values defined in pipeline or application config
# must not contain sensitive data in plaintext.
# ---------------------------------------------------------------------------

sensitive_env_key_patterns := [
    "(?i)(password|passwd|pwd)",
    "(?i)(secret|token|api[_-]?key)",
    "(?i)(private[_-]?key|client[_-]?secret)",
    "(?i)(auth|credential|certificate)",
    "(?i)(connection[_-]?string|db[_-]?url)",
]

violation contains msg if {
    env_var := input.environment.variables[key]
    pattern := sensitive_env_key_patterns[_]
    regex.match(pattern, key)
    not startswith(env_var, "<+secrets")
    not startswith(env_var, "${{")
    not startswith(env_var, "$(")
    msg := {
        "rule":     "CS-007",
        "severity": "MEDIUM",
        "key":      key,
        "issue":    sprintf("Environment variable '%v' appears to hold sensitive data as a plaintext value.", [key]),
        "fix":      "Replace the plaintext value with a secrets manager reference (e.g. Harness: <+secrets.getValue(\"name\")>).",
    }
}

# ---------------------------------------------------------------------------
# RULE: CS-008 — Code files must have license headers
# Severity: LOW
# All source code files must include the organisation license header
# as the first comment block in the file.
# ---------------------------------------------------------------------------

license_header_pattern := `(?i)(copyright|spdx-license-identifier|licensed under)`

violation contains msg if {
    file := input.files[_]
    is_source_file(file.path)
    not regex.match(license_header_pattern, file.content)
    msg := {
        "rule":     "CS-008",
        "severity": "LOW",
        "file":     file.path,
        "issue":    sprintf("Source file '%v' is missing the required license header.", [file.path]),
        "fix":      "Add the organisation-approved license header comment block to the top of the file (e.g. SPDX-License-Identifier or Copyright notice).",
    }
}

source_extensions := {".go", ".py", ".js", ".ts", ".java", ".cs", ".cpp", ".c", ".rb", ".sh"}

is_source_file(path) if {
    ext := source_extensions[_]
    endswith(path, ext)
}

# ---------------------------------------------------------------------------
# RULE: CS-009 — No debug or test code left in production files
# Severity: LOW
# Production source files must not contain debug statements, TODO/FIXME
# markers, or test-only code blocks that were not cleaned up.
# ---------------------------------------------------------------------------

debug_patterns := [
    `(?i)\bconsole\.log\s*\(`,
    `(?i)\bprint\s*\(\s*["']debug`,
    `(?i)\bdebugger\b`,
    `(?i)#\s*TODO\b`,
    `(?i)#\s*FIXME\b`,
    `(?i)//\s*TODO\b`,
    `(?i)//\s*FIXME\b`,
    `(?i)/\*\s*TODO\b`,
    `(?i)\bpdb\.set_trace\s*\(`,
    `(?i)\bipdb\.set_trace\s*\(`,
]

violation contains msg if {
    file := input.files[_]
    is_source_file(file.path)
    pattern := debug_patterns[_]
    regex.match(pattern, file.content)
    msg := {
        "rule":     "CS-009",
        "severity": "LOW",
        "file":     file.path,
        "issue":    sprintf("Production file '%v' contains debug statements, TODO/FIXME markers, or leftover test code.", [file.path]),
        "fix":      "Remove all debug statements (e.g. console.log, debugger, pdb.set_trace) and resolve or track TODO/FIXME comments before merging to the default branch.",
    }
}

# ---------------------------------------------------------------------------
# ALLOW — All code security checks pass when no violations exist
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
        "CS-001: No hardcoded API keys or tokens in code",
        "CS-002: No hardcoded passwords or credentials",
        "CS-003: No use of deprecated or insecure functions",
        "CS-004: No direct commits to main/master branch",
        "CS-005: Branch protection rules must be enabled",
        "CS-006: Code must pass SAST scan before merge",
        "CS-007: No sensitive data in environment variables",
        "CS-008: Code files must have license headers",
        "CS-009: No debug or test code left in production files",
    ],
}
