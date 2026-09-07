# ============================================================
# Delegate Validation Policies
# Package: harness.delegate.validation
# Version: 1.0.0
# Last Updated: 2026-06-05
#
# Enforces validation guardrails for all Harness delegates
# including connectivity, versioning, security posture,
# resource limits, scope assignment, and tagging compliance.
# ============================================================

package harness.delegate.validation

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
# RULE: DV-001 — Delegates must be active and connected
# Severity: CRITICAL
# Only delegates that are in an ENABLED and CONNECTED state may be
# used to execute pipeline stages. Disconnected delegates must not
# be targeted by delegate selectors.
# ---------------------------------------------------------------------------

violation contains msg if {
    delegate := input.delegates[_]
    delegate.status != "ENABLED"
    msg := {
        "rule":     "DV-001",
        "severity": "CRITICAL",
        "delegate": delegate.name,
        "status":   delegate.status,
        "issue":    sprintf("Delegate '%v' is not in ENABLED state (current: %v).", [delegate.name, delegate.status]),
        "fix":      "Investigate why the delegate is not enabled. Restart the delegate process, check connectivity to the Harness Manager, and verify the delegate token is valid.",
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    delegate.status == "ENABLED"
    not delegate.connected
    msg := {
        "rule":     "DV-001",
        "severity": "CRITICAL",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is ENABLED but not connected to Harness Manager.", [delegate.name]),
        "fix":      "Check delegate network connectivity and firewall rules. Ensure the delegate can reach app.harness.io on port 443. Review delegate logs for connection errors.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-002 — Delegates must run approved versions only
# Severity: CRITICAL
# All delegates must run a version that appears on the organisation's
# approved version list. Delegates running unapproved or end-of-life
# versions must be upgraded before use.
# ---------------------------------------------------------------------------

violation contains msg if {
    delegate := input.delegates[_]
    not delegate_version(delegate) in input.policy.approved_delegate_versions
    msg := {
        "rule":     "DV-002",
        "severity": "CRITICAL",
        "delegate": delegate.name,
        "version":  delegate_version(delegate),
        "issue":    sprintf("Delegate '%v' is running a non-approved version: '%v'.", [delegate.name, delegate_version(delegate)]),
        "fix":      "Upgrade the delegate to an approved version listed in the Harness upgrade guide. Update the delegate YAML or Helm chart, then redeploy.",
    }
}

delegate_version(delegate) := delegate.spec.version if {
    delegate.spec.version
} else := delegate.version if {
    delegate.version
} else := "UNKNOWN"

# ---------------------------------------------------------------------------
# RULE: DV-003 — Delegates must carry org-approved tag
# Severity: HIGH
# Every delegate must have the 'org-approved' tag to confirm it has
# passed the organisation's baseline security and configuration review.
# ---------------------------------------------------------------------------

violation contains msg if {
    delegate := input.delegates[_]
    # NOTE: 'org-approved' must be an exact bare key — key:value format
    # (e.g. 'org-approved:2026') is intentionally not accepted here.
    not "org-approved" in delegate.tags
    msg := {
        "rule":     "DV-003",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is missing the required 'org-approved' tag.", [delegate.name]),
        "fix":      "Complete the delegate onboarding checklist and add the 'org-approved' tag once the delegate has passed the baseline security review.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-004 — Delegates must not run as root user
# Severity: HIGH
# Delegate containers and processes must not run as the root user (UID 0)
# to limit the blast radius of any container escape or exploit.
# ---------------------------------------------------------------------------

violation contains msg if {
    delegate := input.delegates[_]
    delegate.security_context.run_as_user == 0
    msg := {
        "rule":     "DV-004",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is configured to run as root (UID 0).", [delegate.name]),
        "fix":      "Set a non-root UID (e.g. 1000) in the delegate pod/container security context. Update the delegate Helm values or YAML spec accordingly.",
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    delegate.spec.runAsRoot == true
    msg := {
        "rule":     "DV-004",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is configured to run as root (runAsRoot: true).", [delegate.name]),
        "fix":      "Set 'runAsRoot: false' in the delegate spec. Update the delegate Helm values or YAML spec accordingly.",
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    object.get(delegate, "security_context", "MISSING") == "MISSING"
    object.get(object.get(delegate, "spec", {}), "runAsRoot", "MISSING") == "MISSING"
    msg := {
        "rule":     "DV-004",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' declares neither security_context nor spec.runAsRoot, so root/non-root status cannot be verified.", [delegate.name]),
        "fix":      "Explicitly set security_context.run_as_user (non-zero) or spec.runAsRoot: false so root-user compliance can be verified.",
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    delegate.security_context.privileged == true
    msg := {
        "rule":     "DV-004",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is running in privileged mode.", [delegate.name]),
        "fix":      "Set 'privileged: false' in the delegate container security context. Identify and replace any capabilities that require privileged mode with specific Linux capabilities.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-005 — Delegate must have resource limits defined
# Severity: HIGH
# Delegates running as containers must define CPU and memory resource
# limits to prevent noisy-neighbour issues and infrastructure saturation.
# ---------------------------------------------------------------------------

violation contains msg if {
    delegate := input.delegates[_]
    not delegate.resources.limits.cpu
    msg := {
        "rule":     "DV-005",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' does not define a CPU resource limit.", [delegate.name]),
        "fix":      "Add a 'cpu' limit to the delegate container resources spec (e.g. cpu: '1'). Refer to the delegate sizing guide for recommended values.",
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    not delegate.resources.limits.memory
    msg := {
        "rule":     "DV-005",
        "severity": "HIGH",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' does not define a memory resource limit.", [delegate.name]),
        "fix":      "Add a 'memory' limit to the delegate container resources spec (e.g. memory: '2Gi'). Refer to the delegate sizing guide for recommended values.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-006 — Delegates must be assigned to correct scope
# Severity: MEDIUM
# Each delegate must be scoped to either an organisation or a project.
# Delegates with no scope assignment should not be used in pipelines
# as they could be accessed by unintended projects.
# ---------------------------------------------------------------------------

valid_scopes := {"ACCOUNT", "ORG", "PROJECT"}

violation contains msg if {
    delegate := input.delegates[_]
    scope_type := object.get(delegate, ["scope", "type"], "MISSING")
    not scope_type in valid_scopes
    msg := {
        "rule":     "DV-006",
        "severity": "MEDIUM",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' does not have a valid scope assignment (current: '%v').", [delegate.name, scope_type]),
        "fix":      sprintf("Assign the delegate to a valid scope: one of %v. Update the delegate configuration and redeploy.", [valid_scopes]),
    }
}

violation contains msg if {
    delegate := input.delegates[_]
    delegate.scope.type == "PROJECT"
    not delegate.scope.project_identifier
    msg := {
        "rule":     "DV-006",
        "severity": "MEDIUM",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate '%v' is scoped to PROJECT but no project_identifier is set.", [delegate.name]),
        "fix":      "Specify the 'project_identifier' in the delegate scope configuration to restrict the delegate to the intended project.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-007 — Delegate names must follow naming convention
# Severity: MEDIUM
# Delegate names must follow the pattern:
# <environment>-<region>-delegate-<index>
# using lowercase letters, digits, and hyphens only
# (e.g. prod-eu-west-delegate-01, dev-us-east-delegate-02).
# ---------------------------------------------------------------------------

delegate_name_pattern := `^[a-z][a-z0-9]*(-[a-z0-9]+)*-delegate-[0-9]{2,}$`

violation contains msg if {
    delegate := input.delegates[_]
    not regex.match(delegate_name_pattern, delegate.name)
    msg := {
        "rule":     "DV-007",
        "severity": "MEDIUM",
        "delegate": delegate.name,
        "issue":    sprintf("Delegate name '%v' does not follow the naming convention <env>-<region>-delegate-<index>.", [delegate.name]),
        "fix":      "Rename the delegate following the pattern: <environment>-<region>-delegate-<nn> (e.g. 'prod-eu-west-delegate-01'). Update all pipeline delegate selectors that reference this delegate.",
    }
}

# ---------------------------------------------------------------------------
# RULE: DV-008 — Delegates must have owner and cost-centre tags
# Severity: LOW
# All delegates must carry 'owner' and 'cost-centre' tags for
# resource attribution, billing, and operational ownership.
# Tags may be supplied as a bare key ("owner") or in key:value format
# ("owner:platform-team"). Both forms satisfy the requirement.
# ---------------------------------------------------------------------------

required_delegate_tags := {"owner", "cost-centre"}

# Helper: returns true when the tag set contains an exact match or a
# key:value entry whose key prefix equals the required tag name.
delegate_has_tag(tags, tag) if {
    tag in tags
}

delegate_has_tag(tags, tag) if {
    some t in tags
    startswith(t, sprintf("%v:", [tag]))
}

violation contains msg if {
    delegate := input.delegates[_]
    tag := required_delegate_tags[_]
    not delegate_has_tag(delegate.tags, tag)
    msg := {
        "rule":     "DV-008",
        "severity": "LOW",
        "delegate": delegate.name,
        "tag":      tag,
        "issue":    sprintf("Delegate '%v' is missing required tag: '%v' (accepted formats: '%v' or '%v:<value>').", [delegate.name, tag, tag, tag]),
        "fix":      sprintf("Add the '%v' tag to the delegate configuration as a bare tag ('%v') or in key:value format ('%v:<value>').", [tag, tag, tag]),
    }
}

# ---------------------------------------------------------------------------
# ALLOW — All delegate validation checks pass when no violations exist
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
        "DV-001: Delegates must be active and connected",
        "DV-002: Delegates must run approved versions only",
        "DV-003: Delegates must carry org-approved tag",
        "DV-004: Delegates must not run as root user",
        "DV-005: Delegate must have resource limits defined",
        "DV-006: Delegates must be assigned to correct scope",
        "DV-007: Delegate names must follow naming convention",
        "DV-008: Delegates must have owner and cost-centre tags",
    ],
}
