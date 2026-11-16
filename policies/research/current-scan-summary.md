## Run: 2026-11-16 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 7
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| GAP-001 | CVE-2026-116964 | HIGH | TBD | NEEDS_MANUAL_REVIEW | A flaw was found in konflux-ci. An attacker with repository write access can achieve arbitrary code execution within the Continuous Integration and Continuous Delivery (CI/CD) workflow environment. By |
| GAP-002 | CVE-2026-50240 | HIGH | TBD | NEEDS_MANUAL_REVIEW | A flaw was found in OpenShift Pipelines-as-Code (PAC). PAC does not verify whether the creator of a Repository custom resource has permission to create PipelineRuns. A namespace user with only Reposit |
| GAP-003 | CVE-2026-102289 | LOW | TBD | NEEDS_MANUAL_REVIEW | zizmor is a static analysis tool for CI/CD systems. In version 1.27.0, debug logging serializes the parsed application configuration with a derived Debug implementation for GitHubToken, causing creden |
| GAP-004 | CVE-2026-68549 | LOW | TBD | NEEDS_MANUAL_REVIEW | ClickMigrate is a database migration tool for ClickHouse with automatic SQL migration management and version tracking. Prior to version 1.0.3, a path traversal vulnerability in the revision command al |
| GAP-005 | CVE-2026-127208 | HIGH | TBD | NEEDS_MANUAL_REVIEW | datamodel-code-generator before 0.84.0 contains a code injection vulnerability that allows attackers to achieve arbitrary code execution by supplying a malicious JSON Schema with a crafted x-python-ty |
| GAP-006 | CVE-2026-101471 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Product Lifecycle Analytics product of Oracle Supply Chain (component: Installation Issues).   The supported version that is affected is 3.6.1. Easily exploitable vulnerabi |
| GAP-007 | CVE-2026-20320 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco BroadWorks contains an improper restriction of XML external entity reference vulnerability that could allow an unauthenticated, remote attacker to read sensitive configuration information on an |


### Recurring unresolved gaps (first reported in an earlier run): 12
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-54141 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | OpenHuman is an open-source agent harness available as a desktop application and Rust library. Before 0.57.13, a remote direct message received through a configured Yuanbao channel is converted into a |
| REC-002 | CVE-2026-54532 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | CloudPirates Open Source Helm Charts is a collection of Helm charts. Prior to commit 271d415, pull_request_target workflow is vulnerable to cache poisoning and OIDC token theft. A pull_request_target |
| REC-003 | CVE-2026-53942 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | Conda Organization Infrastructure is a centralized location for infrastructure codes. Prior to commit 9c0f238, a GitHub Actions Pwn Request vulnerability appears to remain present in conda/conda. The |
| REC-004 | CVE-2026-118762 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | Monkeytype is a minimalistic and customizable typing test. Prior to 26.43.0, the .github/workflows/fix-formatting.yml workflow runs on pull_request_target with repository write permissions, checks out |
| REC-005 | CVE-2026-119290 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Zuke is a code-first, strongly typed build automation system for Deno. Prior to 1.51.0, @zuke/core writes rendered reportSummary(...) notes to GITHUB_STEP_SUMMARY through writeJobSummary without apply |
| REC-006 | CVE-2026-105770 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Octo STS (github.com/octo-sts/app) before 0.11.2 returns trust policy configuration to callers whose OIDC token does not satisfy that policy. TrustPolicy.CheckToken included the policy's issuer, subje |
| REC-007 | CVE-2026-112058 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | VideoLAN libdvdnav through 7.0.0 contains an out-of-bounds read vulnerability in set_PTT that allows attackers to crash applications by supplying an invalid JumpTT title number checked only by an asse |
| REC-008 | CVE-2026-112895 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Pillow is a Python imaging library. From 5.1.0 until 13.0.0, Pillow can exhaust resources while parsing an existing PDF during an append operation. PdfParser follows page-tree child references without |
| REC-009 | CVE-2026-101469 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Product Lifecycle Analytics product of Oracle Supply Chain (component: Installation Issues).   The supported version that is affected is 3.6.1. Difficult to exploit vulnera |
| REC-010 | CVE-2026-101470 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Product Lifecycle Analytics product of Oracle Supply Chain (component: Installation Issues).   The supported version that is affected is 3.6.1. Easily exploitable vulnerabi |
| REC-011 | CVE-2026-97229 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab Community Edition and Enterprise Edition contain a integer overflow or wraparound vulnerability that could allow an unauthenticated user to execute arbitrary code on the GitLab server via a spe |
| REC-012 | CVE-2026-76418 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall ASA Software and Cisco Secure FTD Software contains an unchecked return value to NULL pointer dereference vulnerability that could allow an unauthenticated, remote attacker to ca |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 24
24 threats fully covered by existing rules. No changes required.

---
