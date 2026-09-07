# OPA Policy Writing Guide

> 🛡️ Comprehensive guide for writing, testing, and deploying OPA policies in this repository

---

## Table of Contents

1. [Introduction to OPA and Rego](#1-introduction-to-opa-and-rego)
2. [Repository Policy Structure and Naming Conventions](#2-repository-policy-structure-and-naming-conventions)
3. [How to Write a New .rego Policy File](#3-how-to-write-a-new-rego-policy-file)
4. [How to Test a Policy Locally Using OPA CLI](#4-how-to-test-a-policy-locally-using-opa-cli)
5. [How to Load Policies into Harness Policy Engine](#5-how-to-load-policies-into-harness-policy-engine)
6. [How to Link Policies to Harness Pipelines](#6-how-to-link-policies-to-harness-pipelines)
7. [How to Raise a Policy Exception](#7-how-to-raise-a-policy-exception)
8. [Policy Review and Approval Process](#8-policy-review-and-approval-process)
9. [Examples Using Existing Rules](#9-examples-using-existing-rules)
10. [Contribution Guidelines for New Policies](#10-contribution-guidelines-for-new-policies)
11. [Research Agent — Automated Policy Intelligence](#11-research-agent--automated-policy-intelligence)

---

## 1. Introduction to OPA and Rego

### What is OPA?

[Open Policy Agent (OPA)](https://www.openpolicyagent.org/) is an open-source, general-purpose policy engine that enables fine-grained, unified policy enforcement across cloud-native stacks. In this repository, OPA policies gate Harness CI/CD pipelines to enforce security and compliance standards before merging or releasing to production.

### What is Rego?

Rego is OPA's purpose-built policy language. It is a declarative query language designed for expressing policies over structured data (JSON). Key characteristics:

- **Declarative** — you describe *what* must be true, not *how* to compute it
- **Safe** — no infinite loops; every query terminates
- **Composable** — rules, helper functions, and packages can be imported and reused

### Core Rego Concepts

| Concept | Description |
|---|---|
| `package` | Namespace for a set of related rules |
| `input` | The JSON document being evaluated (e.g. pipeline YAML, PR metadata) |
| `rule` | A named expression that yields `true`, `false`, or a value |
| `violation` | A set-valued rule that collects all policy breaches found in `input` |
| `deny` | Conventional rule that returns messages for blocked actions |
| `warn` | Conventional rule that returns advisory messages without blocking |
| `default` | Fallback value when a rule body produces no results |
| `import future.keywords.*` | Enables `if`, `in`, `contains`, `every` sugar syntax |

### Simple Rego Example

```rego
package example.policy

import future.keywords.if
import future.keywords.contains

default allow = false

# Deny if 'name' field is absent
violation contains msg if {
    not input.name
    msg := {
        "rule":  "EX-001",
        "issue": "The 'name' field is required.",
        "fix":   "Add a 'name' field to the input document.",
    }
}

allow if {
    count(violation) == 0
}
```

---

## 2. Repository Policy Structure and Naming Conventions

### Directory Layout

```
├── policies/
│   ├── opa/
│   │   ├── pipeline-guardrails.rego     ← harness.pipeline.guardrails
│   │   ├── code-security.rego           ← harness.code.security
│   │   ├── connector-compliance.rego    ← harness.connector.compliance
│   │   └── delegate-validation.rego     ← harness.delegate.validation
│   └── pipeline/
│       ├── stage-gates.yaml
│       └── approval-rules.yaml
└── docs/
    ├── policy-guide.md                  ← This file
    └── violation-remediation.md
```

### File Naming Convention

Policy files use lowercase hyphenated names that describe the domain they govern:

```
<domain>-<topic>.rego
```

**Examples:**

| File | Domain | Topic |
|---|---|---|
| `pipeline-guardrails.rego` | pipeline | guardrails |
| `code-security.rego` | code | security |
| `connector-compliance.rego` | connector | compliance |
| `delegate-validation.rego` | delegate | validation |

### Package Naming Convention

Every policy file declares a package using the pattern:

```
package harness.<area>.<topic>
```

| Area | Example Package |
|---|---|
| `pipeline` | `harness.pipeline.guardrails` |
| `code` | `harness.code.security` |
| `connector` | `harness.connector.compliance` |
| `delegate` | `harness.delegate.validation` |

### Rule ID Naming Convention

Rule IDs follow a two-part pattern: a two-letter area prefix followed by a zero-padded three-digit number.

```
<PREFIX>-<NNN>
```

| Prefix | Area | Example |
|---|---|---|
| `PG` | Pipeline Guardrails | `PG-001` |
| `CS` | Code Security | `CS-001` |
| `CC` | Connector Compliance | `CC-001` |
| `DV` | Delegate Validation | `DV-001` |

Rules within each file are numbered sequentially. New rules take the next available number.

---

## 3. How to Write a New .rego Policy File

### 3.1 File Header

Every policy file begins with a structured comment header:

```rego
# ============================================================
# <Human-Readable Title>
# Package: harness.<area>.<topic>
# Version: 1.0.0
# Last Updated: YYYY-MM-DD
#
# <One-paragraph description of what this file enforces.>
# ============================================================
```

### 3.2 Package Declaration and Imports

```rego
package harness.<area>.<topic>

import future.keywords.if
import future.keywords.in
import future.keywords.contains
import future.keywords.every
```

Always import the four future keywords. They enable the expressive `if`, `in`, `contains`, and `every` syntax used consistently across all policy files in this repository.

### 3.3 Default Values

```rego
default allow = false
default violation_count = 0
```

`allow` defaults to `false` so that a pipeline or resource is denied unless all rules explicitly pass.

### 3.4 Package Naming Convention

```rego
package harness.{area}.{topic}
```

Replace `{area}` and `{topic}` with lowercase, dot-separated identifiers matching the file's domain. Do not use hyphens inside the package name.

### 3.5 Rule Naming Convention

Rule IDs follow `<PREFIX>-<NNN>` (see §2). Every rule block begins with a structured comment:

```rego
# ---------------------------------------------------------------------------
# RULE: PG-001 — <Short human-readable title>
# Severity: CRITICAL | HIGH | MEDIUM | LOW
# <One or two sentences explaining what the rule enforces and why.>
# ---------------------------------------------------------------------------
```

### 3.6 Severity Levels

| Severity | Meaning | Pipeline Effect |
|---|---|---|
| `CRITICAL` | Security or compliance breach; blocks pipeline execution | ❌ Blocks |
| `HIGH` | Significant risk; blocks pipeline execution | ❌ Blocks |
| `MEDIUM` | Moderate risk; blocks pipeline execution | ❌ Blocks |
| `LOW` | Advisory finding; does not block pipeline execution | ⚠️ Warns |

> **Note:** Severity is a metadata field inside the violation message object. The `violation` set is collected regardless of severity — it is the caller (Guardrail Enforcement Agent or Harness policy step) that decides whether to block based on severity thresholds.

### 3.7 How to Write Deny Rules

Deny rules use the `violation contains msg` pattern. A violation fires when all conditions in the rule body are satisfied:

```rego
violation contains msg if {
    # 1. Navigate to the resource being checked
    stage := input.pipeline.stages[_]

    # 2. Assert the condition that triggers the violation
    stage.type == "Deployment"
    not has_approval_step(stage)

    # 3. Build the violation message object
    msg := {
        "rule":     "PG-001",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' is missing a required approval step.", [stage.name]),
        "fix":      "Add a HarnessApproval or JiraApproval step before the execution step.",
    }
}
```

**Required fields in every violation message:**

| Field | Type | Description |
|---|---|---|
| `rule` | string | Rule ID (e.g. `"PG-001"`) |
| `severity` | string | One of `CRITICAL`, `HIGH`, `MEDIUM`, `LOW` |
| `issue` | string | Human-readable description of the problem |
| `fix` | string | Actionable remediation step |

Additional context fields (e.g. `stage`, `step`, `file`, `image`) should be added when available to aid diagnosis.

### 3.8 How to Write Warn Rules

For advisory checks that should surface information without blocking, use a separate `warn` set rule:

```rego
warn contains msg if {
    stage := input.pipeline.stages[_]
    not stage.spec.description
    msg := {
        "rule":     "PG-010",
        "severity": "LOW",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' has no description.", [stage.name]),
        "fix":      "Add a 'description' field to improve pipeline readability.",
    }
}
```

`warn` rules follow the same message schema as `violation` rules but are not included in the `violation` set and do not affect `allow`.

### 3.9 How to Write Violation Messages

Messages must be clear, specific, and actionable:

- **`issue`** — State *what* is wrong and *where*. Use `sprintf` to include the resource name.
- **`fix`** — Provide a concrete, step-by-step action the developer can take immediately.
- Avoid vague language like "configuration is incorrect". Be specific.

**Good example:**

```rego
"issue": sprintf("Stage '%v' targets a production environment but has no approval step.", [stage.name]),
"fix":   "Add a Harness Approval step (HarnessApproval or JiraApproval) before the execution step in this stage.",
```

**Poor example:**

```rego
"issue": "Approval missing.",
"fix":   "Fix the pipeline.",
```

### 3.10 Allow Rule and Summary

Every policy file must end with an `allow` rule and a `summary` object:

```rego
# ---------------------------------------------------------------------------
# ALLOW — passes when no violations exist
# ---------------------------------------------------------------------------

allow if {
    count(violation) == 0
}

violation_count := count(violation)

# ---------------------------------------------------------------------------
# SUMMARY — Aggregated compliance report
# ---------------------------------------------------------------------------

summary := {
    "allow":             allow,
    "violation_count":   violation_count,
    "violations":        violation,
    "policies_evaluated": [
        "XX-001: <title>",
        "XX-002: <title>",
    ],
}
```

---

## 4. How to Test a Policy Locally Using OPA CLI

### 4.1 Install OPA CLI

**macOS (Homebrew):**

```bash
brew install opa
```

**Linux:**

```bash
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static
chmod +x opa
sudo mv opa /usr/local/bin/
```

**Windows (PowerShell):**

```powershell
Invoke-WebRequest -Uri "https://openpolicyagent.org/downloads/latest/opa_windows_amd64.exe" -OutFile "opa.exe"
```

Verify the installation:

```bash
opa version
```

### 4.2 Write a Test Input JSON

Create a JSON file that represents the resource being evaluated. The structure must match the `input` document expected by the policy.

**Example: `test-input.json` for `pipeline-guardrails.rego`**

```json
{
  "pipeline": {
    "name": "Deploy to Production",
    "description": "Main deployment pipeline",
    "tags": {
      "owner": "platform-team",
      "cost-centre": "CC-1234"
    },
    "stages": [
      {
        "name": "deploy-prod",
        "type": "Deployment",
        "timeout": "1h",
        "spec": {
          "infrastructure": {
            "environment": {
              "type": "Production",
              "name": "prod-eu-west"
            },
            "spec": {
              "delegateSelectors": ["prod-eu-west-delegate-01"]
            }
          },
          "execution": {
            "steps": [
              {
                "step": {
                  "name": "approve",
                  "type": "HarnessApproval",
                  "spec": {}
                }
              },
              {
                "step": {
                  "name": "deploy",
                  "type": "K8sRollingDeploy",
                  "spec": {
                    "image": "gcr.io/deloitte-platform/app:1.2.3"
                  }
                }
              }
            ],
            "rollbackSteps": [
              {
                "step": {
                  "name": "rollback",
                  "type": "K8sRollingRollback",
                  "spec": {}
                }
              }
            ]
          }
        }
      }
    ]
  }
}
```

### 4.3 Run the `opa eval` Command

Evaluate the full policy summary against a test input:

```bash
opa eval \
  --input test-input.json \
  --data policies/opa/pipeline-guardrails.rego \
  "data.harness.pipeline.guardrails.summary"
```

Evaluate only the `violation` set:

```bash
opa eval \
  --input test-input.json \
  --data policies/opa/pipeline-guardrails.rego \
  "data.harness.pipeline.guardrails.violation"
```

Evaluate a specific rule expression:

```bash
opa eval \
  --input test-input.json \
  --data policies/opa/pipeline-guardrails.rego \
  "data.harness.pipeline.guardrails.allow"
```

### 4.4 Interpret Results

**Passing result (no violations):**

```json
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "allow": true,
            "violation_count": 0,
            "violations": [],
            "policies_evaluated": ["PG-001: ...", "PG-002: ..."]
          }
        }
      ]
    }
  ]
}
```

**Failing result (one or more violations):**

```json
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "allow": false,
            "violation_count": 1,
            "violations": [
              {
                "rule": "PG-001",
                "severity": "CRITICAL",
                "stage": "deploy-prod",
                "issue": "Stage 'deploy-prod' targets a production environment but has no approval step.",
                "fix": "Add a Harness Approval step (HarnessApproval or JiraApproval) before the execution step in this stage."
              }
            ]
          }
        }
      ]
    }
  ]
}
```

Key fields to check in the output:

| Field | Expected when passing | Expected when failing |
|---|---|---|
| `allow` | `true` | `false` |
| `violation_count` | `0` | `> 0` |
| `violations` | Empty array `[]` | Array of violation objects |

### 4.5 Running OPA Unit Tests

OPA supports built-in unit testing via `opa test`. Write test files alongside policies:

```rego
# policies/opa/pipeline-guardrails_test.rego
package harness.pipeline.guardrails_test

import data.harness.pipeline.guardrails

test_allow_when_no_violations {
    guardrails.allow with input as {
        "pipeline": {
            "name": "test",
            "description": "test pipeline",
            "tags": {"owner": "team", "cost-centre": "CC-001"},
            "stages": []
        }
    }
}
```

Run all tests:

```bash
opa test policies/opa/
```

---

## 5. How to Load Policies into Harness Policy Engine

### Prerequisites

- Harness account with Admin or Policy Manager role
- Policy files committed to `policies/opa/` in this repository

### Step-by-Step

1. **Navigate to Policies**
   - Go to **Account Settings** (or Org/Project Settings for narrower scope)
   - Select **Policies** under the Governance section

2. **Create a New Policy**
   - Click **New Policy**
   - Enter a name matching the file, e.g. `Pipeline Guardrails`
   - Paste the contents of the `.rego` file into the policy editor, or use the **Git Experience** to sync directly from this repository

3. **Enable Git Experience (recommended)**
   - Under **Policy Settings → Git Experience**, connect to this repository
   - Set the policy file path to `policies/opa/<filename>.rego`
   - Harness will automatically sync policy updates when changes are merged to `main`

4. **Save and Activate**
   - Click **Save**
   - Ensure the policy status shows as **Active**

5. **Verify**
   - Use the **Test Policy** panel in Harness to paste a sample input JSON and confirm the policy evaluates correctly before linking it to a pipeline

---

## 6. How to Link Policies to Harness Pipelines

### Using Policy Sets

1. **Create a Policy Set**
   - Go to **Account/Org/Project Settings → Policies → Policy Sets**
   - Click **New Policy Set**
   - Assign a name (e.g. `Production Deployment Gates`)
   - Add one or more policies from §5

2. **Configure Enforcement Action**
   - Set **On Failure**: `Warn & Continue` for LOW severity sets, `Error & Exit` for CRITICAL/HIGH sets

3. **Link to a Pipeline Stage**
   - Open the target pipeline in Harness Studio
   - Select the stage where enforcement should occur (typically before a deploy step)
   - Under **Advanced → Policy Enforcement**, select the Policy Set created above
   - Choose the **Event** that triggers evaluation: `On Step`, `On Stage`, or `On Pipeline`

4. **Link via YAML**

   Alternatively, add the policy enforcement block directly in the pipeline YAML:

   ```yaml
   stage:
     name: deploy-prod
     type: Deployment
     spec:
       ...
     policies:
       - identifier: pipeline_guardrails_policy_set
         type: PolicySet
   ```

5. **Test the Integration**
   - Trigger the pipeline with a known-violating input
   - Confirm that the pipeline fails at the policy evaluation step with the expected violation messages

---

## 7. How to Raise a Policy Exception

A policy exception is a time-boxed, documented waiver that allows a specific pipeline or resource to bypass one or more policy rules without modifying the policy itself.

### When to Raise an Exception

- A legacy pipeline cannot be immediately remediated (e.g. a migration in progress)
- A third-party integration requires a non-standard configuration temporarily
- A business-critical release must proceed while a fix is in flight

### Raising an Exception

1. **Raise a GitHub Issue** in this repository using the `policy-exception` label
2. **Include the following in the issue:**
   - Rule ID(s) being exempted (e.g. `PG-003`)
   - Pipeline/resource identifier
   - Justification with business reason
   - Proposed fix and target remediation date
   - Risk acknowledgement from the team lead

3. **Obtain Approval**
   - Exceptions require approval from the Security/Compliance team (see §8)

4. **Record in Harness**
   - Go to **Policies → Exceptions** in the Harness UI
   - Create a new exception scoped to the specific pipeline or account
   - Set an expiry date (maximum 90 days; renewable with re-approval)
   - Reference the GitHub issue number in the exception notes

5. **Monitor and Close**
   - Track the exception via the GitHub issue
   - Once the remediation is complete, close the issue and remove the Harness exception

---

## 8. Policy Review and Approval Process

### Overview

All new or modified policies must go through a peer review process before being activated in Harness. This ensures correctness, security soundness, and alignment with compliance requirements.

### Process

```
Author writes/modifies .rego policy
        │
        ▼
Branch: policy/<area>-<description>
        │
        ▼
Local OPA testing (opa eval + opa test)
        │
        ▼
Pull Request opened against main
        │
        ▼
Guardrail Enforcement Agent evaluates PR
        │
        ▼
Peer review: at least 1 security/compliance reviewer
        │
        ▼
Optional: CISO/Governance sign-off for CRITICAL rules
        │
        ▼
Merge to main → auto-synced to Harness Policy Engine
```

### Review Criteria

Reviewers check:

| Criterion | Description |
|---|---|
| Correctness | Rule fires only when the violation genuinely exists |
| Completeness | All relevant edge cases are covered |
| Clarity | `issue` and `fix` messages are specific and actionable |
| Naming | Rule ID follows convention; package name is correct |
| Tests | At least one `opa test` test case per new rule |
| Documentation | `violation-remediation.md` updated with remediation guidance |

### Approval Requirements

| Change Type | Approvals Required |
|---|---|
| New LOW/MEDIUM rule | 1 peer review |
| New HIGH rule | 1 peer review + Security team lead |
| New CRITICAL rule | 1 peer review + Security team lead + CISO sign-off |
| Removing or weakening a rule | Same as the original severity level |
| Exception to an existing rule | Security team lead + documented business justification |

---

## 9. Examples Using Existing Rules

### 9.1 CRITICAL Example — PG-001: Approval Gate Required

**Source file:** `policies/opa/pipeline-guardrails.rego`

**What it enforces:** Every pipeline stage targeting a production environment must have at least one approval step before execution.

**Rego rule:**

```rego
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
    env_name := lower(stage.spec.infrastructure.environment.name)
    regex.match("^(prod|production|prd).*", env_name)
}

has_approval_step(stage) if {
    step := stage.spec.execution.steps[_]
    step.step.type in {"HarnessApproval", "JiraApproval", "ServiceNowApproval"}
}
```

**Triggering input (violation):**

```json
{
  "pipeline": {
    "stages": [{
      "name": "deploy-prod",
      "spec": {
        "infrastructure": {
          "environment": { "type": "Production", "name": "prod-eu-west" }
        },
        "execution": {
          "steps": [
            { "step": { "name": "deploy", "type": "K8sRollingDeploy", "spec": {} } }
          ]
        }
      }
    }]
  }
}
```

**Expected violation output:**

```json
{
  "rule": "PG-001",
  "severity": "CRITICAL",
  "stage": "deploy-prod",
  "issue": "Stage 'deploy-prod' targets a production environment but has no approval step.",
  "fix": "Add a Harness Approval step (HarnessApproval or JiraApproval) before the execution step in this stage."
}
```

**Remediation:** Add a `HarnessApproval` step as the first step in any production deployment stage.

---

### 9.2 MEDIUM Example — CS-006: SAST Scan Required Before Merge

**Source file:** `policies/opa/code-security.rego`

**What it enforces:** Pull requests must have a passing SAST (Static Application Security Testing) scan result before they can be merged.

**Rego rule:**

```rego
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
```

**Triggering input (violation):**

```json
{
  "pull_request": {
    "number": 42,
    "checks": {
      "sast": { "passed": false }
    }
  }
}
```

**Expected violation output:**

```json
{
  "rule": "CS-006",
  "severity": "MEDIUM",
  "pr": 42,
  "issue": "Pull request #42 has not passed the required SAST security scan.",
  "fix": "Ensure the SAST pipeline check completes successfully. Review and remediate any findings reported by the scanner before merging."
}
```

**Remediation:** Wait for the SAST check to complete and address any flagged findings. Re-run the scan until it passes before merging.

---

### 9.3 LOW Example — DV-008: Delegate Owner and Cost-Centre Tags Required

**Source file:** `policies/opa/delegate-validation.rego`

**What it enforces:** All Harness delegates must carry `owner` and `cost-centre` tags for resource attribution and billing. Tags may be supplied as a bare key (`"owner"`) or in key:value format (`"owner:platform-team"`). Both forms satisfy the requirement.

**Rego rule:**

```rego
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
```

**Triggering input (violation):**

```json
{
  "delegates": [
    {
      "name": "prod-eu-west-delegate-01",
      "tags": ["org-approved"]
    }
  ]
}
```

**Expected violation output:**

```json
[
  {
    "rule": "DV-008",
    "severity": "LOW",
    "delegate": "prod-eu-west-delegate-01",
    "tag": "owner",
    "issue": "Delegate 'prod-eu-west-delegate-01' is missing required tag: 'owner' (accepted formats: 'owner' or 'owner:<value>').",
    "fix": "Add the 'owner' tag to the delegate configuration as a bare tag ('owner') or in key:value format ('owner:<value>')."
  },
  {
    "rule": "DV-008",
    "severity": "LOW",
    "delegate": "prod-eu-west-delegate-01",
    "tag": "cost-centre",
    "issue": "Delegate 'prod-eu-west-delegate-01' is missing required tag: 'cost-centre' (accepted formats: 'cost-centre' or 'cost-centre:<value>').",
    "fix": "Add the 'cost-centre' tag to the delegate configuration as a bare tag ('cost-centre') or in key:value format ('cost-centre:<value>')."
  }
]
```

**Passing inputs (no violation):**

```json
{ "delegates": [{ "name": "prod-eu-west-delegate-01", "tags": ["org-approved", "owner", "cost-centre"] }] }
```

```json
{ "delegates": [{ "name": "prod-eu-west-delegate-01", "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-1234"] }] }
```

**Remediation:** Add `owner` and `cost-centre` tags to the delegate configuration in the Harness UI or delegate YAML spec, using either bare-key or key:value format.

---

## 10. Contribution Guidelines for New Policies

### Before You Start

- Check existing `.rego` files to ensure the rule does not already exist
- Review open issues and PRs in this repository to avoid duplicating in-flight work
- Discuss significant new policy areas in a GitHub issue before writing code

### Step-by-Step Contribution

1. **Create a branch** from `main`:
   ```bash
   git checkout -b policy/<area>-<short-description>
   ```
   Example: `policy/code-dependency-scanning`

2. **Add or modify the `.rego` file** in `policies/opa/`:
   - Follow all conventions in §2 and §3
   - Assign the next available rule ID in the sequence
   - Include a rule comment block with severity level

3. **Write OPA unit tests** in a `_test.rego` file:
   - At minimum, one test for a passing case and one for each violation path
   - Run locally: `opa test policies/opa/`

4. **Update `docs/violation-remediation.md`**:
   - Add an entry for each new rule with expanded remediation guidance

5. **Test locally** with `opa eval` (see §4)

6. **Open a Pull Request** against `main`:
   - Title format: `policy: Add <RULE-ID> — <short title>`
   - Link the issue if one exists
   - The Guardrail Enforcement Agent will automatically evaluate the PR

7. **Address review feedback** from the Guardrail Enforcement Agent and human reviewers

8. **Obtain required approvals** (see §8 for approval thresholds by severity)

9. **Merge** — the policy is automatically synced to Harness Policy Engine via Git Experience

### Code Style

- Use 4-space indentation in Rego files
- Use `snake_case` for variable and function names
- Group related helper functions immediately after the rule that uses them
- Separate each rule block with the standard comment divider line:
  ```
  # ---------------------------------------------------------------------------
  ```
- Do not leave trailing whitespace

### Checklist for New Rules

- [ ] Rule ID follows `<PREFIX>-<NNN>` convention
- [ ] Package name follows `harness.<area>.<topic>` convention
- [ ] Rule comment block includes severity level
- [ ] `violation contains msg` pattern is used (not bare `deny`)
- [ ] Violation message includes `rule`, `severity`, `issue`, and `fix` fields
- [ ] `fix` message is specific and actionable
- [ ] `sprintf` is used to include resource names in messages
- [ ] Helper functions are defined for reusable condition checks
- [ ] `policies_evaluated` list in `summary` is updated
- [ ] `opa test` passes with at least one test per rule
- [ ] `docs/violation-remediation.md` updated
- [ ] PR opened against `main` with correct title format

---

*For questions or clarifications, open a GitHub issue in this repository with the `policy-question` label.*

---

## 11. Research Agent — Automated Policy Intelligence

The **Research Agent** runs weekly (and on demand) to monitor external threat 
intelligence sources and identify gaps in the current OPA rule set.

### What it does

1. Fetches new CVEs from NVD and active exploits from CISA KEV (OWASP and
   Harness release notes are manually monitored — automated fetch for those
   two sources is not yet implemented in `scripts/research_agent.py`).
2. Compares findings against every `.rego` rule in `policies/opa/` and 
   `policies/pi/`.
3. Flags threats that have no corresponding guardrail as **gaps**.
4. Logs each gap as `NEEDS_MANUAL_REVIEW` (rule assignment `TBD`) — the
   current implementation does not autonomously draft `.rego` rule text.
5. Files a GitHub Issue with the scan summary. GitHub Enterprise Cloud
   policy prevents Actions from opening PRs directly, so a human drafts and
   opens the rule-update PR manually after reviewing the Issue.
6. Logs every run in `policies/research/update-log.md`.

### How to trigger it manually

```bash
gh workflow run research-agent.yml \
  --field trigger_type=on_demand
```

### Reviewing Research Agent Issues

Research Agent scan summaries carry the labels `research-proposal` and 
`needs-human-review`. Before drafting/merging a rule change based on one:

1. Read each flagged gap and verify it correctly addresses the cited advisory.
2. Draft the `.rego` rule and a matching `_test.rego` case, then run 
   `opa test policies/` locally to confirm all test cases pass.
3. Open a PR yourself and request a review from the Guardrail Enforcement 
   Agent to validate OPA syntax.
4. Check that `docs/violation-remediation.md` has been updated for each new 
   rule ID.

### Update log format

Each run appends a structured entry to `policies/research/update-log.md`:

```
## Run: <ISO date> — Trigger: <scheduled|on_demand|pr_open>

### Sources scanned
### Gaps found
### Rules updated
### No-action items
```

Do **not** edit this file manually. All entries are appended automatically 
by the Research Agent workflow.
