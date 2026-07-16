# Violation Remediation Guide

> 🛡️ Step-by-step fix instructions for every active OPA policy rule in the `agent_guardrails` repository

This guide covers all **44 active rules** across seven policy files. For each rule you will find:

- Rule ID and severity
- What triggers the violation
- Step-by-step fix instructions
- Before/after examples
- How to raise a policy exception when an immediate fix is not possible

---

## Table of Contents

### Pipeline Guardrails (`harness.pipeline.guardrails`)

| Rule | Severity | Summary |
|---|---|---|
| [PG-001](#pg-001--approval-gate-required-before-production-deploy) | CRITICAL | Approval gate required before production deploy |
| [PG-002](#pg-002--no-plaintext-secrets-in-pipeline-yaml) | CRITICAL | No plaintext secrets in pipeline YAML |
| [PG-003](#pg-003--container-images-must-use-approved-registries) | HIGH | Container images must use approved registries |
| [PG-004](#pg-004--pipeline-stage-timeout-must-be-set) | MEDIUM | Pipeline stage timeout must be set |
| [PG-005](#pg-005--delegate-selector-must-be-specified-for-deploy-stages) | MEDIUM | Delegate selector must be specified for deploy stages |
| [PG-006](#pg-006--no-wildcard-delegate-selector) | HIGH | No wildcard delegate selector |
| [PG-007](#pg-007--rollback-strategy-required-for-production-deployments) | HIGH | Rollback strategy required for production deployments |
| [PG-008](#pg-008--pipeline-must-have-a-description) | LOW | Pipeline must have a description |
| [PG-009](#pg-009--required-pipeline-tags-must-be-present) | LOW | Required pipeline tags must be present |

### Code Security (`harness.code.security`)

| Rule | Severity | Summary |
|---|---|---|
| [CS-001](#cs-001--no-hardcoded-api-keys-or-tokens-in-code) | CRITICAL | No hardcoded API keys or tokens in code |
| [CS-002](#cs-002--no-hardcoded-passwords-or-credentials) | CRITICAL | No hardcoded passwords or credentials |
| [CS-003](#cs-003--no-use-of-deprecated-or-insecure-functions) | HIGH | No use of deprecated or insecure functions |
| [CS-004](#cs-004--no-direct-commits-to-mainmaster-branch) | HIGH | No direct commits to main/master branch |
| [CS-005](#cs-005--branch-protection-rules-must-be-enabled) | HIGH | Branch protection rules must be enabled |
| [CS-006](#cs-006--code-must-pass-sast-scan-before-merge) | MEDIUM | Code must pass SAST scan before merge |
| [CS-007](#cs-007--no-sensitive-data-in-environment-variables) | MEDIUM | No sensitive data in environment variables |
| [CS-008](#cs-008--code-files-must-have-license-headers) | LOW | Code files must have license headers |
| [CS-009](#cs-009--no-debug-or-test-code-left-in-production-files) | LOW | No debug or test code left in production files |

### Connector Compliance (`harness.connector.compliance`)

| Rule | Severity | Summary |
|---|---|---|
| [CC-001](#cc-001--all-connectors-must-use-secret-references) | CRITICAL | All connectors must use secret references |
| [CC-002](#cc-002--no-expired-connector-credentials-allowed) | CRITICAL | No expired connector credentials allowed |
| [CC-003](#cc-003--connectors-must-use-approved-authentication-types) | HIGH | Connectors must use approved authentication types |
| [CC-004](#cc-004--git-connectors-must-use-ssh-or-token-auth-only) | HIGH | Git connectors must use SSH or token auth only |
| [CC-005](#cc-005--cloud-connectors-must-use-iam-roles-not-keys) | HIGH | Cloud connectors must use IAM roles not keys |
| [CC-006](#cc-006--connectors-must-have-owner-and-team-tags) | MEDIUM | Connectors must have owner and team tags |
| [CC-007](#cc-007--connector-names-must-follow-naming-convention) | MEDIUM | Connector names must follow naming convention |
| [CC-008](#cc-008--connectors-must-have-a-description-field) | LOW | Connectors must have a description field |

### Delegate Validation (`harness.delegate.validation`)

| Rule | Severity | Summary |
|---|---|---|
| [DV-001](#dv-001--delegates-must-be-active-and-connected) | CRITICAL | Delegates must be active and connected |
| [DV-002](#dv-002--delegates-must-run-approved-versions-only) | CRITICAL | Delegates must run approved versions only |
| [DV-003](#dv-003--delegates-must-carry-org-approved-tag) | HIGH | Delegates must carry org-approved tag |
| [DV-004](#dv-004--delegates-must-not-run-as-root-user) | HIGH | Delegates must not run as root user |
| [DV-005](#dv-005--delegate-must-have-resource-limits-defined) | HIGH | Delegate must have resource limits defined |
| [DV-006](#dv-006--delegates-must-be-assigned-to-correct-scope) | MEDIUM | Delegates must be assigned to correct scope |
| [DV-007](#dv-007--delegate-names-must-follow-naming-convention) | MEDIUM | Delegate names must follow naming convention |
| [DV-008](#dv-008--delegates-must-have-owner-and-cost-centre-tags) | LOW | Delegates must have owner and cost-centre tags |

### Pi Guardrails — Bash Security (`pi.guardrails.bash`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-001](#pi-001--pi-agent-bash-security-level-must-be-l4-or-l5-minimum) | CRITICAL | Pi agent bash security level must be L4 or L5 minimum |
| [PI-002](#pi-002--no-unrestricted-bash-tool-access-l1l2l3) | CRITICAL | No unrestricted bash tool access (L1/L2/L3) |
| [PI-003](#pi-003--bash-commands-must-match-approved-whitelist-only) | HIGH | Bash commands must match approved whitelist only |

### Pi Guardrails — Workflow Gates (`pi.guardrails.workflow`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-004](#pi-004--tests-must-pass-before-pr-can-be-opened) | HIGH | Tests must pass before PR can be opened |
| [PI-005](#pi-005--human-approval-gate-must-be-completed-before-pr-is-opened) | HIGH | Human approval gate must be completed before PR is opened |
| [PI-010](#pi-010--all-pi-agent-workflow-steps-must-be-logged) | LOW | All Pi agent workflow steps must be logged |

### Pi Guardrails — Code Standards (`pi.guardrails.code`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-006](#pi-006--pi-generated-code-must-pass-linting) | MEDIUM | Pi-generated code must pass linting |
| [PI-007](#pi-007--no-hardcoded-secrets-api-keys-passwords-or-tokens) | MEDIUM | No hardcoded secrets, API keys, passwords, or tokens |
| [PI-008](#pi-008--pi-generated-code-must-include-at-minimum-one-unit-test-per-function) | MEDIUM | Pi-generated code must include at minimum one unit test per function |
| [PI-009](#pi-009--approved-pi-agent-versions-only) | MEDIUM | Approved Pi agent versions only |

---

## How to Raise a Policy Exception

If an immediate fix is not possible, raise a time-boxed exception:

1. Open a GitHub Issue in this repository with label `policy-exception`
2. Include: rule ID(s), pipeline/resource identifier, business justification, proposed fix date, and risk acknowledgement from the team lead
3. Obtain approval from the Security/Compliance team (CRITICAL/HIGH rules also require CISO sign-off)
4. In the Harness UI go to **Policies → Exceptions**, create an exception scoped to the specific pipeline, set an expiry (max 90 days), and reference the GitHub issue number
5. Track remediation via the issue; remove the exception once the fix is merged

---

## Pipeline Guardrails

---

### PG-001 — Approval gate required before production deploy

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when a pipeline stage targets a production environment (environment type is `Production`, or the environment name starts with `prod`, `production`, or `prd`) and has no approval step (`HarnessApproval`, `JiraApproval`, or `ServiceNowApproval`) in its execution steps.

#### Step-by-step fix

1. Open the pipeline in Harness Studio or your YAML editor.
2. Locate the stage that targets the production environment.
3. Under `spec.execution.steps`, add an approval step **before** any deployment step.
4. Choose the approval type appropriate for your team:
   - `HarnessApproval` — native Harness approval with configurable approvers
   - `JiraApproval` — waits for a Jira issue to reach an approved status
   - `ServiceNowApproval` — waits for a ServiceNow change record to be approved
5. Configure required approvers and approval criteria.
6. Save and re-run the pipeline to confirm the policy passes.

#### Before

```yaml
stages:
  - stage:
      name: deploy-prod
      type: Deployment
      spec:
        infrastructure:
          environment:
            type: Production
            name: prod-eu-west
        execution:
          steps:
            - step:
                name: deploy
                type: K8sRollingDeploy
                spec: {}
```

#### After

```yaml
stages:
  - stage:
      name: deploy-prod
      type: Deployment
      spec:
        infrastructure:
          environment:
            type: Production
            name: prod-eu-west
        execution:
          steps:
            - step:
                name: approve-production-deploy
                type: HarnessApproval
                spec:
                  approvalMessage: "Please review and approve deployment to production."
                  includePipelineExecutionHistory: true
                  approvers:
                    userGroups:
                      - platform-team-leads
                    minimumCount: 1
            - step:
                name: deploy
                type: K8sRollingDeploy
                spec: {}
```

#### Exception guidance

Raise a `policy-exception` issue if a legacy pipeline cannot be refactored immediately. Exceptions for CRITICAL rules require Security team lead + CISO sign-off. Maximum exception duration: 30 days for CRITICAL rules.

---

### PG-002 — No plaintext secrets in pipeline YAML

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when an environment variable in a pipeline step has a name matching a secret key pattern (e.g. `PASSWORD`, `API_KEY`, `SECRET`, `TOKEN`, `ACCESS_KEY`, `PRIVATE_KEY`, `CREDENTIAL`, `AUTH_TOKEN`) and the value does **not** begin with `<+secrets` or `<+pipeline.variables`.

#### Step-by-step fix

1. Identify the step and environment variable flagged in the violation message.
2. Navigate to **Account/Org/Project Settings → Secrets** in Harness.
3. Create a new secret with the secret value.
4. Copy the secret name (e.g. `my-db-password`).
5. In the pipeline YAML, replace the plaintext value with the Harness secret expression:
   ```
   <+secrets.getValue("my-db-password")>
   ```
6. Save the pipeline and verify the step still receives the correct value.

#### Before

```yaml
- step:
    name: run-migration
    type: Run
    spec:
      envVariables:
        DB_PASSWORD: "MyPlaintextPass123!"
        API_KEY: "sk-abc123def456"
```

#### After

```yaml
- step:
    name: run-migration
    type: Run
    spec:
      envVariables:
        DB_PASSWORD: <+secrets.getValue("db-migration-password")>
        API_KEY: <+secrets.getValue("external-api-key")>
```

#### Exception guidance

No exceptions should be granted for this rule. Plaintext secrets in YAML are a direct security exposure. Escalate to the Security team immediately if rotation is needed before remediation.

---

### PG-003 — Container images must use approved registries

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when a step's `spec.image` value does not begin with one of the approved registry prefixes:

- `gcr.io/deloitte-`
- `us-docker.pkg.dev/deloitte-`
- `eu-docker.pkg.dev/deloitte-`
- `index.docker.io/deloitteinternal/`
- `ghcr.io/deloitte-global-cloud-services/`

#### Step-by-step fix

1. Identify the image flagged in the violation (e.g. `nginx:latest`, `python:3.11`).
2. Check the [Internal Container Registry catalogue](#) for an approved equivalent.
3. If an approved image exists, update the pipeline step to reference it:
   - Replace `nginx:latest` → `gcr.io/deloitte-platform/nginx:1.25`
4. If no approved image exists, raise a request with the Platform team to mirror the image into an approved registry.
5. Once mirrored, update the pipeline step to use the mirrored image.
6. Pin images to a specific digest or immutable tag (avoid `latest`).

#### Before

```yaml
- step:
    name: run-tests
    type: Run
    spec:
      image: python:3.11
      command: pytest
```

#### After

```yaml
- step:
    name: run-tests
    type: Run
    spec:
      image: gcr.io/deloitte-platform/python:3.11-approved
      command: pytest
```

#### Exception guidance

Raise a `policy-exception` issue with the image name, use case, and security justification. The Platform team will assess and either mirror the image or provide an alternative within 5 business days.

---

### PG-004 — Pipeline stage timeout must be set

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when:
- A stage does not have a `timeout` field at all, **or**
- The `timeout` value does not match the required format: `<number>(m|h|d)` (e.g. `30m`, `2h`, `1d`)

#### Step-by-step fix

1. Open the pipeline YAML or Harness Studio.
2. Locate each stage that is missing a timeout or has an invalid format.
3. Add or correct the `timeout` field using the format `<number>(m|h|d)`:
   - Minutes: `30m`
   - Hours: `2h`
   - Days: `1d`
4. Choose a timeout appropriate for the stage's expected execution time (add a safety margin of 20–50%).
5. Save and re-run to confirm compliance.

#### Before

```yaml
- stage:
    name: build
    type: CI
    spec: {}
```

#### After

```yaml
- stage:
    name: build
    type: CI
    timeout: 30m
    spec: {}
```

#### Exception guidance

Exceptions are rarely warranted for this rule. If a stage genuinely requires unbounded execution time (e.g. a long-running batch process), document the reason and request a waiver with the maximum acceptable duration stated.

---

### PG-005 — Delegate selector must be specified for deploy stages

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when a stage of type `Deployment` does not have at least one entry in `spec.infrastructure.spec.delegateSelectors`.

#### Step-by-step fix

1. Identify the Deployment stage flagged in the violation.
2. In Harness, navigate to the connector for the target environment and note the delegate tags assigned to it.
3. In the pipeline YAML, add the `delegateSelectors` list under the stage infrastructure spec.
4. Use specific, environment-appropriate delegate tags (see [DV-007](#dv-007--delegate-names-must-follow-naming-convention) for naming convention).

#### Before

```yaml
- stage:
    name: deploy-staging
    type: Deployment
    spec:
      infrastructure:
        spec: {}
```

#### After

```yaml
- stage:
    name: deploy-staging
    type: Deployment
    spec:
      infrastructure:
        spec:
          delegateSelectors:
            - staging-eu-west-delegate-01
```

#### Exception guidance

If the target delegate does not yet exist or is being provisioned, raise an exception with the expected delegate provisioning date. Maximum exception duration: 14 days.

---

### PG-006 — No wildcard delegate selector

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when any entry in `spec.infrastructure.spec.delegateSelectors` is the literal string `"*"`.

#### Step-by-step fix

1. Locate the Deployment stage with the wildcard selector `*`.
2. Replace `*` with one or more specific delegate tags that target the correct environment.
3. Verify the named delegate(s) are online and connected before re-running the pipeline.

#### Before

```yaml
delegateSelectors:
  - "*"
```

#### After

```yaml
delegateSelectors:
  - prod-eu-west-delegate-01
```

#### Exception guidance

No exceptions are granted for wildcard delegate selectors. Using `*` bypasses host-targeting controls and poses a significant security risk. Remediation must be completed before the next pipeline run.

---

### PG-007 — Rollback strategy required for production deployments

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when a `Deployment` stage targeting a production environment either:
- Has no `rollbackSteps` block under `spec.execution`, **or**
- Has a `rollbackSteps` block that is empty (zero entries)

#### Step-by-step fix

1. Open the production Deployment stage in Harness Studio or YAML editor.
2. Under `spec.execution`, add a `rollbackSteps` block.
3. Add at least one rollback step appropriate to the deployment type:
   - Kubernetes rolling: `K8sRollingRollback`
   - Helm: `HelmRollback`
   - ECS: `EcsRollingRollback`
   - Shell Script fallback: a custom `ShellScript` step that restores the previous state
4. Test the rollback path in a non-production environment before relying on it in production.

#### Before

```yaml
spec:
  execution:
    steps:
      - step:
          name: deploy
          type: K8sRollingDeploy
          spec: {}
```

#### After

```yaml
spec:
  execution:
    steps:
      - step:
          name: deploy
          type: K8sRollingDeploy
          spec: {}
    rollbackSteps:
      - step:
          name: rollback-deploy
          type: K8sRollingRollback
          spec: {}
```

#### Exception guidance

Raise a `policy-exception` issue only when the deployment tooling does not natively support automated rollback (e.g. a legacy bespoke deployment mechanism). Include a manual runbook reference as the rollback procedure.

---

### PG-008 — Pipeline must have a description

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when the pipeline root object either:
- Has no `description` field, **or**
- Has a `description` field whose value is blank (empty or whitespace only)

#### Step-by-step fix

1. Open the pipeline in Harness Studio.
2. Click the pipeline name/settings and locate the **Description** field.
3. Enter a clear, meaningful description covering: the pipeline's purpose, the service it deploys or tests, and the team that owns it.
4. Alternatively, add the field directly to the pipeline YAML root.

#### Before

```yaml
pipeline:
  name: Deploy App
  stages: []
```

#### After

```yaml
pipeline:
  name: Deploy App
  description: "Deploys the platform-api service to all environments. Owned by the Platform Engineering team."
  stages: []
```

#### Exception guidance

This is a LOW severity advisory. Exceptions are not required but the description should be added at the earliest opportunity.

---

### PG-009 — Required pipeline tags must be present

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/pipeline-guardrails.rego` |
| **Package** | `harness.pipeline.guardrails` |

#### What triggers this violation

The rule fires when the pipeline `tags` block is missing the `owner` tag, the `cost-centre` tag, or both.

#### Step-by-step fix

1. Open the pipeline in Harness Studio.
2. Navigate to the pipeline **Tags** section (or edit the YAML `tags` block at the pipeline root).
3. Add the missing tags:
   - `owner`: the team or individual responsible for this pipeline (e.g. `platform-team`)
   - `cost-centre`: the billing code for resource attribution (e.g. `CC-1234`)
4. Save and re-run.

#### Before

```yaml
pipeline:
  name: Deploy App
  tags: {}
```

#### After

```yaml
pipeline:
  name: Deploy App
  tags:
    owner: platform-team
    cost-centre: CC-1234
```

#### Exception guidance

LOW severity advisory. Add the tags at the earliest opportunity; no formal exception process is required.

---

## Code Security

---

### CS-001 — No hardcoded API keys or tokens in code

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule scans each file in `input.files` and fires if the file content matches any of the following patterns:
- `api_key` / `apikey` followed by a value of 16+ characters
- `access_token` / `auth_token` followed by a value of 20+ characters
- HTTP Authorization header token value (e.g. `Authorization: Token <value>` patterns)
- AWS access key pattern (`AKIA…`, `AGPA…`, etc.)

#### Step-by-step fix

1. Immediately revoke and rotate the exposed credential in the external system (AWS Console, API provider portal, etc.).
2. Remove the hardcoded value from the source file.
3. Store the new credential in Harness Secret Manager or your organisation's secrets vault.
4. Replace the hardcoded value with a secret reference:
   - In pipeline YAML: `<+secrets.getValue("secret-name")>`
   - In application code: load from environment variable injected by the pipeline
5. Verify the secret reference resolves correctly in a non-production pipeline run.
6. Add the affected file pattern to `.gitignore` if it is a local config file that should never be committed.
7. Audit git history to confirm the credential was not previously committed and is not cached.

#### Before

```python
# config.py
API_KEY = "sk-abc123def456789xyz"
```

#### After

```python
# config.py
import os
API_KEY = os.environ["API_KEY"]  # Injected by Harness pipeline via secret reference
```

Pipeline step:

```yaml
envVariables:
  API_KEY: <+secrets.getValue("external-api-key")>
```

#### Exception guidance

No exceptions. Exposed credentials must be rotated immediately. Contact the Security team for incident response support if the credential was committed to a public repository.

---

### CS-002 — No hardcoded passwords or credentials

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when a file contains patterns such as:
- `password = "..."` / `passwd = "..."` / `pwd = "..."`
- `db_password = "..."` / `database_password = "..."`
- `secret_key = "..."` / `client_secret = "..."`
- `private_key = "-----BEGIN..."`

#### Step-by-step fix

1. Rotate the exposed password or credential immediately.
2. Remove the hardcoded value from the source file.
3. Store the credential in Harness Secret Manager or a vault solution.
4. Inject the credential at runtime via an environment variable reference.
5. Audit git history using `git log -p --all -S "hardcoded-value"` to confirm no cached copies remain, then use `git filter-repo` or BFG Repo Cleaner if history must be purged.

#### Before

```yaml
# docker-compose.yml
environment:
  DB_PASSWORD: "SuperSecret123"
```

#### After

```yaml
# docker-compose.yml
environment:
  DB_PASSWORD: "${DB_PASSWORD}"  # Provided by CI/CD pipeline secret injection
```

#### Exception guidance

No exceptions. Rotate immediately, then remediate. Contact Security for assistance if needed.

---

### CS-003 — No use of deprecated or insecure functions

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when a source file contains calls to any of the following:

| Function | Risk |
|---|---|
| `eval()` | Code injection |
| `exec()` | Command injection |
| `System.exit()` | Abrupt termination |
| `MD5()` | Cryptographically broken hash |
| `SHA1()` | Cryptographically weak hash |
| `DES()` | Deprecated cipher |
| `RC4()` | Deprecated stream cipher |
| `pickle.load()` / `pickle.loads()` | Unsafe deserialisation |
| `deserialize()` | Unsafe deserialisation |

#### Step-by-step fix

1. Locate the flagged function call in the source file.
2. Replace with the approved alternative:

| Deprecated | Approved Alternative |
|---|---|
| `MD5`, `SHA1` | `SHA-256`, `SHA-3` (via `hashlib` in Python, `crypto` in Node.js, `java.security.MessageDigest` with `SHA-256`) |
| `DES`, `RC4` | `AES-256-GCM` or `ChaCha20-Poly1305` |
| `eval()` | Rewrite logic to avoid dynamic code evaluation; use a safe parser/AST library |
| `exec()` | Use a subprocess library with argument lists (not shell strings); validate all inputs |
| `pickle.load()` | Use `json.loads()`, `yaml.safe_load()`, or a schema-validated deserialiser |

3. Run unit tests to confirm functional equivalence.
4. Update any dependent test files.

#### Before (Python)

```python
import hashlib
digest = hashlib.md5(data).hexdigest()
```

#### After (Python)

```python
import hashlib
digest = hashlib.sha256(data).hexdigest()
```

#### Exception guidance

Raise a `policy-exception` issue with a detailed justification (e.g. a third-party library that internally uses MD5 for a non-security purpose). Include a plan to migrate to a supported library version that removes the dependency.

---

### CS-004 — No direct commits to main/master branch

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when a commit targets the `main` or `master` branch and is not a merge commit.

#### Step-by-step fix

1. Do not push directly to `main` or `master`. If you have already done so:
   a. Revert the direct commit if the code is not yet deployed.
   b. Cherry-pick the changes onto a feature branch.
2. Raise a pull request from the feature branch.
3. Obtain the required number of reviews (see `policy-guide.md §8`).
4. Merge via the pull request — the merge commit satisfies the `is_merge_commit` check.
5. To prevent future direct pushes, enable branch protection rules (see [CS-005](#cs-005--branch-protection-rules-must-be-enabled)).

#### Before

```bash
# Direct push to main — VIOLATION
git checkout main
git commit -m "hotfix: patch critical bug"
git push origin main
```

#### After

```bash
# Feature branch → pull request → merge
git checkout -b hotfix/critical-bug-patch
git commit -m "hotfix: patch critical bug"
git push origin hotfix/critical-bug-patch
# Open PR and merge via GitHub/Harness Code
```

#### Exception guidance

Emergency hotfixes require the same process — use a `hotfix/` branch and expedite the pull request review. Contact the Security team lead for emergency fast-track approval. Maximum time to open a PR after an emergency direct push: 2 hours.

---

### CS-005 — Branch protection rules must be enabled

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when:
- `repository.branch_protection.enabled` is `false` or missing, **or**
- Branch protection is enabled but `require_pull_request_reviews` is `false`

#### Step-by-step fix

**GitHub:**

1. Go to **Repository Settings → Branches**.
2. Click **Add rule** (or edit the existing rule for `main`/`master`).
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (set minimum to 1 or per team policy)
   - ✅ Require status checks to pass before merging
   - ✅ Do not allow bypassing the above settings
4. Click **Save changes**.

**Harness Code:**

1. Go to **Repository Settings → Branch Rules**.
2. Add or update the rule for the default branch.
3. Enable pull request reviews and required status checks.

#### Before

Branch protection: disabled

#### After

Branch protection settings:

```
✅ Require pull request before merging
✅ Required approvals: 1
✅ Dismiss stale reviews when new commits are pushed
✅ Require status checks to pass (e.g. build, SAST)
✅ Block force pushes
```

#### Exception guidance

No exceptions for this rule on the default branch. For non-default branches, raise a `policy-exception` issue with a documented justification.

---

### CS-006 — Code must pass SAST scan before merge

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when `input.pull_request.checks.sast.passed` is `false` or absent, meaning the SAST pipeline check either failed or has not yet run for the pull request.

#### Step-by-step fix

1. Navigate to the pull request checks section and locate the SAST check.
2. If the check has not run: trigger it manually or push a new commit to re-trigger the pipeline.
3. If the check failed:
   a. Open the SAST report (linked from the check detail page).
   b. Review each finding — severity, file, and line number.
   c. Remediate or suppress (with justification) each finding.
   d. Push updated code to re-trigger the SAST scan.
4. Repeat until the SAST check reports a passing status.
5. Do not merge until `checks.sast.passed` is `true`.

#### Before

```json
"checks": {
  "sast": { "passed": false, "findings": 3 }
}
```

#### After

```json
"checks": {
  "sast": { "passed": true, "findings": 0 }
}
```

#### Exception guidance

Raise a `policy-exception` issue if a SAST finding is a confirmed false positive. Include the tool name, finding ID, reason for false positive determination, and Security team acknowledgement.

---

### CS-007 — No sensitive data in environment variables

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when an environment variable key matches a sensitive name pattern (e.g. `PASSWORD`, `SECRET`, `TOKEN`, `API_KEY`, `PRIVATE_KEY`, `CLIENT_SECRET`, `AUTH`, `CREDENTIAL`, `CONNECTION_STRING`, `DB_URL`) and the value does not begin with a secrets manager expression (`<+secrets`, `${{`, or `$(`).

#### Step-by-step fix

1. Identify the environment variable key and its current plaintext value.
2. Store the value in Harness Secret Manager:
   - Go to **Secrets → New Secret → Secret Text**
   - Enter a descriptive name and the secret value
3. Replace the environment variable value with the secret reference.
4. Verify the application receives the correct value at runtime.

#### Before

```yaml
environment:
  variables:
    DB_CONNECTION_STRING: "dbuser:S3cr3tV4lu3@db-host:5432/mydb"
    CLIENT_SECRET: "abc123xyz789"
```

#### After

```yaml
environment:
  variables:
    DB_CONNECTION_STRING: <+secrets.getValue("db-connection-string")>
    CLIENT_SECRET: <+secrets.getValue("oauth-client-secret")>
```

#### Exception guidance

Raise a `policy-exception` issue if the variable is used in a context where Harness secret expressions cannot be resolved (e.g. a custom plugin step). Include the technical constraint and a proposed alternative secure delivery mechanism.

---

### CS-008 — Code files must have license headers

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires for source files with extensions `.go`, `.py`, `.js`, `.ts`, `.java`, `.cs`, `.cpp`, `.c`, `.rb`, `.sh` that do not contain the patterns `copyright`, `spdx-license-identifier`, or `licensed under` (case-insensitive).

#### Step-by-step fix

1. Identify the source file(s) missing the license header.
2. Add the organisation-approved license header as the **first comment block** in the file.
3. Use one of the approved header formats:

**SPDX format (preferred):**

```python
# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 Deloitte Global Cloud Services
```

**Full copyright block:**

```go
// Copyright 2024 Deloitte Global Cloud Services
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
```

4. Consider adding a pre-commit hook or CI step to enforce headers on all new files automatically (e.g. `addlicense` tool).

#### Before

```python
import os
import sys

def main():
    pass
```

#### After

```python
# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 Deloitte Global Cloud Services

import os
import sys

def main():
    pass
```

#### Exception guidance

LOW severity advisory. Add headers during the next planned sprint. No formal exception is required.

---

### CS-009 — No debug or test code left in production files

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/code-security.rego` |
| **Package** | `harness.code.security` |

#### What triggers this violation

The rule fires when a production source file contains any of:

| Pattern | Meaning |
|---|---|
| `console.log(` | JavaScript debug logging |
| `print("debug...` | Debug print statement |
| `debugger` | JavaScript debugger breakpoint |
| `# TODO` / `// TODO` / `/* TODO` | Unresolved to-do comment |
| `# FIXME` / `// FIXME` | Unresolved fix-me comment |
| `pdb.set_trace()` | Python interactive debugger |
| `ipdb.set_trace()` | Python IPython debugger |

#### Step-by-step fix

1. Remove or replace all flagged statements:
   - Replace `console.log` debugging with structured logger calls (e.g. `logger.debug(...)`)
   - Remove `debugger` statements
   - Remove `pdb.set_trace()` / `ipdb.set_trace()` calls
2. Resolve or create tracked issues for `TODO` and `FIXME` comments:
   - If the work can be done now: do it and remove the comment
   - If the work is deferred: create a GitHub Issue and replace the comment with `// See issue #<N>` or remove the comment entirely
3. Run the project linter to catch any remaining instances before pushing.

#### Before

```javascript
function processPayment(amount) {
  console.log("Processing payment:", amount); // TODO: add proper logging
  debugger;
  return charge(amount);
}
```

#### After

```javascript
function processPayment(amount) {
  logger.info("Processing payment", { amount });
  return charge(amount);
}
```

#### Exception guidance

LOW severity advisory. Remove debug code before merging to the default branch. No formal exception is required.

---

## Connector Compliance

---

### CC-001 — All connectors must use secret references

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when a connector's `spec.credentials` contains a field whose name matches a credential pattern (password, token, api_key, access_key, secret, private_key, client_secret, certificate) and the value does not begin with `<+secrets` or `${ngSecretManager`.

#### Step-by-step fix

1. Identify the connector identifier and credential field from the violation message.
2. Navigate to **Harness → Connectors** and open the flagged connector.
3. For each plaintext credential field:
   a. Create or locate the corresponding Harness Secret (Account/Org/Project scope as appropriate).
   b. Edit the connector and replace the plaintext value with the secret reference using `<+secrets.getValue("secret-name")>`.
4. Test the connector connectivity using the **Test Connection** button.
5. Save the connector.

#### Before

```yaml
spec:
  credentials:
    password: "MyPlaintextPassword"
    token: "ghp_abc123def456"
```

#### After

```yaml
spec:
  credentials:
    password: <+secrets.getValue("github-connector-password")>
    token: <+secrets.getValue("github-personal-access-token")>
```

#### Exception guidance

No exceptions. Plaintext connector credentials are an immediate security risk. Rotate and remediate immediately.

---

### CC-002 — No expired connector credentials allowed

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when `connector.spec.credentials.expiry_date` is a valid RFC3339 timestamp that is in the past relative to the current time.

#### Step-by-step fix

1. Identify the connector identifier and expiry date from the violation message.
2. Rotate the credential in the external system:
   - **AWS:** Generate a new IAM access key and secret; deactivate the old key.
   - **GitHub:** Generate a new personal access token or GitHub App installation token.
   - **Azure:** Rotate the service principal secret in Azure AD.
   - **GCP:** Create a new service account key (or switch to Workload Identity — see [CC-005](#cc-005--cloud-connectors-must-use-iam-roles-not-keys)).
3. Update the corresponding Harness Secret with the new credential value.
4. Open the connector in Harness, update the expiry date to the new credential's expiry, and test connectivity.
5. Set a calendar reminder or pipeline alert to renew the credential before the next expiry.

#### Before

```yaml
spec:
  credentials:
    token: <+secrets.getValue("github-token")>
    expiry_date: "2024-01-01T00:00:00Z"  # EXPIRED
```

#### After

```yaml
spec:
  credentials:
    token: <+secrets.getValue("github-token-rotated")>
    expiry_date: "2025-06-01T00:00:00Z"  # Updated
```

#### Exception guidance

No exceptions. Expired credentials may cause active pipeline failures. Remediation must happen before the next pipeline execution.

---

### CC-003 — Connectors must use approved authentication types

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when `connector.spec.authentication.type` is not one of the approved types:

`ServiceAccountToken`, `OpenIDConnect`, `IAMRole`, `IRSA`, `WorkloadIdentity`, `SSHKey`, `GitHubApp`, `OAuth`, `BearerToken`

#### Step-by-step fix

1. Identify the connector and its current authentication type from the violation message.
2. Determine the appropriate approved authentication type for the connector's target system:

| Target System | Recommended Auth Type |
|---|---|
| Kubernetes cluster | `ServiceAccountToken` or `IRSA` |
| AWS | `IAMRole` or `IRSA` |
| GCP | `WorkloadIdentity` |
| Azure | `WorkloadIdentity` |
| GitHub | `GitHubApp` or `OAuth` |
| SSH hosts | `SSHKey` |
| Generic HTTP APIs | `BearerToken` or `OAuth` |

3. Reconfigure the connector to use the approved type.
4. Update or create the corresponding credentials/secrets in Harness Secret Manager.
5. Test the connector connection.

#### Before

```yaml
spec:
  authentication:
    type: BasicAuth
    username: my-user
    password: <+secrets.getValue("my-password")>
```

#### After

```yaml
spec:
  authentication:
    type: BearerToken
    token: <+secrets.getValue("api-bearer-token")>
```

#### Exception guidance

Raise a `policy-exception` issue if a third-party system only supports a non-approved auth type. Include the system name, why approved auth types are not available, and a plan to migrate when the vendor adds support.

---

### CC-004 — Git connectors must use SSH or token auth only

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when a connector of type `Github`, `Gitlab`, `Bitbucket`, `AzureRepo`, or `Codecommit` uses `UsernamePassword` or `BasicAuth` authentication.

#### Step-by-step fix

**Switching to SSH key authentication:**

1. Generate an SSH key pair if you do not already have one:
   ```bash
   ssh-keygen -t ed25519 -C "harness-connector@deloitte.com"
   ```
2. Add the public key to the Git provider (GitHub: **Settings → SSH and GPG keys**).
3. Store the private key as a Harness Secret (type: **SSH Key**).
4. Update the connector authentication type to `SSHKey` and reference the secret.
5. Test the connector.

**Switching to token (HTTP) authentication:**

1. Generate a personal access token or GitHub App token with the minimum required scopes.
2. Store the token in Harness Secret Manager.
3. Update the connector authentication type to `BearerToken` or `OAuth` and reference the secret.

#### Before

```yaml
spec:
  authentication:
    type: UsernamePassword
    username: my-git-user
    password: <+secrets.getValue("git-password")>
```

#### After

```yaml
spec:
  authentication:
    type: BearerToken
    token: <+secrets.getValue("github-pat-token")>
```

#### Exception guidance

No exceptions. Username/password authentication for Git connectors is deprecated by all major Git providers. Migrate to SSH or token immediately.

---

### CC-005 — Cloud connectors must use IAM roles not keys

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when a connector of type `Aws`, `Gcp`, or `Azure` uses credential type `ManualConfig`, `AccessKey`, `ServiceAccountKey`, or `ServicePrincipalSecret` (all of which use static long-lived credentials).

#### Step-by-step fix

**AWS:**

1. Create an IAM role with the minimum required permissions for the connector's purpose.
2. Assign the role to the Harness Delegate (EC2 instance profile, EKS IRSA, or ECS task role).
3. Reconfigure the AWS connector to use `IAMRole` or `IRSA` credential type.
4. Remove the static access key from IAM and from Harness.

**GCP:**

1. Configure Workload Identity for the GCP project.
2. Bind the Kubernetes service account used by the Harness Delegate to a GCP IAM service account.
3. Reconfigure the GCP connector to use `WorkloadIdentity`.
4. Delete the service account key.

**Azure:**

1. Assign a Managed Identity to the Azure resource running the Harness Delegate.
2. Grant the required Azure RBAC permissions to the Managed Identity.
3. Reconfigure the Azure connector to use `WorkloadIdentity` (Managed Identity).
4. Revoke the service principal secret.

#### Before

```yaml
spec:
  credential:
    type: ManualConfig
    access_key: <+secrets.getValue("aws-access-key-id")>
    secret_key: <+secrets.getValue("aws-secret-access-key")>
```

#### After

```yaml
spec:
  credential:
    type: IAMRole
    role_arn: "arn:aws:iam::123456789012:role/harness-delegate-role"
```

#### Exception guidance

Raise a `policy-exception` issue if the Delegate is running in an environment that does not support role-based authentication (e.g. on-premises). Include the infrastructure details and a migration timeline.

---

### CC-006 — Connectors must have owner and team tags

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when a connector's `tags` map is missing the `owner` key, the `team` key, or both.

#### Step-by-step fix

1. Open the connector in Harness (**Connectors → [connector name] → Edit**).
2. Navigate to the **Tags** section.
3. Add the missing tags:
   - `owner`: the individual or team responsible for this connector (e.g. `platform-team`)
   - `team`: the team that owns the connected resource (e.g. `data-engineering`)
4. Save the connector.

#### Before

```yaml
tags: {}
```

#### After

```yaml
tags:
  owner: platform-team
  team: data-engineering
```

#### Exception guidance

MEDIUM severity. Add tags at the earliest opportunity. Formal exception not required but recommended within 2 weeks.

---

### CC-007 — Connector names must follow naming convention

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when the connector `identifier` does not match the pattern:

```
^[a-z][a-z0-9]*(-[a-z0-9]+){2,}$
```

This requires at least three hyphen-separated segments (e.g. `aws-prod-main`, `github-dev-frontend`).

#### Step-by-step fix

1. Determine the correct name following the convention: `<type>-<environment>-<descriptor>`
   - Examples: `aws-prod-main`, `github-dev-app`, `gcp-staging-data-pipeline`
2. In the Harness UI, rename the connector identifier to match the convention.
3. Update all pipeline YAML references that use the old connector identifier.
4. Test pipelines that reference the renamed connector to confirm they still resolve correctly.

#### Before

```yaml
identifier: MyGitHubConnector
```

#### After

```yaml
identifier: github-prod-platform-app
```

#### Exception guidance

Raise a `policy-exception` issue if renaming the connector would require a large number of pipeline updates and a migration window is needed. Maximum exception duration: 30 days.

---

### CC-008 — Connectors must have a description field

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/connector-compliance.rego` |
| **Package** | `harness.connector.compliance` |

#### What triggers this violation

The rule fires when a connector either:
- Has no `description` field, **or**
- Has a `description` field that is blank (empty or whitespace only)

#### Step-by-step fix

1. Open the connector in Harness and navigate to the **Description** field.
2. Enter a clear description covering: what the connector connects to, its purpose, and the owning team.
3. Save the connector.

#### Before

```yaml
identifier: aws-prod-main
description: ""
```

#### After

```yaml
identifier: aws-prod-main
description: "AWS connector for the production account (123456789012). Used by the Platform team for EKS deployments. Owned by platform-team."
```

#### Exception guidance

LOW severity advisory. Add the description at the earliest opportunity.

---

## Delegate Validation

---

### DV-001 — Delegates must be active and connected

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when:
- A delegate's `status` is not `ENABLED`, **or**
- A delegate is `ENABLED` but `connected` is `false`

#### Step-by-step fix

**Delegate not ENABLED:**

1. SSH into the host or cluster running the delegate.
2. Check delegate process status:
   ```bash
   # For Kubernetes delegate
   kubectl get pods -n harness-delegate-ng
   kubectl describe pod <delegate-pod>
   kubectl logs <delegate-pod> --tail=100
   ```
3. Look for startup errors: invalid delegate token, network unreachability, or resource exhaustion.
4. Restart the delegate pod / process:
   ```bash
   kubectl rollout restart deployment/<delegate-deployment> -n harness-delegate-ng
   ```
5. Verify the delegate token in Harness matches the token configured in the delegate YAML.

**Delegate ENABLED but not connected:**

1. Verify outbound connectivity from the delegate host to `app.harness.io:443`.
2. Check firewall and proxy rules — the delegate must reach Harness Manager.
3. Inspect delegate logs for connection timeout or TLS errors.
4. If behind a proxy, ensure `PROXY_HOST`, `PROXY_PORT`, and `PROXY_USER` are set in the delegate YAML.

#### Before

```json
{ "name": "prod-eu-west-delegate-01", "status": "DISABLED", "connected": false }
```

#### After

```json
{ "name": "prod-eu-west-delegate-01", "status": "ENABLED", "connected": true }
```

#### Exception guidance

No exceptions. A disconnected delegate will cause all pipelines that target it to fail. This is an operational incident — page the on-call delegate operator immediately.

---

### DV-002 — Delegates must run approved versions only

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when `delegate.version` is not present in `input.policy.approved_delegate_versions` — the organisation's allowlist of delegate versions.

#### Step-by-step fix

1. Check the current approved delegate versions list (maintained in Harness Policy input or a shared configuration file).
2. Identify the target approved version.
3. Upgrade the delegate:

**Kubernetes delegate (Helm):**

```bash
helm upgrade harness-delegate harness/harness-delegate \
  --namespace harness-delegate-ng \
  --set delegateToken=<token> \
  --set delegateName=prod-eu-west-delegate-01 \
  --set image.tag=<approved-version>
```

**Docker delegate:**

```bash
docker pull harness/delegate:<approved-version>
docker stop harness-delegate && docker rm harness-delegate
# Re-run docker run with the new image tag
```

4. Verify the new version appears in the Harness Delegates list.
5. Run a test pipeline to confirm the upgraded delegate executes tasks correctly.

#### Before

```yaml
# delegate.yaml
image: harness/delegate:23.10.81202  # Non-approved version
```

#### After

```yaml
# delegate.yaml
image: harness/delegate:24.06.83200  # Approved version
```

#### Exception guidance

Raise a `policy-exception` issue if the upgrade requires a maintenance window or compatibility testing with connected infrastructure. Maximum exception duration: 14 days for CRITICAL rules.

---

### DV-003 — Delegates must carry org-approved tag

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when `"org-approved"` is not present in the delegate's `tags` array.

#### Step-by-step fix

1. Complete the delegate onboarding checklist (security review, connectivity verification, version approval).
2. Once the checklist is complete and signed off by the Security team:
   a. In the Harness UI go to **Delegates → [delegate name] → Tags**.
   b. Add the tag `org-approved`.
3. Alternatively, add the tag to the delegate YAML spec and redeploy.

#### Before

```yaml
tags:
  - owner: platform-team
  - cost-centre: CC-1234
# Missing: org-approved
```

#### After

```yaml
tags:
  - owner: platform-team
  - cost-centre: CC-1234
  - org-approved
```

#### Exception guidance

Raise a `policy-exception` issue if the delegate is in the process of completing the security review. Include the review start date and expected completion date. Maximum exception duration: 7 days.

---

### DV-004 — Delegates must not run as root user

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when:
- `delegate.security_context.run_as_user == 0` (delegate running as root UID), **or**
- `delegate.security_context.privileged == true` (delegate running in privileged mode)

#### Step-by-step fix

**Set non-root UID:**

1. Update the delegate Kubernetes deployment or Helm values to set a non-root `runAsUser`:

```yaml
# values.yaml (Helm)
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

2. Redeploy the delegate and verify it starts successfully.
3. If the delegate fails to start with a non-root UID, identify which directories or files require root ownership and fix the permissions.

**Remove privileged mode:**

1. Set `privileged: false` in the container security context.
2. Identify capabilities that previously required privileged mode.
3. Grant only the specific Linux capabilities needed (e.g. `NET_ADMIN` instead of `privileged: true`).

#### Before

```yaml
securityContext:
  runAsUser: 0
  privileged: true
```

#### After

```yaml
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
  privileged: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

#### Exception guidance

Raise a `policy-exception` issue if a specific tool used by the delegate requires root (e.g. Docker-in-Docker). Include the tool name, its purpose, and an alternative approach (e.g. Kaniko for container builds instead of Docker-in-Docker).

---

### DV-005 — Delegate must have resource limits defined

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when `delegate.resources.limits.cpu` or `delegate.resources.limits.memory` is absent.

#### Step-by-step fix

1. Refer to the [Harness delegate sizing guide](https://developer.harness.io/docs/platform/delegates/delegate-concepts/delegate-requirements/) for recommended resource values.
2. Update the delegate deployment YAML or Helm values to include resource limits:

```yaml
resources:
  limits:
    cpu: "1"
    memory: "2Gi"
  requests:
    cpu: "500m"
    memory: "1Gi"
```

3. Redeploy the delegate and monitor its resource usage under normal load.
4. Adjust limits if the delegate is consistently hitting them (check `kubectl top pod` or Harness delegate metrics).

#### Before

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  # No limits defined
```

#### After

```yaml
resources:
  limits:
    cpu: "1"
    memory: "2Gi"
  requests:
    cpu: "500m"
    memory: "1Gi"
```

#### Exception guidance

Raise a `policy-exception` issue if the delegate is running in a resource-constrained environment where limits would cause unnecessary throttling. Include current resource usage data to justify the exception.

---

### DV-006 — Delegates must be assigned to correct scope

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when:
- `delegate.scope.type` is not one of `ACCOUNT`, `ORG`, or `PROJECT`, **or**
- `delegate.scope.type` is `PROJECT` but `delegate.scope.project_identifier` is not set

#### Step-by-step fix

1. Determine the intended scope for the delegate:
   - `ACCOUNT` — accessible to all orgs and projects within the account
   - `ORG` — accessible to all projects within a specific organisation
   - `PROJECT` — accessible only to a specific project

2. In the Harness UI (**Delegates → [delegate name] → Edit**), set the scope accordingly.

3. If scoping to a project, set the `project_identifier` to the target project's unique identifier.

4. Redeploy the delegate if scope changes require YAML updates.

#### Before

```yaml
scope:
  type: INVALID_SCOPE
```

#### After

```yaml
scope:
  type: PROJECT
  project_identifier: platform-api-prod
```

#### Exception guidance

MEDIUM severity. Ensure the delegate scope is set before it is used in production pipelines. Formal exception not required but scope must be set within 5 business days.

---

### DV-007 — Delegate names must follow naming convention

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when the delegate `name` does not match the pattern:

```
^[a-z][a-z0-9]*(-[a-z0-9]+)*-delegate-[0-9]{2,}$
```

The expected format is: `<environment>-<region>-delegate-<nn>` (e.g. `prod-eu-west-delegate-01`).

#### Step-by-step fix

1. Determine the correct name: `<environment>-<region>-delegate-<nn>`
   - Examples: `prod-eu-west-delegate-01`, `dev-us-east-delegate-02`, `staging-ap-southeast-delegate-01`
2. In Harness, rename the delegate via **Delegates → [delegate name] → Edit → Name**.
3. Update all pipeline YAML files that reference the old delegate name in `delegateSelectors`.
4. Run a test pipeline to confirm the renamed delegate is still targeted correctly.

#### Before

```yaml
name: MyProductionDelegate
```

#### After

```yaml
name: prod-eu-west-delegate-01
```

#### Exception guidance

Raise a `policy-exception` issue if renaming requires a coordinated pipeline update across many teams. Maximum exception duration: 30 days.

---

### DV-008 — Delegates must have owner and cost-centre tags

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/opa/delegate-validation.rego` |
| **Package** | `harness.delegate.validation` |

#### What triggers this violation

The rule fires when the delegate's `tags` array contains no entry for the `owner` tag, the `cost-centre` tag, or both. Both bare-key format (`"owner"`) and key:value format (`"owner:platform-team"`) are accepted.

#### Accepted tag formats

| Format | Example | Accepted? |
|---|---|---|
| Bare key | `owner` | ✅ Yes |
| Key:value | `owner:platform-team` | ✅ Yes |
| Missing entirely | _(not present)_ | ❌ Violation |

#### Step-by-step fix

1. Open the delegate in Harness (**Delegates → [delegate name] → Tags**).
2. Add the missing tags in either bare-key or key:value format:
   - `owner` or `owner:<team>`: the team responsible for the delegate (e.g. `owner:platform-team`)
   - `cost-centre` or `cost-centre:<code>`: the billing code for delegate infrastructure costs (e.g. `cost-centre:CC-1234`)
3. Alternatively, add the tags to the delegate YAML spec and redeploy:

```yaml
tags:
  - org-approved
  - 'owner:platform-team'
  - 'cost-centre:CC-1234'
```

4. Save or redeploy.

#### Before

```json
{
  "name": "prod-eu-west-delegate-01",
  "tags": ["org-approved"]
}
```

#### After (key:value format)

```json
{
  "name": "prod-eu-west-delegate-01",
  "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-1234"]
}
```

#### After (bare-key format)

```json
{
  "name": "prod-eu-west-delegate-01",
  "tags": ["org-approved", "owner", "cost-centre"]
}
```

#### Exception guidance

LOW severity advisory. Add the tags at the earliest opportunity. No formal exception required.

---

---

## Pi Guardrails

Pi Guardrail policies enforce bash security levels, code quality standards, workflow gates, and audit logging for Pi coding agent (pi.dev) workflows.

---

### Pi Guardrails (`pi.guardrails.bash`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-001](#pi-001--pi-agent-bash-security-level-must-be-l4-or-l5-minimum) | CRITICAL | Pi agent bash security level must be L4 or L5 minimum |
| [PI-002](#pi-002--no-unrestricted-bash-tool-access-l1l2l3) | CRITICAL | No unrestricted bash tool access (L1/L2/L3) |
| [PI-003](#pi-003--bash-commands-must-match-approved-whitelist-only) | HIGH | Bash commands must match approved whitelist only |

### Pi Guardrails (`pi.guardrails.workflow`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-004](#pi-004--tests-must-pass-before-pr-can-be-opened) | HIGH | Tests must pass before PR can be opened |
| [PI-005](#pi-005--human-approval-gate-must-be-completed-before-pr-is-opened) | HIGH | Human approval gate must be completed before PR is opened |

### Pi Guardrails (`pi.guardrails.code`)

| Rule | Severity | Summary |
|---|---|---|
| [PI-006](#pi-006--pi-generated-code-must-pass-linting) | MEDIUM | Pi-generated code must pass linting |
| [PI-007](#pi-007--no-hardcoded-secrets-api-keys-passwords-or-tokens) | MEDIUM | No hardcoded secrets, API keys, passwords, or tokens |
| [PI-008](#pi-008--pi-generated-code-must-include-at-minimum-one-unit-test-per-function) | MEDIUM | Pi-generated code must include at minimum one unit test per function |
| [PI-009](#pi-009--approved-pi-agent-versions-only) | MEDIUM | Approved Pi agent versions only |
| [PI-010](#pi-010--all-pi-agent-workflow-steps-must-be-logged) | LOW | All Pi agent workflow steps must be logged |

---

### PI-001 — Pi agent bash security level must be L4 or L5 minimum

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/pi/bash-security.rego` |
| **Package** | `pi.guardrails.bash` |

#### What triggers this violation

The rule fires when `input.pi_agent.bash_security_level` is set to any value other than `L4` or `L5`. The Pi agent must operate with a whitelist-only (`L4`) or no-bash (`L5`) configuration at all times.

#### Bash security level reference

| Level | Description | Status |
|---|---|---|
| L1 | User prompt — unrestricted | ❌ BLOCKED |
| L2 | System prompt — unrestricted | ❌ BLOCKED |
| L3 | LLM-filtered — unrestricted | ❌ BLOCKED |
| L4 | Whitelist only | ✅ MINIMUM REQUIRED |
| L5 | No bash access | ✅ PERMITTED |

#### Step-by-step fix

1. Open the Pi agent configuration file for your workflow.
2. Locate the `bash_security_level` setting.
3. Set it to `L4` (whitelist only) or `L5` (no bash access).
4. Save and re-trigger the workflow.
5. Confirm the security level is reported correctly in the Pi agent startup logs.

#### Before

```yaml
pi_agent:
  bash_security_level: L2
```

#### After

```yaml
pi_agent:
  bash_security_level: L4
```

#### Exception guidance

CRITICAL severity. No exceptions permitted. Escalate to the Security team immediately if a business case exists for a lower level.

---

### PI-002 — No unrestricted bash tool access (L1/L2/L3)

| | |
|---|---|
| **Severity** | CRITICAL |
| **Policy file** | `policies/pi/bash-security.rego` |
| **Package** | `pi.guardrails.bash` |

#### What triggers this violation

The rule fires when `input.pi_agent.bash_security_level` is explicitly set to `L1`, `L2`, or `L3`. These levels allow unrestricted bash command execution and are prohibited regardless of context.

#### Step-by-step fix

1. Immediately stop any running Pi agent workflow operating at L1, L2, or L3.
2. Reconfigure the agent to `L4` (whitelist only) or `L5` (no bash).
3. Audit recent workflow runs executed at the prohibited level for unexpected commands.
4. Remove any pipeline steps or scripts that rely on unrestricted bash execution.
5. Re-run the workflow and confirm the guardrail reports PASS.

#### Before

```yaml
pi_agent:
  bash_security_level: L1
```

#### After

```yaml
pi_agent:
  bash_security_level: L4
```

#### Exception guidance

CRITICAL severity. No exceptions permitted. Any workflow found operating at L1/L2/L3 must be halted immediately and reported to the Security team for incident review.

---

### PI-003 — Bash commands must match approved whitelist only

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/pi/bash-security.rego` |
| **Package** | `pi.guardrails.bash` |

#### What triggers this violation

The rule fires when a bash command in `input.pi_agent.bash_commands` is not on the organisation-approved whitelist, or matches a blocked pattern.

#### Approved commands

`pytest`, `pip install`, `git add`, `git commit`, `git push`, `gh pr create`, `echo`, `cat`, `ls`, `mkdir`, `cp`, `mv`

#### Blocked patterns

`rm -rf`, `curl`, `wget`, `chmod 777`, `sudo`, `eval`, `exec`, `os.system(...)`, `subprocess.run(..., shell=True)`

#### Step-by-step fix

1. Review the Pi agent workflow definition and identify any commands not on the whitelist.
2. Remove or replace non-whitelisted commands:
   - Replace `curl`/`wget` downloads with pre-baked Docker images or Harness pipeline steps.
   - Replace `rm -rf` with targeted file removal using approved tools.
   - Replace `subprocess.run(shell=True)` with explicit argument lists (no shell).
3. Submit a whitelist extension request to the platform team if a new command is genuinely needed, with a security justification.
4. Re-run the workflow and confirm PASS.

#### Before

```yaml
bash_commands:
  - "curl https://example.com/install.sh | bash"
  - "rm -rf /tmp/build"
```

#### After

```yaml
bash_commands:
  - "pip install my-package==1.2.3"
  - "pytest tests/"
```

#### Exception guidance

HIGH severity. Raise a `policy-exception` issue with a security justification if a whitelisted command cannot cover the required use case. Maximum exception duration: 14 days.

---

### PI-004 — Tests must pass before PR can be opened

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/pi/workflow-gates.rego` |
| **Package** | `pi.guardrails.workflow` |

#### What triggers this violation

The rule fires when the Pi agent workflow attempts to execute `gh pr create` before a `pytest` step has run and completed with `outcome: pass` and `tests_passed: true`. The ordering is enforced by step index.

#### Step-by-step fix

1. Open the Pi agent workflow definition.
2. Ensure `pytest` (or equivalent test runner) appears **before** `gh pr create` in the `workflow_steps` list.
3. Configure the workflow so that `gh pr create` is only executed when the test step exits with code 0.
4. Add `tests_passed: true` and `outcome: pass` to the test step log entry.
5. Re-run the workflow and confirm PASS.

#### Before

```yaml
workflow_steps:
  - action: "gh pr create"
    outcome: pass
  - action: "pytest"
    outcome: pass
    tests_passed: true
```

#### After

```yaml
workflow_steps:
  - action: "pytest"
    outcome: pass
    tests_passed: true
    timestamp: "2026-06-08T07:00:00Z"
  - action: "gh pr create"
    outcome: pass
    timestamp: "2026-06-08T07:01:00Z"
```

#### Exception guidance

HIGH severity. No exceptions for ordering. If tests cannot run in the Pi agent environment, raise a `policy-exception` issue with a risk acknowledgement and a plan to add test coverage. Maximum exception duration: 7 days.

---

### PI-005 — Human approval gate must be completed before PR is opened

| | |
|---|---|
| **Severity** | HIGH |
| **Policy file** | `policies/pi/workflow-gates.rego` |
| **Package** | `pi.guardrails.workflow` |

#### What triggers this violation

The rule fires when `input.pi_agent.human_approval_completed` is `false` or absent at the time `gh pr create` is attempted. No automated PR may be opened without explicit human sign-off.

#### Step-by-step fix

1. Add a human review step to the Pi agent workflow before the PR creation step.
2. The reviewing human must explicitly approve the proposed changes and set `human_approval_completed: true` in the workflow payload.
3. Configure the workflow gate so that `gh pr create` is blocked until the approval flag is set.
4. Document the approver's identity and timestamp in the workflow log for audit purposes.
5. Re-run the workflow and confirm PASS.

#### Before

```json
{
  "pi_agent": {
    "human_approval_completed": false
  }
}
```

#### After

```json
{
  "pi_agent": {
    "human_approval_completed": true
  }
}
```

#### Exception guidance

HIGH severity. No fully automated PR submissions are permitted under any circumstances. If the human approver is unavailable, the PR must be deferred. Contact the platform team to discuss async approval workflows.

---

### PI-006 — Pi-generated code must pass linting

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/pi/code-standards.rego` |
| **Package** | `pi.guardrails.code` |

#### What triggers this violation

The rule fires when a file in `input.files` has `lint_status` set to anything other than `pass`, or when a lint error entry matches a known error pattern (SyntaxError, IndentationError, PEP8 E-codes).

#### Step-by-step fix

1. Run the linter locally on the Pi-generated file:
   ```bash
   flake8 <file.py>
   pylint <file.py>
   ```
2. Fix all reported syntax errors and PEP8 violations.
3. For automatic style fixes, use:
   ```bash
   autopep8 --in-place --aggressive <file.py>
   ```
4. Re-run the linter and confirm no errors remain.
5. Re-run the Pi agent workflow and confirm PASS.

#### Before

```python
def my_func(x,y):
  return x+y
```

#### After

```python
def my_func(x, y):
    return x + y
```

#### Exception guidance

MEDIUM severity advisory. Fix lint errors before opening a PR. No formal exception process required, but repeated lint failures may indicate the Pi agent prompt needs refinement.

---

### PI-007 — No hardcoded secrets, API keys, passwords, or tokens

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/pi/code-standards.rego` |
| **Package** | `pi.guardrails.code` |

#### What triggers this violation

The rule fires when a file's `content` in `input.files` matches a secret pattern: API keys (16+ chars), access tokens (20+ chars), passwords, private keys, AWS key patterns (AKIA…), or Bearer tokens

#### Step-by-step fix

1. **Immediately rotate** the exposed credential in the external system (AWS Console, API provider portal, etc.).
2. Remove the hardcoded value from the Pi-generated file.
3. Store the new credential in Harness Secret Manager or your organisation's secrets vault.
4. Replace the hardcoded value with an environment variable reference:
   ```python
   import os
   api_key = os.environ["MY_API_KEY"]
   ```
5. Inject the secret via Harness pipeline environment variables referencing Secret Manager.
6. Audit git history to confirm the credential was not previously committed.

#### Before

```python
api_key = "sk-abc123XYZ789longSecretValue"
```

#### After

```python
import os
api_key = os.environ["MY_API_KEY"]
```

#### Exception guidance

MEDIUM severity. Treat any exposed secret as a CRITICAL incident regardless of guardrail severity — rotate immediately and report to the Security team.

---

### PI-008 — Pi-generated code must include at minimum one unit test per function

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/pi/code-standards.rego` |
| **Package** | `pi.guardrails.code` |

#### What triggers this violation

The rule fires when a function listed in `file.functions` has no corresponding test entry in `file.tests` (or in a sibling `test_<module>.py` file) whose name contains the function name.

#### Step-by-step fix

1. For each Pi-generated function without a test, create a unit test:
   - Name the test `test_<function_name>` in a file named `test_<module>.py`.
   - The test must exercise at least the primary logic path of the function.
2. Run the tests locally to confirm they pass:
   ```bash
   pytest test_<module>.py -v
   ```
3. Commit the test file alongside the source file.
4. Re-run the Pi agent workflow and confirm PASS.

#### Before

```python
# utils.py
def add(x, y):
    return x + y

# No test file
```

#### After

```python
# utils.py
def add(x, y):
    return x + y

# test_utils.py
def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
```

#### Exception guidance

MEDIUM severity advisory. Refine the Pi agent prompt to instruct it to always generate tests alongside functions. Repeated violations may indicate a prompt engineering issue.

---

### PI-009 — Approved Pi agent versions only

| | |
|---|---|
| **Severity** | MEDIUM |
| **Policy file** | `policies/pi/code-standards.rego` |
| **Package** | `pi.guardrails.code` |

#### What triggers this violation

The rule fires when `input.pi_agent.version` is not in the organisation-approved versions list: `1.0.0`, `1.1.0`, `1.2.0`, `2.0.0`, `2.1.0`.

#### Step-by-step fix

1. Check the currently configured Pi agent version in your workflow configuration.
2. Update the version to an approved release:
   ```yaml
   pi_agent:
     version: "2.1.0"
   ```
3. If a newer version is needed, contact the platform team to request approval. Provide the version number, release notes link, and a security assessment.
4. Do not proceed with an unapproved version — all output from unapproved versions is considered non-compliant.

#### Before

```yaml
pi_agent:
  version: "3.0.0-beta"
```

#### After

```yaml
pi_agent:
  version: "2.1.0"
```

#### Exception guidance

MEDIUM severity. Raise a `policy-exception` issue with a business justification and a security review of the requested version. Maximum exception duration: 30 days.

---

### PI-010 — All Pi agent workflow steps must be logged

| | |
|---|---|
| **Severity** | LOW |
| **Policy file** | `policies/pi/workflow-gates.rego` |
| **Package** | `pi.guardrails.workflow` |

#### What triggers this violation

The rule fires when any step in `input.pi_agent.workflow_steps` is missing one or more of the required log fields: `timestamp`, `action`, or `outcome`.

#### Step-by-step fix

1. Review the Pi agent workflow configuration and ensure every step emits a structured log entry.
2. Each entry must include:
   - `timestamp`: ISO 8601 format (e.g. `2026-06-08T07:00:00Z`)
   - `action`: the step name (e.g. `pytest`, `gh pr create`)
   - `outcome`: `pass` or `fail`
3. Update the workflow configuration to add any missing fields.
4. Re-run the workflow and confirm all steps log correctly.

#### Before

```yaml
workflow_steps:
  - action: "pytest"
    outcome: pass
```

#### After

```yaml
workflow_steps:
  - action: "pytest"
    outcome: pass
    timestamp: "2026-06-08T07:00:00Z"
```

#### Exception guidance

LOW severity advisory. Add logging at the earliest opportunity. Consistent audit logs are required for compliance reviews and incident investigation.

---

*For questions or clarifications, open a GitHub Issue in this repository with the `policy-question` label. For exceptions, use the `policy-exception` label.*

