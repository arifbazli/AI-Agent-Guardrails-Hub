# ============================================================
# Pi Guardrail — Bash Security Policies
# Package: pi.guardrails.bash
# Version: 1.0.0
# Last Updated: 2026-06-08
#
# Enforces bash security levels and command whitelist controls
# for Pi coding agent (pi.dev) workflows. Pi agents must operate
# at security level L4 (whitelist) or L5 (no bash) minimum.
# ============================================================

package pi.guardrails.bash

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
# APPROVED BASH COMMAND WHITELIST
# ---------------------------------------------------------------------------

approved_bash_commands := {
    "pytest",
    "pip install",
    "git add",
    "git commit",
    "git push",
    "gh pr create",
    "echo",
    "cat",
    "ls",
    "mkdir",
    "cp",
    "mv",
}

blocked_bash_patterns := [
    `(?i)^rm\s+-rf`,
    `(?i)^curl\b`,
    `(?i)^wget\b`,
    `(?i)chmod\s+777`,
    `(?i)^sudo\b`,
    `(?i)\beval\b`,
    `(?i)\bexec\b`,
    `(?i)os\.system\s*\(`,
    `(?i)subprocess\.run\s*\(.*shell\s*=\s*True`,
]

# ---------------------------------------------------------------------------
# RULE: PI-001 — Pi agent bash security level must be L4 or L5 minimum
# Severity: CRITICAL
# Pi agents must be configured with bash security level L4 (whitelist only)
# or L5 (no bash access). Levels L1, L2, and L3 are never permitted.
# ---------------------------------------------------------------------------

violation contains msg if {
    level := input.pi_agent.bash_security_level
    not level in {"L4", "L5"}
    msg := {
        "rule":     "PI-001",
        "severity": "CRITICAL",
        "level":    level,
        "issue":    sprintf("Pi agent bash security level is '%v'. Minimum required is L4 (whitelist) or L5 (no bash).", [level]),
        "fix":      "Set the Pi agent bash security level to L4 (whitelist only) or L5 (no bash access) in the Pi agent configuration.",
        "docs":     "docs/violation-remediation.md#pi-001",
    }
}

# ---------------------------------------------------------------------------
# RULE: PI-002 — No unrestricted bash tool access (L1/L2/L3)
# Severity: CRITICAL
# Bash levels L1 (user prompt), L2 (system prompt), and L3 (LLM-filtered)
# all allow unrestricted command execution and are strictly prohibited.
# ---------------------------------------------------------------------------

violation contains msg if {
    level := input.pi_agent.bash_security_level
    level in {"L1", "L2", "L3"}
    msg := {
        "rule":     "PI-002",
        "severity": "CRITICAL",
        "level":    level,
        "issue":    sprintf("Pi agent is running with unrestricted bash access at level '%v'. Levels L1, L2, and L3 are prohibited.", [level]),
        "fix":      "Immediately reconfigure the Pi agent to L4 (whitelist) or L5 (no bash). Remove any pipeline steps that rely on unrestricted bash execution.",
        "docs":     "docs/violation-remediation.md#pi-002",
    }
}

# ---------------------------------------------------------------------------
# RULE: PI-003 — Bash commands must match approved whitelist only
# Severity: HIGH
# All bash commands executed by the Pi agent must be drawn exclusively
# from the organisation-approved command whitelist. Blocked commands
# must never be invoked regardless of security level.
# ---------------------------------------------------------------------------

violation contains msg if {
    cmd := input.pi_agent.bash_commands[_]
    not command_is_approved(cmd)
    msg := {
        "rule":     "PI-003",
        "severity": "HIGH",
        "command":  cmd,
        "issue":    sprintf("Pi agent bash command '%v' is not on the approved whitelist.", [cmd]),
        "fix":      "Remove the command from the Pi agent workflow. Only the following commands are permitted: pytest, pip install, git add, git commit, git push, gh pr create, echo, cat, ls, mkdir, cp, mv.",
        "docs":     "docs/violation-remediation.md#pi-003",
    }
}

violation contains msg if {
    cmd := input.pi_agent.bash_commands[_]
    command_is_blocked(cmd)
    msg := {
        "rule":     "PI-003",
        "severity": "HIGH",
        "command":  cmd,
        "issue":    sprintf("Pi agent bash command '%v' matches a blocked pattern (rm -rf, curl, wget, chmod 777, sudo, eval, exec, os.system, subprocess.run with shell=True).", [cmd]),
        "fix":      "Remove the blocked command immediately. Replace destructive file operations with safe alternatives. Use Harness Secret Manager for credentials rather than curl/wget.",
        "docs":     "docs/violation-remediation.md#pi-003",
    }
}

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

command_is_approved(cmd) if {
    approved := approved_bash_commands[_]
    cmd == approved
}

command_is_approved(cmd) if {
    approved := approved_bash_commands[_]
    startswith(cmd, concat("", [approved, " "]))
}

command_is_blocked(cmd) if {
    pattern := blocked_bash_patterns[_]
    regex.match(pattern, cmd)
}

# ---------------------------------------------------------------------------
# ALLOW — All bash security checks pass when no violations exist
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
        "PI-001: Pi agent bash security level must be L4 or L5 minimum",
        "PI-002: No unrestricted bash tool access (L1/L2/L3)",
        "PI-003: Bash commands must match approved whitelist only",
    ],
}
