# ============================================================
# Harness Pipeline Guardrail Policies
# Package: harness.pipeline.guardrails
# Version: 1.0.0
# Last Updated: 2026-06-04
#
# Enforces security, compliance, and operational guardrails
# for Harness CI/CD pipelines across all connected repositories.
# ============================================================

package harness.pipeline.guardrails

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
# RULE: PG-001 — Approval gate required before production deploy
# Severity: CRITICAL
# Every pipeline stage that targets a production environment MUST
# have at least one approval step before execution.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    is_production_stage(stage)
    not has_approval_step(stage)
    msg := {
        "rule":     "PG-001",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' targets a production environment but has no approval step.", [stage.name]),
        "fix":      "Add a Harness Approval step (HarnessApproval or JiraApproval) before the execution step in this stage.",
    }
}

is_production_stage(stage) if {
    env := lower(stage.spec.infrastructure.environment.type)
    env == "production"
}

is_production_stage(stage) if {
    env := lower(stage.spec.environment.type)
    env == "production"
}

is_production_stage(stage) if {
    env_name := lower(stage.spec.infrastructure.environment.name)
    regex.match("^(prod|production|prd).*", env_name)
}

approval_step_types := {"HarnessApproval", "JiraApproval", "ServiceNowApproval"}

# Membership alone isn't enough — an approval step placed AFTER the deploy
# step previously still counted as compliant. Require the earliest approval
# step to come before every other (non-approval) step in the stage.
has_approval_step(stage) if {
    steps := stage.spec.execution.steps
    approval_indices := [i | steps[i].step.type in approval_step_types]
    count(approval_indices) > 0
    other_indices := [i | steps[i]; not steps[i].step.type in approval_step_types]
    count(other_indices) == 0
}

has_approval_step(stage) if {
    steps := stage.spec.execution.steps
    approval_indices := [i | steps[i].step.type in approval_step_types]
    other_indices := [i | steps[i]; not steps[i].step.type in approval_step_types]
    count(approval_indices) > 0
    count(other_indices) > 0
    min(approval_indices) < min(other_indices)
}

# ---------------------------------------------------------------------------
# RULE: PG-002 — No plaintext secrets in pipeline YAML
# Severity: CRITICAL
# Secret values must always be referenced via Harness Secret Manager
# expressions (e.g. <+secrets.getValue("...")>) and never inlined.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    env   := step.step.spec.envVariables[key]
    is_plaintext_secret(key, env)
    msg := {
        "rule":     "PG-002",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "step":     step.step.name,
        "key":      key,
        "issue":    sprintf("Environment variable '%v' in step '%v' appears to contain a plaintext secret.", [key, step.step.name]),
        "fix":      "Replace the value with a Harness Secret Manager reference: <+secrets.getValue(\"secret-name\")>",
    }
}

violation contains msg if {
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    env   := step.step.spec.env[key]
    is_plaintext_secret(key, env)
    msg := {
        "rule":     "PG-002",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "step":     step.step.name,
        "key":      key,
        "issue":    sprintf("Environment variable '%v' in step '%v' appears to contain a plaintext secret.", [key, step.step.name]),
        "fix":      "Replace the value with a Harness Secret Manager reference: <+secrets.getValue(\"secret-name\")>",
    }
}

secret_key_patterns := [
    "(?i)(password|passwd|pwd)",
    "(?i)(secret|token|api[_-]?key)",
    "(?i)(access[_-]?key|private[_-]?key)",
    "(?i)(credential|auth[_-]?token)",
]

is_plaintext_secret(key, value) if {
    pattern := secret_key_patterns[_]
    regex.match(pattern, key)
    not startswith(value, "<+secrets")
    not startswith(value, "<+pipeline.variables")
}

# ---------------------------------------------------------------------------
# RULE: PG-003 — Container images must use approved registries
# Severity: HIGH
# All container image references must pull from approved internal or
# trusted registries. Public unvetted images are not permitted.
# ---------------------------------------------------------------------------

approved_registries := {
    "gcr.io/deloitte-",
    "us-docker.pkg.dev/deloitte-",
    "eu-docker.pkg.dev/deloitte-",
    "index.docker.io/deloitteinternal/",
    "ghcr.io/deloitte-global-cloud-services/",
}

violation contains msg if {
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    image := step.step.spec.image
    not image_from_approved_registry(image)
    msg := {
        "rule":     "PG-003",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "image":    image,
        "issue":    sprintf("Image '%v' is not from an approved registry.", [image]),
        "fix":      "Use an image from an approved registry. See policies/opa/pipeline-guardrails.rego for the approved_registries list.",
    }
}

image_from_approved_registry(image) if {
    prefix := approved_registries[_]
    startswith(image, prefix)
}

# ---------------------------------------------------------------------------
# RULE: PG-004 — Pipeline stage timeout must be set
# Severity: MEDIUM
# Every pipeline stage must define an explicit timeout to prevent
# runaway executions from consuming infrastructure resources.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    not stage.timeout
    msg := {
        "rule":     "PG-004",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' does not define a timeout.", [stage.name]),
        "fix":      "Set a 'timeout' field on the stage (e.g. timeout: 1h) to cap maximum execution time.",
    }
}

violation contains msg if {
    stage := input.pipeline.stages[_]
    stage.timeout
    not regex.match(`^\d+(m|h|d)$`, stage.timeout)
    msg := {
        "rule":     "PG-004",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "timeout":  stage.timeout,
        "issue":    sprintf("Stage '%v' has an invalid timeout format: '%v'. Expected format: <number>(m|h|d).", [stage.name, stage.timeout]),
        "fix":      "Use a valid timeout format, e.g. '30m', '2h', or '1d'.",
    }
}

# ---------------------------------------------------------------------------
# RULE: PG-005 — Delegate selector must be specified for deploy stages
# Severity: MEDIUM
# Deployment stages must target a named delegate or delegate tag to
# ensure execution on a compliant, authorized host.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    stage.type == "Deployment"
    not has_delegate_selector(stage)
    msg := {
        "rule":     "PG-005",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Deployment stage '%v' does not specify a delegate selector.", [stage.name]),
        "fix":      "Add a delegateSelectors list to the stage infrastructure with at least one valid delegate tag.",
    }
}

has_delegate_selector(stage) if {
    count(stage.spec.infrastructure.spec.delegateSelectors) > 0
}

has_delegate_selector(stage) if {
    count(stage.spec.delegateSelectors) > 0
}

# ---------------------------------------------------------------------------
# RULE: PG-006 — No wildcard delegate selector
# Severity: HIGH
# Using '*' as a delegate selector bypasses host-targeting controls
# and must not be permitted.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    selector := stage.spec.infrastructure.spec.delegateSelectors[_]
    selector == "*"
    msg := {
        "rule":     "PG-006",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Deployment stage '%v' uses a wildcard ('*') delegate selector.", [stage.name]),
        "fix":      "Replace the wildcard selector with a specific delegate tag (e.g. 'prod-delegate', 'eu-west-delegate').",
    }
}

# PG-005 recognises both the nested infra path and this flat path as valid
# delegate selector locations (see has_delegate_selector) — PG-006 must check
# both too, or a wildcard set via the flat schema goes undetected.
violation contains msg if {
    stage := input.pipeline.stages[_]
    selector := stage.spec.delegateSelectors[_]
    selector == "*"
    msg := {
        "rule":     "PG-006",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Deployment stage '%v' uses a wildcard ('*') delegate selector.", [stage.name]),
        "fix":      "Replace the wildcard selector with a specific delegate tag (e.g. 'prod-delegate', 'eu-west-delegate').",
    }
}

# ---------------------------------------------------------------------------
# RULE: PG-007 — Rollback strategy required for production deployments
# Severity: HIGH
# Production deployment stages must define a rollback strategy
# to ensure service continuity in the event of a failed deploy.
# ---------------------------------------------------------------------------

violation contains msg if {
    stage := input.pipeline.stages[_]
    stage.type == "Deployment"
    is_production_stage(stage)
    not has_rollback_steps(stage)
    msg := {
        "rule":     "PG-007",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Production deployment stage '%v' does not define rollbackSteps.", [stage.name]),
        "fix":      "Add a 'rollbackSteps' block to the stage execution spec with at least one rollback action.",
    }
}

violation contains msg if {
    stage := input.pipeline.stages[_]
    stage.type == "Deployment"
    is_production_stage(stage)
    has_rollback_steps(stage)
    count(rollback_steps(stage)) == 0
    msg := {
        "rule":     "PG-007",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Production deployment stage '%v' has an empty rollbackSteps list.", [stage.name]),
        "fix":      "Add at least one rollback step (e.g. K8sRollingRollback, HelmRollback) to the rollbackSteps block.",
    }
}

has_rollback_steps(stage) if { stage.spec.execution.rollbackSteps }
has_rollback_steps(stage) if { stage.spec.rollbackSteps }

rollback_steps(stage) := stage.spec.execution.rollbackSteps if {
    stage.spec.execution.rollbackSteps
} else := stage.spec.rollbackSteps

# ---------------------------------------------------------------------------
# RULE: PG-008 — Pipeline must have a description
# Severity: LOW
# All pipelines must include a description field for auditability
# and discoverability.
# ---------------------------------------------------------------------------

violation contains msg if {
    not input.pipeline.description
    msg := {
        "rule":     "PG-008",
        "severity": "LOW",
        "issue":    "Pipeline is missing a 'description' field.",
        "fix":      "Add a 'description' field to the pipeline root with a brief summary of the pipeline's purpose.",
    }
}

violation contains msg if {
    input.pipeline.description
    trim_space(input.pipeline.description) == ""
    msg := {
        "rule":     "PG-008",
        "severity": "LOW",
        "issue":    "Pipeline 'description' field is blank.",
        "fix":      "Provide a meaningful description for the pipeline.",
    }
}

# ---------------------------------------------------------------------------
# RULE: PG-009 — Required pipeline tags must be present
# Severity: LOW
# Pipelines must carry the 'owner' and 'cost-centre' tags for
# resource attribution and billing.
# ---------------------------------------------------------------------------

required_tags := {"owner", "cost-centre"}

violation contains msg if {
    tag := required_tags[_]
    not input.pipeline.tags[tag]
    msg := {
        "rule":     "PG-009",
        "severity": "LOW",
        "tag":      tag,
        "issue":    sprintf("Pipeline is missing the required tag: '%v'.", [tag]),
        "fix":      sprintf("Add the tag '%v' to the pipeline tags block with an appropriate value.", [tag]),
    }
}

# ---------------------------------------------------------------------------
# ALLOW — Pipeline passes all guardrails when no violations exist
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
        "PG-001: Approval gate required before production deploy",
        "PG-002: No plaintext secrets in pipeline YAML",
        "PG-003: Container images must use approved registries",
        "PG-004: Pipeline stage timeout must be set",
        "PG-005: Delegate selector must be specified for deploy stages",
        "PG-006: No wildcard delegate selector",
        "PG-007: Rollback strategy required for production deployments",
        "PG-008: Pipeline must have a description",
        "PG-009: Required pipeline tags must be present",
    ],
}
