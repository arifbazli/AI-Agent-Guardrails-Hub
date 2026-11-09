## Run: 2026-11-09 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 2
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| GAP-001 | CVE-2026-54141 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | OpenHuman is an open-source agent harness available as a desktop application and Rust library. Before 0.57.13, a remote direct message received through a configured Yuanbao channel is converted into a |
| GAP-002 | CVE-2026-105770 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Octo STS (github.com/octo-sts/app) before 0.11.2 returns trust policy configuration to callers whose OIDC token does not satisfy that policy. TrustPolicy.CheckToken included the policy's issuer, subje |


### Recurring unresolved gaps (first reported in an earlier run): 16
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-54532 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | CloudPirates Open Source Helm Charts is a collection of Helm charts. Prior to commit 271d415, pull_request_target workflow is vulnerable to cache poisoning and OIDC token theft. A pull_request_target |
| REC-002 | CVE-2026-53942 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | Conda Organization Infrastructure is a centralized location for infrastructure codes. Prior to commit 9c0f238, a GitHub Actions Pwn Request vulnerability appears to remain present in conda/conda. The |
| REC-003 | CVE-2026-118762 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | Monkeytype is a minimalistic and customizable typing test. Prior to 26.43.0, the .github/workflows/fix-formatting.yml workflow runs on pull_request_target with repository write permissions, checks out |
| REC-004 | CVE-2026-119290 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Zuke is a code-first, strongly typed build automation system for Deno. Prior to 1.51.0, @zuke/core writes rendered reportSummary(...) notes to GITHUB_STEP_SUMMARY through writeJobSummary without apply |
| REC-005 | CVE-2026-14814 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab has remediated an issue in GitLab CE/EE affecting all versions before 19.2.8, 19.3 before 19.3.5, and 19.4 before 19.4.2 that, under certain conditions, could have allowed a user to poison cach |
| REC-006 | CVE-2026-16301 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab has remediated an issue in GitLab CE/EE affecting all versions from 18.7 before 19.2.8, 19.3 before 19.3.5, and 19.4 before 19.4.2 that, under certain conditions, could have allowed an authenti |
| REC-007 | CVE-2026-81839 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab has remediated an issue in GitLab EE affecting all versions from 18.1 before 19.2.8, 19.3 before 19.3.5, and 19.4 before 19.4.2 that, under certain conditions, could have allowed an authenticat |
| REC-008 | CVE-2026-97229 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | GitLab has remediated an issue in GitLab CE/EE affecting all versions from 19.2 before 19.2.8, 19.3 before 19.3.5, and 19.4 before 19.4.2 that, under certain conditions, could have allowed an unauthen |
| REC-009 | CVE-2026-9268 | LOW | TBD | NEEDS_MANUAL_REVIEW | GitLab has remediated an issue in GitLab EE affecting all versions from 13.6 before 19.2.8, 19.3 before 19.3.5, and 19.4 before 19.4.2 that, under certain conditions, could have allowed an authenticat |
| REC-010 | CVE-2026-85745 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | MariaDB server is a community developed fork of MySQL server. From 10.6.1 until 10.6.28, 10.11.19, 11.4.13, 11.8.9, 12.3.3, and 13.0.2, ST_Area reads beyond the allocated buffer when processing invali |
| REC-011 | CVE-2026-112058 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | VideoLAN libdvdnav through 7.0.0 contains an out-of-bounds read vulnerability in set_PTT that allows attackers to crash applications by supplying an invalid JumpTT title number checked only by an asse |
| REC-012 | CVE-2026-112895 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Pillow is a Python imaging library. From 5.1.0 until 13.0.0, Pillow can exhaust resources while parsing an existing PDF during an append operation. PdfParser follows page-tree child references without |
| REC-013 | CVE-2026-101469 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Product Lifecycle Analytics product of Oracle Supply Chain (component: Installation Issues).   The supported version that is affected is 3.6.1. Difficult to exploit vulnera |
| REC-014 | CVE-2026-101470 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Product Lifecycle Analytics product of Oracle Supply Chain (component: Installation Issues).   The supported version that is affected is 3.6.1. Easily exploitable vulnerabi |
| REC-015 | CVE-2026-76418 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall ASA Software and Cisco Secure FTD Software contains an unchecked return value to NULL pointer dereference vulnerability that could allow an unauthenticated, remote attacker to ca |
| REC-016 | CVE-2026-76519 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Email Gateway contains a relative path traversal vulnerability that could allow an unauthenticated, remote attacker to write arbitrary files on the underlying operating system. |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 25
25 threats fully covered by existing rules. No changes required.

---
