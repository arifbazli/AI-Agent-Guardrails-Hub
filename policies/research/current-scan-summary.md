## Run: 2026-11-23 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 7
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| GAP-001 | CVE-2026-114134 | LOW | TBD | NEEDS_MANUAL_REVIEW | Black is the uncompromising Python code formatter. Prior to 26.10.1, the Black GitHub Action with use_pyproject: true accepts tool.black.required-version from pyproject.toml without validating that it |
| GAP-002 | CVE-2026-123369 | LOW | TBD | NEEDS_MANUAL_REVIEW | compose-lint is a Docker Compose security linter that identifies dangerous misconfigurations before deployment. Prior to 0.31.0, compose-lint prints attacker-controlled service names, environment keys |
| GAP-003 | CVE-2026-119371 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | SQLite before 3.54.0 contains a stack exhaustion vulnerability that allows attackers to bypass the SQLITE_LIMIT_EXPR_DEPTH nesting limit because common table expressions are not counted against it. At |
| GAP-004 | CVE-2026-119376 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | SQLite before 3.54.0 contains a stack exhaustion vulnerability that allows attackers to bypass the SQLITE_LIMIT_EXPR_DEPTH limit by chaining COLLATE postfix operators. Attackers can supply roughly 175 |
| GAP-005 | CVE-2026-123508 | LOW | TBD | NEEDS_MANUAL_REVIEW | Vikunja before 2.7.1 contains a supply chain vulnerability in its mage release targets that fetch the xgo module and Docker image by mutable latest references. Attackers who compromise the upstream xg |
| GAP-006 | CVE-2026-124439 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Scriban and Scriban.Signed before 7.5.3 contain uncontrolled recursion flaws in which postfix member, indexer, and call chains bypass ExpressionDepthLimit, array comparison lacks depth and cycle check |
| GAP-007 | CVE-2026-76466 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Expressway Series contains a use of hard-coded credentials vulnerability that allows an unauthenticated, remote attacker with persistent cookies and network access to execute commands as root on |


### Recurring unresolved gaps (first reported in an earlier run): 12
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-54141 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | OpenHuman is an open-source agent harness available as a desktop application and Rust library. Before 0.57.13, a remote direct message received through a configured Yuanbao channel is converted into a |
| REC-002 | CVE-2026-118762 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | Monkeytype is a minimalistic and customizable typing test. Prior to 26.43.0, the .github/workflows/fix-formatting.yml workflow runs on pull_request_target with repository write permissions, checks out |
| REC-003 | CVE-2026-119290 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Zuke is a code-first, strongly typed build automation system for Deno. Prior to 1.51.0, @zuke/core writes rendered reportSummary(...) notes to GITHUB_STEP_SUMMARY through writeJobSummary without apply |
| REC-004 | CVE-2026-105770 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Octo STS (github.com/octo-sts/app) before 0.11.2 returns trust policy configuration to callers whose OIDC token does not satisfy that policy. TrustPolicy.CheckToken included the policy's issuer, subje |
| REC-005 | CVE-2026-116964 | HIGH | TBD | NEEDS_MANUAL_REVIEW | A flaw was found in konflux-ci. An attacker with repository write access can achieve arbitrary code execution within the Continuous Integration and Continuous Delivery (CI/CD) workflow environment. By |
| REC-006 | CVE-2026-50240 | HIGH | TBD | NEEDS_MANUAL_REVIEW | A flaw was found in OpenShift Pipelines-as-Code (PAC). PAC does not verify whether the creator of a Repository custom resource has permission to create PipelineRuns. A namespace user with only Reposit |
| REC-007 | CVE-2026-102289 | LOW | TBD | NEEDS_MANUAL_REVIEW | zizmor is a static analysis tool for CI/CD systems. In version 1.27.0, debug logging serializes the parsed application configuration with a derived Debug implementation for GitHubToken, causing creden |
| REC-008 | CVE-2026-68549 | LOW | TBD | NEEDS_MANUAL_REVIEW | ClickMigrate is a database migration tool for ClickHouse with automatic SQL migration management and version tracking. Prior to version 1.0.3, a path traversal vulnerability in the revision command al |
| REC-009 | CVE-2026-127208 | HIGH | TBD | NEEDS_MANUAL_REVIEW | datamodel-code-generator before 0.84.0 contains a code injection vulnerability that allows attackers to achieve arbitrary code execution by supplying a malicious JSON Schema with a crafted x-python-ty |
| REC-010 | CVE-2026-20320 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco BroadWorks contains an improper restriction of XML external entity reference vulnerability that could allow an unauthenticated, remote attacker to read sensitive configuration information on an |
| REC-011 | CVE-2026-97229 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab Community Edition and Enterprise Edition contain a integer overflow or wraparound vulnerability that could allow an unauthenticated user to execute arbitrary code on the GitLab server via a spe |
| REC-012 | CVE-2026-76418 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall ASA Software and Cisco Secure FTD Software contains an unchecked return value to NULL pointer dereference vulnerability that could allow an unauthenticated, remote attacker to ca |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 24
24 threats fully covered by existing rules. No changes required.

---
