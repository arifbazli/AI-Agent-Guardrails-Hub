## Run: 2026-09-14 — Trigger: scheduled

### Sources scanned
- NVD: 40 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 0
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
_No new gaps found in this run._


### Recurring unresolved gaps (first reported in an earlier run): 21
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-50192 | LOW | TBD | NEEDS_MANUAL_REVIEW | Kerberos Agent is an open source video (surveillance) management agent. Prior to version 3.6.26, the Kerberos Hub upload path sends the agent's Hub credentials in the custom `X-Kerberos-Hub-PrivateKey |
| REC-002 | CVE-2026-46370 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Fleet is an open-source device management platform built on osquery. In versions up to and including 4.84.1, the labels host-listing endpoint (GET /api/v1/fleet/labels/{id}/hosts) allowed an authentic |
| REC-003 | CVE-2026-63187 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Logto is the modern, open-source auth infrastructure for SaaS and AI apps. From 1.40.1 until 1.41.0, Logto's .github/workflows/commitlint.yml directly interpolated github.event.pull_request.title into |
| REC-004 | CVE-2026-55378 | LOW | TBD | NEEDS_MANUAL_REVIEW | JS Recon is a JavaScript enumeration and SAST tool. From 1.2.1-beta.1 until 1.3.1-beta.2, the PR Branch Checker workflow in .github/workflows/pr_checker.yml places github.head_ref and github.event.pul |
| REC-005 | CVE-2026-82856 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | @hulumi/policies versions before 1.3.2 fail to properly validate set-qualified AWS IAM condition operators in GitHub OIDC trust policies. Attackers can use ForAnyValue:StringLike operators to hide wil |
| REC-006 | CVE-2026-53507 | LOW | TBD | NEEDS_MANUAL_REVIEW | oasdiff-action is a GitHub Action that detects breaking changes in OpenAPI specs and post a review on every pull request. Before version 0.0.51, the oasdiff actions resolved external $refs in the Open |
| REC-007 | CVE-2026-88884 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Renovate is a dependency update automation tool. In versions before 44.3.1 (and Mend Renovate CE/EE images before 15.4.0, mend-renovate-ce Helm chart before 15.4.0, mend-renovate-enterprise-edition He |
| REC-008 | CVE-2026-71493 | LOW | TBD | NEEDS_MANUAL_REVIEW | Infracost provides cloud cost intelligence for engineers, AI coding agents, and CI/CD. Prior to 0.10.45, the readFile, pathExists, isDir, and matchPaths template functions in internal/config/template/ |
| REC-009 | CVE-2026-71494 | LOW | TBD | NEEDS_MANUAL_REVIEW | Infracost provides cloud cost intelligence for engineers, AI coding agents, and CI/CD. Prior to 0.10.45, internal/hcl/remote_variables_loader.go and related Terraform Cloud, remote-plan, and Terragrun |
| REC-010 | CVE-2026-45099 | LOW | TBD | NEEDS_MANUAL_REVIEW | Terragrunt is a flexible orchestration tool that allows Infrastructure as Code written in OpenTofu or Terraform to scale. Prior to 1.0.4, Terragrunt trusts paths decoded from a downloaded module's .te |
| REC-011 | CVE-2026-55588 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | ORAS (OCI Registry As Storage) is a CLI and library for managing artifacts in OCI registries. In ORAS CLI versions up to and including 1.3.2, the recursive referrer traversal does not track visited de |
| REC-012 | CVE-2026-86597 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Insertion of sensitive information into log files in the Snowflake Python, Go, JDBC, Node.js, PHP PDO, and ODBC drivers allowed authentication tokens, query-result encryption keys, pre-signed cloud-st |
| REC-013 | CVE-2026-40506 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | OpenEMR before 8.2.0 contains a path traversal vulnerability in the standard_tables_manage.php interface where the db GET parameter is passed without validation to temp_dir_cleanup(), which joins the |
| REC-014 | CVE-2026-70691 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| REC-015 | CVE-2026-70693 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| REC-016 | CVE-2026-70697 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| REC-017 | CVE-2026-70698 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Install).   The supported version that is affected is 6.2.1. Easily exploitable vulnerability a |
| REC-018 | CVE-2026-85706 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab Community Edition and Enterprise Edition contains a path traversal vulnerability that allows an unauthenticated user to read arbitrary files due to an improper path confinement and missing auth |
| REC-019 | CVE-2026-19490 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an authentication-bypass vulnerability involving an alternate path or channel. When the NetScaler appliance is configured as an AAA virtual server or |
| REC-020 | CVE-2026-20079 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall Management Center (FMC) Software and Cisco Security Cloud Control (SCC) Firewall Management contain an authentication Bypass using an alternate path or channel vulnerability that |
| REC-021 | CVE-2026-8452 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an improper restriction of operations within the bounds of a memory buffer vulnerability which could lead to denial of service. |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 23
23 threats fully covered by existing rules. No changes required.

---
