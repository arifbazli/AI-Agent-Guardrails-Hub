# Loop Engine — Auto-Fix History

> Automated log maintained by the Loop Engine. Each entry records one fix attempt:
> pipeline type, rule that failed, fix applied, attempt number, and result.  
> Do **not** edit manually — entries are appended automatically by `scripts/loop_engine.py`.

## Format

Each row records one loop attempt:

| Column | Description |
|---|---|
| Date | ISO timestamp (UTC) |
| Pipeline | `harness`, `pi`, or `research` |
| Rule | Rule ID that triggered the loop (e.g. PG-001, PI-003) |
| Attempt | Attempt number (1, 2, or 3) |
| Violation | Short description of the violation detected |
| Fix Applied | What the auto-fixer changed |
| Result | `PASS`, `FAIL`, or `ESCALATED` |

---

## Log Entries

| Date | Pipeline | Rule | Attempt | Violation | Fix Applied | Result |
|---|---|---|---|---|---|---|
| 2026-06-12 08:45:01 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:45:20 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-12 08:45:37 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-12 08:45:47 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:45:59 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:46:12 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:46:25 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:46:39 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-12 08:54:15 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:54:26 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-12 08:56:40 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-12 08:57:00 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 01:16:02 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 01:16:19 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 1 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 2 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 3 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 1 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 2 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | OPA-ERROR | 3 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:31:24 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 1 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 2 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 3 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 1 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 2 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | OPA-ERROR | 3 | [Errno 2] No such file or directory: 'opa' | Apply fix for OPA-ERROR in policies/opa/pipeline-guardrails.rego | FAIL |
| 2026-06-15 01:33:22 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 01:34:43 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 01:35:01 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 01:46:50 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 01:47:08 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 01:56:39 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 01:56:59 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 1 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 1 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 1 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 1 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 1 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 1 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 1 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 2 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 2 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 2 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 2 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 2 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 2 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 2 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 3 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 3 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 3 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 3 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | APPROVED_REGISTRIES | 3 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 3 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | REQUIRED_TAGS | 3 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:16 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:17 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 1 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 1 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 1 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 1 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 1 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 1 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 1 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 2 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 2 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 2 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 2 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 2 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 2 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 2 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 3 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 3 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 3 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 3 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | APPROVED_REGISTRIES | 3 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 3 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | REQUIRED_TAGS | 3 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:18 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:05:19 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 02:05:25 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 02:05:46 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 1 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 1 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 1 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 1 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 1 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 1 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 1 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 2 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 2 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 2 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 2 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 2 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 2 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 2 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 3 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 3 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 3 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 3 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | APPROVED_REGISTRIES | 3 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 3 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | REQUIRED_TAGS | 3 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:51 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 1 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 1 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 1 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 1 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 1 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 1 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 1 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 1 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 2 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 2 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 2 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 2 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 2 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 2 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 2 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 2 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 3 | eu-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 3 | gcr.io/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 3 | ghcr.io/deloitte-global-cloud-services/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 3 | index.docker.io/deloitteinternal/ | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | APPROVED_REGISTRIES | 3 | us-docker.pkg.dev/deloitte- | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 3 | cost-centre | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | REQUIRED_TAGS | 3 | owner | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(password|passwd|pwd) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(secret|token|api[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(access[_-]?key|private[_-]?key) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:52 UTC | harness | SECRET_KEY_PATTERNS | 3 | (?i)(credential|auth[_-]?token) | Apply fix for APPROVED_REGISTRIES in test-inputs/final-verify.yaml; Apply fix fo | FAIL |
| 2026-06-15 02:20:54 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |
| 2026-06-15 02:21:00 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 02:21:15 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 02:46:08 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:46:08 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:46:08 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'cost-centre'. | Apply fix for PG-009 in test-inputs/trigger-test.yaml; Apply fix for PG-009 in t | FAIL |
| 2026-06-15 02:46:08 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'owner'. | Apply fix for PG-009 in test-inputs/trigger-test.yaml; Apply fix for PG-009 in t | FAIL |
| 2026-06-15 02:46:08 UTC | harness | PG-008 | 1 | Pipeline 'description' field is blank. | Apply fix for PG-009 in test-inputs/trigger-test.yaml; Apply fix for PG-009 in t | FAIL |
| 2026-06-15 02:46:08 UTC | harness | PG-* | 2 |  | none | PASS |
| 2026-06-15 02:46:09 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:46:09 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'cost-centre'. | Apply fix for PG-009 in test-inputs/verify-test.yaml; Apply fix for PG-009 in te | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'owner'. | Apply fix for PG-009 in test-inputs/verify-test.yaml; Apply fix for PG-009 in te | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-008 | 1 | Pipeline 'description' field is blank. | Apply fix for PG-009 in test-inputs/verify-test.yaml; Apply fix for PG-009 in te | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-* | 2 |  | none | PASS |
| 2026-06-15 02:46:09 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'cost-centre'. | Apply fix for PG-009 in test-inputs/human-pr-test.yaml; Apply fix for PG-009 in  | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-009 | 1 | Pipeline is missing the required tag: 'owner'. | Apply fix for PG-009 in test-inputs/human-pr-test.yaml; Apply fix for PG-009 in  | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-008 | 1 | Pipeline 'description' field is blank. | Apply fix for PG-009 in test-inputs/human-pr-test.yaml; Apply fix for PG-009 in  | FAIL |
| 2026-06-15 02:46:09 UTC | harness | PG-* | 2 |  | none | PASS |
| 2026-06-15 02:46:33 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:32 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 02:59:46 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 03:00:07 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:13:55 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-15 06:14:13 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-15 06:14:27 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-16 00:51:02 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 00:51:02 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 00:51:02 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 00:51:02 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 00:51:24 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-16 00:51:39 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-16 01:01:33 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:01:33 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:01:33 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:01:33 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:01:52 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-16 01:15:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:15:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:15:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:15:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:15:20 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-16 01:15:38 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-16 01:22:35 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:22:35 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:22:35 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:22:35 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 01:22:48 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-16 01:23:04 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
| 2026-06-16 06:10:17 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:10:17 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:10:17 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:10:17 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:20:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:20:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:20:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:20:07 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:25:57 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:25:57 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:25:57 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-16 06:25:57 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 01:49:20 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 01:49:20 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 01:49:20 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 01:49:20 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 01:49:33 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-22 02:11:09 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 02:11:09 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 02:11:09 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 02:11:09 UTC | harness | PG-* | 1 |  | none | PASS |
| 2026-06-22 02:11:23 UTC | pi | PI-* | 1 |  | none | PASS |
| 2026-06-22 02:11:41 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |

| 2026-11-23 05:09:32 UTC | harness | PG-007 | 1 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-001 | 1 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-005 | 1 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 1 | Environment variable 'API_KEY' in step 'deploy-app' appears to contain a plainte | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 1 | Environment variable 'DB_PASSWORD' in step 'deploy-app' appears to contain a pla | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-004 | 1 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-003 | 1 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-007 | 2 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-001 | 2 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-005 | 2 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 2 | Environment variable 'API_KEY' in step 'deploy-app' appears to contain a plainte | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 2 | Environment variable 'DB_PASSWORD' in step 'deploy-app' appears to contain a pla | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-004 | 2 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-003 | 2 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-007 | 3 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-001 | 3 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-005 | 3 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 3 | Environment variable 'API_KEY' in step 'deploy-app' appears to contain a plainte | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-002 | 3 | Environment variable 'DB_PASSWORD' in step 'deploy-app' appears to contain a pla | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-004 | 3 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:32 UTC | harness | PG-003 | 3 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/trigger-test.yaml; Apply fix for PG-001 in t | FAIL |

| 2026-11-23 05:09:33 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |

| 2026-11-23 05:09:34 UTC | harness | PG-007 | 1 | Production deployment stage 'deploy' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-001 | 1 | Stage 'deploy' targets a production environment but has no approval step. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-005 | 1 | Deployment stage 'deploy' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-002 | 1 | Environment variable 'SECRET' in step 'run' appears to contain a plaintext secre | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-004 | 1 | Stage 'deploy' does not define a timeout. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-003 | 1 | Image 'bad.registry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-007 | 2 | Production deployment stage 'deploy' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-001 | 2 | Stage 'deploy' targets a production environment but has no approval step. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-005 | 2 | Deployment stage 'deploy' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-002 | 2 | Environment variable 'SECRET' in step 'run' appears to contain a plaintext secre | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-004 | 2 | Stage 'deploy' does not define a timeout. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-003 | 2 | Image 'bad.registry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-007 | 3 | Production deployment stage 'deploy' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-001 | 3 | Stage 'deploy' targets a production environment but has no approval step. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-005 | 3 | Deployment stage 'deploy' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-002 | 3 | Environment variable 'SECRET' in step 'run' appears to contain a plaintext secre | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-004 | 3 | Stage 'deploy' does not define a timeout. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:34 UTC | harness | PG-003 | 3 | Image 'bad.registry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/human-pr-test.yaml; Apply fix for PG-001 in  | FAIL |

| 2026-11-23 05:09:35 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |

| 2026-11-23 05:09:35 UTC | harness | PG-* | 1 |  | none | PASS |

| 2026-11-23 05:09:36 UTC | harness | PG-007 | 1 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-001 | 1 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-005 | 1 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-002 | 1 | Environment variable 'SECRET' in step 'deploy' appears to contain a plaintext se | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-004 | 1 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-003 | 1 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-007 | 2 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-001 | 2 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-005 | 2 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-002 | 2 | Environment variable 'SECRET' in step 'deploy' appears to contain a plaintext se | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-004 | 2 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-003 | 2 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-007 | 3 | Production deployment stage 'deploy-production' does not define rollbackSteps. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-001 | 3 | Stage 'deploy-production' targets a production environment but has no approval s | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-005 | 3 | Deployment stage 'deploy-production' does not specify a delegate selector. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-002 | 3 | Environment variable 'SECRET' in step 'deploy' appears to contain a plaintext se | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-004 | 3 | Stage 'deploy-production' does not define a timeout. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:36 UTC | harness | PG-003 | 3 | Image 'badregistry.io/app:latest' is not from an approved registry. | Apply fix for PG-007 in test-inputs/verify-test.yaml; Apply fix for PG-001 in te | FAIL |

| 2026-11-23 05:09:37 UTC | harness | PG-* | 3 | max attempts reached | escalated to human | ESCALATED |

| 2026-11-23 05:09:37 UTC | harness | PG-008 | 0 | Pipeline is missing a 'description' field. | advisory only — LOW severity is not auto-fixed | FAIL |

| 2026-11-23 05:09:37 UTC | harness | PG-009 | 0 | Pipeline is missing the required tag: 'cost-centre'. | advisory only — LOW severity is not auto-fixed | FAIL |

| 2026-11-23 05:09:37 UTC | harness | PG-009 | 0 | Pipeline is missing the required tag: 'owner'. | advisory only — LOW severity is not auto-fixed | FAIL |

| 2026-11-23 05:09:56 UTC | pi | PI-* | 1 |  | none | PASS |

| 2026-11-23 05:10:12 UTC | research | REGO-SYNTAX | 1 |  | none | PASS |
