# ============================================================
# Connector Compliance Policies
# Package: harness.connector.compliance
# Version: 1.0.0
# Last Updated: 2026-06-05
#
# Enforces compliance guardrails for all Harness connectors
# including secret handling, authentication, tagging, and
# naming conventions across connected repositories.
# ============================================================

package harness.connector.compliance

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
# HELPER — Resolve connector identifier from either nested or flat schema
# Nested: connectors[].connector.identifier
# Flat:   connectors[].identifier
# ---------------------------------------------------------------------------

connector_id(connector) := connector.connector.identifier if {
    connector.connector.identifier
} else := connector.identifier

# ---------------------------------------------------------------------------
# RULE: CC-001 — All connectors must use secret references
# Severity: CRITICAL
# Connector credentials (passwords, tokens, keys) must reference a
# Harness Secret Manager entry and never be stored as plaintext values.
# ---------------------------------------------------------------------------

violation contains msg if {
    connector := input.connectors[_]
    credential_field := connector.spec.credentials[field]
    not startswith(credential_field, "<+secrets")
    not startswith(credential_field, "${ngSecretManager")
    is_credential_field(field)
    msg := {
        "rule":      "CC-001",
        "severity":  "CRITICAL",
        "connector": connector_id(connector),
        "field":     field,
        "issue":     sprintf("Connector '%v' field '%v' contains a plaintext value instead of a secret reference.", [connector_id(connector), field]),
        "fix":       "Replace the plaintext value with a Harness Secret Manager reference: <+secrets.getValue(\"secret-name\")>.",
    }
}

credential_field_patterns := [
    "(?i)(password|passwd|pwd)",
    "(?i)(token|api[_-]?key|access[_-]?key|secret)",
    "(?i)(private[_-]?key|client[_-]?secret|certificate)",
]

is_credential_field(field) if {
    pattern := credential_field_patterns[_]
    regex.match(pattern, field)
}

# ---------------------------------------------------------------------------
# RULE: CC-002 — No expired connector credentials allowed
# Severity: CRITICAL
# Connectors whose credentials have passed their expiry date must not
# be used in active pipelines.
# ---------------------------------------------------------------------------

violation contains msg if {
    connector := input.connectors[_]
    connector.spec.credentials.expiry_date
    is_expired(connector.spec.credentials.expiry_date)
    msg := {
        "rule":       "CC-002",
        "severity":   "CRITICAL",
        "connector":  connector_id(connector),
        "expiry":     connector.spec.credentials.expiry_date,
        "issue":      sprintf("Connector '%v' has expired credentials (expiry: %v).", [connector_id(connector), connector.spec.credentials.expiry_date]),
        "fix":        "Rotate the credentials in the external system, update the corresponding Harness secret, and refresh the expiry date on the connector.",
    }
}

is_expired(expiry_date) if {
    expiry_ns := time.parse_rfc3339_ns(expiry_date)
    now_ns     := time.now_ns()
    expiry_ns  < now_ns
}

# ---------------------------------------------------------------------------
# RULE: CC-003 — Connectors must use approved authentication types
# Severity: HIGH
# Only organisation-approved authentication mechanisms are permitted.
# Unapproved auth types (e.g. basic username/password) are disallowed.
# ---------------------------------------------------------------------------

approved_auth_types := {
    "ServiceAccountToken",
    "OpenIDConnect",
    "IAMRole",
    "IRSA",
    "WorkloadIdentity",
    "SSHKey",
    "GitHubApp",
    "OAuth",
    "BearerToken",
}

violation contains msg if {
    connector := input.connectors[_]
    connector.spec.authentication.type
    not connector.spec.authentication.type in approved_auth_types
    msg := {
        "rule":      "CC-003",
        "severity":  "HIGH",
        "connector": connector_id(connector),
        "auth_type": connector.spec.authentication.type,
        "issue":     sprintf("Connector '%v' uses a non-approved authentication type: '%v'.", [connector_id(connector), connector.spec.authentication.type]),
        "fix":       sprintf("Replace the authentication type with one of the approved types: %v.", [approved_auth_types]),
    }
}

# ---------------------------------------------------------------------------
# RULE: CC-004 — Git connectors must use SSH or token auth only
# Severity: HIGH
# Git repository connectors must authenticate via SSH key or token.
# Username/password authentication is not permitted for Git connectors.
# ---------------------------------------------------------------------------

git_connector_types := {"Github", "Gitlab", "Bitbucket", "AzureRepo", "Codecommit"}

violation contains msg if {
    connector := input.connectors[_]
    connector.type in git_connector_types
    connector.spec.authentication.type in {"UsernamePassword", "BasicAuth"}
    msg := {
        "rule":      "CC-004",
        "severity":  "HIGH",
        "connector": connector_id(connector),
        "type":      connector.type,
        "auth_type": connector.spec.authentication.type,
        "issue":     sprintf("Git connector '%v' uses username/password authentication, which is not permitted.", [connector_id(connector)]),
        "fix":       "Switch the Git connector to use SSH key authentication or a personal access token (HTTP token auth).",
    }
}

# ---------------------------------------------------------------------------
# RULE: CC-005 — Cloud connectors must use IAM roles not keys
# Severity: HIGH
# AWS, GCP, and Azure connectors must authenticate via IAM role
# assumption or workload identity, not static access keys.
# ---------------------------------------------------------------------------

cloud_connector_types := {"Aws", "Gcp", "Azure"}

violation contains msg if {
    connector := input.connectors[_]
    connector.type in cloud_connector_types
    connector.spec.credential.type in {"ManualConfig", "AccessKey", "ServiceAccountKey", "ServicePrincipalSecret"}
    msg := {
        "rule":       "CC-005",
        "severity":   "HIGH",
        "connector":  connector_id(connector),
        "cloud_type": connector.type,
        "cred_type":  connector.spec.credential.type,
        "issue":      sprintf("Cloud connector '%v' (%v) uses static key credentials instead of IAM role-based authentication.", [connector_id(connector), connector.type]),
        "fix":        "Reconfigure the cloud connector to use IAM role assumption (AWS), Workload Identity (GCP), or Managed Identity (Azure) instead of static access keys.",
    }
}

# ---------------------------------------------------------------------------
# RULE: CC-006 — Connectors must have owner and team tags
# Severity: MEDIUM
# All connectors must carry 'owner' and 'team' tags for resource
# attribution, cost allocation, and incident response routing.
# ---------------------------------------------------------------------------

required_connector_tags := {"owner", "team"}

violation contains msg if {
    connector := input.connectors[_]
    tag := required_connector_tags[_]
    not connector.tags[tag]
    msg := {
        "rule":      "CC-006",
        "severity":  "MEDIUM",
        "connector": connector_id(connector),
        "tag":       tag,
        "issue":     sprintf("Connector '%v' is missing required tag: '%v'.", [connector_id(connector), tag]),
        "fix":       sprintf("Add the '%v' tag to the connector definition with an appropriate value.", [tag]),
    }
}

# ---------------------------------------------------------------------------
# RULE: CC-007 — Connector names must follow naming convention
# Severity: MEDIUM
# Connector identifiers must follow the pattern:
# <type>-<environment>-<descriptor> using lowercase letters,
# digits, and hyphens only (e.g. aws-prod-main, github-dev-app).
# ---------------------------------------------------------------------------

connector_name_pattern := `^[a-z][a-z0-9]*(-[a-z0-9]+){2,}$`

violation contains msg if {
    connector := input.connectors[_]
    not regex.match(connector_name_pattern, connector_id(connector))
    msg := {
        "rule":      "CC-007",
        "severity":  "MEDIUM",
        "connector": connector_id(connector),
        "issue":     sprintf("Connector identifier '%v' does not follow the naming convention <type>-<env>-<descriptor>.", [connector_id(connector)]),
        "fix":       "Rename the connector to follow the pattern: <type>-<environment>-<descriptor> using lowercase letters, digits, and hyphens (e.g. 'aws-prod-main', 'github-dev-frontend').",
    }
}

# ---------------------------------------------------------------------------
# RULE: CC-008 — Connectors must have a description field
# Severity: LOW
# All connectors must include a non-empty description to aid
# discoverability and auditability.
# ---------------------------------------------------------------------------

violation contains msg if {
    connector := input.connectors[_]
    not connector.description
    msg := {
        "rule":      "CC-008",
        "severity":  "LOW",
        "connector": connector_id(connector),
        "issue":     sprintf("Connector '%v' is missing a 'description' field.", [connector_id(connector)]),
        "fix":       "Add a 'description' field to the connector with a brief explanation of its purpose, target system, and owning team.",
    }
}

violation contains msg if {
    connector := input.connectors[_]
    connector.description
    trim_space(connector.description) == ""
    msg := {
        "rule":      "CC-008",
        "severity":  "LOW",
        "connector": connector_id(connector),
        "issue":     sprintf("Connector '%v' has a blank 'description' field.", [connector_id(connector)]),
        "fix":       "Provide a meaningful description for the connector.",
    }
}

# ---------------------------------------------------------------------------
# ALLOW — All connector compliance checks pass when no violations exist
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
        "CC-001: All connectors must use secret references",
        "CC-002: No expired connector credentials allowed",
        "CC-003: Connectors must use approved authentication types",
        "CC-004: Git connectors must use SSH or token auth only",
        "CC-005: Cloud connectors must use IAM roles not keys",
        "CC-006: Connectors must have owner and team tags",
        "CC-007: Connector names must follow naming convention",
        "CC-008: Connectors must have a description field",
    ],
}
