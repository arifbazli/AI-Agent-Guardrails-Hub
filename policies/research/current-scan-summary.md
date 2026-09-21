## Run: 2026-09-21 — Trigger: scheduled

### Sources scanned
- NVD: 43 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 6 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 13
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| GAP-001 | CVE-2026-82438 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Description  Three separate mechanisms allowed a web page on an unrelated origin to read responses that Storm's HTTP components served to an authenticated user.  The Logviewer reflected the request's |
| GAP-002 | CVE-2026-86043 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Skipper is an HTTP router and reverse proxy for service composition. Prior to version 0.27.37, the opaAuthorizeRequestWithBody filter can authorize an oversized request after Skipper truncates the bod |
| GAP-003 | CVE-2026-58502 | LOW | TBD | NEEDS_MANUAL_REVIEW | githubtoplanguages generates a user's top GitHub languages as an SVG. The .github/workflows/discord-issue.yml workflow runs when an issue is opened or closed and interpolates github.event.issue.title |
| GAP-004 | CVE-2026-55846 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Allure 2 is the version 2.x branch of Allure Report, a multi-language test reporting tool. Prior to 2.39.0, the HTTP server started by allure serve and allure open uses URI.getPath() in Commands.setUp |
| GAP-005 | CVE-2026-54167 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Pipelines-as-Code is a CI/CD system that lets users define Tekton pipelines in source code repositories. Prior to 0.37.8, 0.39.6, 0.42.1, and 0.48.0, the GitHub App provider accepts X-GitHub-Enterpris |
| GAP-006 | CVE-2026-54168 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Pipelines-as-Code is a CI/CD system that lets users define Tekton pipelines in source code repositories. Prior to 0.37.8, 0.39.6, 0.42.1, and 0.48.0, a GitHub App installation token created during web |
| GAP-007 | CVE-2026-21753 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | HCL Hive is affected by weak software supply chain governance, which could lead to the inclusion of vulnerable, unmaintained, or malicious third-party dependencies within the application environment. |
| GAP-008 | CVE-2026-82021 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Hermes Agent 0.18.2 prior to 0.19.0 contains a supply chain vulnerability in its bundled MCP catalog that allows a remote attacker to execute arbitrary code by compromising a third-party upstream repo |
| GAP-009 | CVE-2026-82290 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Chainlit through 2.12.0 fails to validate ownership of feedback records in PUT and DELETE endpoints. Authenticated attackers can delete or modify other users' feedback by supplying arbitrary feedback |
| GAP-010 | CVE-2026-55273 | HIGH | TBD | NEEDS_MANUAL_REVIEW | In AppendCommentLine of AnnotationProcessor.cpp, there is a possible supply chain risk due to improper input validation. This could lead to local escalation of privilege with no additional execution p |
| GAP-011 | CVE-2026-86775 | HIGH | TBD | NEEDS_MANUAL_REVIEW | knowns (npm package) versions <= 0.29.1 contain a path traversal vulnerability in the Document API. The HTTP handler in internal/server/routes/docs.go normalizes the user-supplied document path with c |
| GAP-012 | CVE-2026-76460 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Identity Services Engine (ISE) and Cisco ISE Passive Identity Connector (ISE-PIC) contain an incorrect use of privileged APIs vulnerability that could allow an unauthenticated, remote attacker t |
| GAP-013 | CVE-2026-76461 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco AsyncOS software for Cisco Secure Email Gateway (SEG) contains a SQL injection vulnerability that could allow an unauthenticated, remote attacker to execute arbitrary commands with root privileg |


### Recurring unresolved gaps (first reported in an earlier run): 11
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-46370 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Fleet is an open-source device management platform built on osquery. In versions up to and including 4.84.1, the labels host-listing endpoint (GET /api/v1/fleet/labels/{id}/hosts) allowed an authentic |
| REC-002 | CVE-2026-55378 | LOW | TBD | NEEDS_MANUAL_REVIEW | JS Recon is a JavaScript enumeration and SAST tool. From 1.2.1-beta.1 until 1.3.1-beta.2, the PR Branch Checker workflow in .github/workflows/pr_checker.yml places github.head_ref and github.event.pul |
| REC-003 | CVE-2026-82856 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | @hulumi/policies versions before 1.3.2 fail to properly validate set-qualified AWS IAM condition operators in GitHub OIDC trust policies. Attackers can use ForAnyValue:StringLike operators to hide wil |
| REC-004 | CVE-2026-53507 | LOW | TBD | NEEDS_MANUAL_REVIEW | oasdiff-action is a GitHub Action that detects breaking changes in OpenAPI specs and post a review on every pull request. Before version 0.0.51, the oasdiff actions resolved external $refs in the Open |
| REC-005 | CVE-2026-88884 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Renovate is a dependency update automation tool. In versions before 44.3.1 (and Mend Renovate CE/EE images before 15.4.0, mend-renovate-ce Helm chart before 15.4.0, mend-renovate-enterprise-edition He |
| REC-006 | CVE-2026-55588 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | ORAS (OCI Registry As Storage) is a CLI and library for managing artifacts in OCI registries. In ORAS CLI versions up to and including 1.3.2, the recursive referrer traversal does not track visited de |
| REC-007 | CVE-2026-86597 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Insertion of sensitive information into log files in the Snowflake Python, Go, JDBC, Node.js, PHP PDO, and ODBC drivers allowed authentication tokens, query-result encryption keys, pre-signed cloud-st |
| REC-008 | CVE-2026-85706 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab Community Edition and Enterprise Edition contains a path traversal vulnerability that allows an unauthenticated user to read arbitrary files due to an improper path confinement and missing auth |
| REC-009 | CVE-2026-19490 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an authentication-bypass vulnerability involving an alternate path or channel. When the NetScaler appliance is configured as an AAA virtual server or |
| REC-010 | CVE-2026-20079 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall Management Center (FMC) Software and Cisco Security Cloud Control (SCC) Firewall Management contain an authentication Bypass using an alternate path or channel vulnerability that |
| REC-011 | CVE-2026-8452 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an improper restriction of operations within the bounds of a memory buffer vulnerability which could lead to denial of service. |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 25
25 threats fully covered by existing rules. No changes required.

---
