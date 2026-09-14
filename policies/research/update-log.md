# Research Agent — Policy Update Log

> Automated log maintained by the Research Agent. Each entry records a full 
> scan run: sources checked, gaps found, rules drafted, and PR actions taken.  
> Do **not** edit manually — append only via the Research Agent workflow.

---

## Run: 2026-06-18 — Trigger: initial_setup

### Sources scanned
- NVD: 0 items reviewed (initial setup — no prior run baseline)
- OWASP: 0 items reviewed (initial setup — no prior run baseline)
- CISA KEV: 0 items reviewed (initial setup — no prior run baseline)
- Harness release notes: 0 items reviewed (initial setup — no prior run baseline)

### Gaps found: 0
No scan performed on initial setup. Baseline established.

### Rules updated: 0
No changes required at initialisation.

### Current rule coverage baseline
| Policy File | Rules Covered | Rule IDs |
|---|---|---|
| `policies/opa/pipeline-guardrails.rego` | 9 | PG-001 – PG-009 |
| `policies/opa/code-security.rego` | 9 | CS-001 – CS-009 |
| `policies/opa/connector-compliance.rego` | 8 | CC-001 – CC-008 |
| `policies/opa/delegate-validation.rego` | 8 | DV-001 – DV-008 |
| `policies/pi/bash-security.rego` | 3 | PI-001 – PI-003 |
| `policies/pi/workflow-gates.rego` | 3 | PI-004, PI-005, PI-010 |
| `policies/pi/code-standards.rego` | 4 | PI-006 – PI-009 |

**Total rules in baseline: 44**

### Next scheduled run
Monday 02:00 UTC — full scan of all sources with 90-day lookback on first live run.

---

## Run: 2026-06-16 — Trigger: on_demand

### Sources scanned
- NVD: 38 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 2 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 40
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-46062 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-46072 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-46116 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-49325 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-5066 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-48208 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-53808 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-53811 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-53823 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-44590 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-45131 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-45132 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-41249 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-48546 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-6406 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-5817 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-5843 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-45082 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-47672 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-27173 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-45760 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-40564 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-44247 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-41184 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-25244 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-026 | CVE-2026-5241 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-027 | CVE-2026-10733 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-028 | CVE-2026-11816 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-029 | CVE-2018-25323 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-030 | CVE-2026-25244 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-031 | CVE-2026-34216 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-032 | CVE-2026-2651 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-033 | CVE-2026-45247 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-034 | CVE-2026-7860 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-035 | CVE-2026-42526 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-036 | CVE-2026-9129 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-037 | CVE-2026-46473 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-038 | CVE-2026-40610 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-039 | CVE-2026-20262 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-040 | CVE-2026-20245 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 0
0 threats fully covered by existing rules. No changes required.

---

## Run: 2026-06-12 — Trigger: initial_setup

### Sources scanned
- NVD: 0 items reviewed (initial setup — no prior run baseline)
- OWASP: 0 items reviewed (initial setup — no prior run baseline)
- CISA KEV: 0 items reviewed (initial setup — no prior run baseline)
- Harness release notes: 0 items reviewed (initial setup — no prior run baseline)

### Gaps found: 0
No scan performed on initial setup. Baseline established.

### Rules updated: 0
No changes required at initialisation.

### Current rule coverage baseline
| Policy File | Rules Covered | Rule IDs |
|---|---|---|
| `policies/opa/pipeline-guardrails.rego` | 9 | PG-001 – PG-009 |
| `policies/opa/code-security.rego` | 9 | CS-001 – CS-009 |
| `policies/opa/connector-compliance.rego` | 8 | CC-001 – CC-008 |
| `policies/opa/delegate-validation.rego` | 8 | DV-001 – DV-008 |
| `policies/pi/bash-security.rego` | 3 | PI-001 – PI-003 |
| `policies/pi/workflow-gates.rego` | 3 | PI-004, PI-005, PI-010 |
| `policies/pi/code-standards.rego` | 4 | PI-006 – PI-009 |

**Total rules in baseline: 44**

### Next scheduled run
Monday 02:00 UTC — full scan of all sources with 90-day lookback on first live run.

---

## Run: 2026-06-22 — Trigger: on_demand

### Sources scanned
- NVD: 33 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 2 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 29
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-46062 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-46072 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-46116 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-49325 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-48208 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-53808 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-53811 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-53823 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-53849 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-44590 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-45131 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-45132 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-41249 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-48546 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-45082 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-47672 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-44985 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-45298 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-44830 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-40564 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-44247 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-41184 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-41185 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-44477 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-8606 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-026 | CVE-2026-42878 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-027 | CVE-2026-9618 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-028 | CVE-2026-32847 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-029 | CVE-2026-45582 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 6
6 threats fully covered by existing rules. No changes required.

---

## Run: 2026-06-22 — Trigger: scheduled

### Sources scanned
- NVD: 20 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 2 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 0
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
_No gaps found in this run._

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 22
22 threats fully covered by existing rules. No changes required.

---

## Run: 2026-07-20 — Trigger: scheduled

### Sources scanned
- NVD: 39 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 22
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-54325 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-54326 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-54327 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-54328 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-7838 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-45793 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-47751 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-15343 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-46420 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-56280 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-0934 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-8330 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2025-71348 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2025-71382 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-44017 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-54069 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2021-47986 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-20230 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-07-27 — Trigger: scheduled

### Sources scanned
- NVD: 38 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 2 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 20
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-7838 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-15036 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-45793 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-47751 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-15343 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-46420 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-46412 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-13323 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2025-71342 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-61446 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-15008 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-63306 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-07-31 — Trigger: on_demand

### Sources scanned
- NVD: 18 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 16
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-7838 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-15036 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-13323 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2025-71342 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-61446 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-15008 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-63306 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 5
5 threats fully covered by existing rules. No changes required.

---
## Run: 2026-07-31 — Trigger: on_demand

### Sources scanned
- NVD: 13 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 11
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-7838 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-15036 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 5
5 threats fully covered by existing rules. No changes required.

---
## Run: 2026-08-03 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 3 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 24
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-15036 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64650 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-45793 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-47751 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-15343 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-46420 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-46412 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-18220 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-12436 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-18245 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-61446 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-15008 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-63306 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-63086 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-33731 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-08-10 — Trigger: scheduled

### Sources scanned
- NVD: 44 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 28
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-64650 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64651 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-62209 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-62219 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-64676 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-46409 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-45793 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-47751 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-15343 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-46420 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-46412 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-18220 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-12436 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-18245 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-61446 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-15008 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-63306 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-63086 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-33731 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-63077 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-026 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-027 | CVE-2023-4346 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-028 | CVE-2008-4128 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-08-17 — Trigger: scheduled

### Sources scanned
- NVD: 43 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 27
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-63808 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-63905 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-64102 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-64650 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-64651 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-65604 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-64676 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-46409 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-46412 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2024-58354 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-67308 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-48168 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-64652 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-18220 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-12436 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-18245 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-19548 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-44359 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-28220 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-63729 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-16266 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-47009 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-20349 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-68820 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-026 | CVE-2026-63077 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-027 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-08-24 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 25
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-64456 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-18830 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-72193 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-64676 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-46409 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-50192 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-67308 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-48168 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-64652 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-11325 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-63187 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-18220 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-12436 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-18245 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-19548 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-50237 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-57858 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-19548 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-48702 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-20349 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-68820 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-63077 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-20316 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---
## Run: 2026-08-31 — Trigger: scheduled

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found: 25
| Gap ID | Source | Severity | Assigned Rule | Status |
|---|---|---|---|---|
| GAP-001 | CVE-2026-18830 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-002 | CVE-2026-72193 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-003 | CVE-2026-64676 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-004 | CVE-2026-46409 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-005 | CVE-2026-50192 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-006 | CVE-2026-46370 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-007 | CVE-2026-48168 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW |
| GAP-008 | CVE-2026-64652 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-009 | CVE-2026-11325 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-010 | CVE-2026-63187 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-011 | CVE-2026-55378 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-012 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-013 | CVE-2026-19548 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-014 | CVE-2026-15423 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-015 | CVE-2026-71493 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-016 | CVE-2026-71494 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-017 | CVE-2026-64655 | LOW | TBD | NEEDS_MANUAL_REVIEW |
| GAP-018 | CVE-2026-50237 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-019 | CVE-2026-57858 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-020 | CVE-2026-19548 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW |
| GAP-021 | CVE-2026-48702 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-022 | CVE-2026-8452 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-023 | CVE-2026-20349 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-024 | CVE-2026-68820 | HIGH | TBD | NEEDS_MANUAL_REVIEW |
| GAP-025 | CVE-2026-63077 | HIGH | TBD | NEEDS_MANUAL_REVIEW |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 20
20 threats fully covered by existing rules. No changes required.

---

## Run: 2026-09-14 — Trigger: on_demand

### Sources scanned
- NVD: 41 items reviewed
- OWASP: manual monitoring (automated fetch not yet implemented)
- CISA KEV: 4 items reviewed
- Harness release notes: manual monitoring (automated fetch not yet implemented)

### Gaps found (new this run): 14
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| GAP-001 | CVE-2026-82856 | CRITICAL | TBD | NEEDS_MANUAL_REVIEW | @hulumi/policies versions before 1.3.2 fail to properly validate set-qualified AWS IAM condition operators in GitHub OIDC trust policies. Attackers can use ForAnyValue:StringLike operators to hide wil |
| GAP-002 | CVE-2026-53507 | LOW | TBD | NEEDS_MANUAL_REVIEW | oasdiff-action is a GitHub Action that detects breaking changes in OpenAPI specs and post a review on every pull request. Before version 0.0.51, the oasdiff actions resolved external $refs in the Open |
| GAP-003 | CVE-2026-88884 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Renovate is a dependency update automation tool. In versions before 44.3.1 (and Mend Renovate CE/EE images before 15.4.0, mend-renovate-ce Helm chart before 15.4.0, mend-renovate-enterprise-edition He |
| GAP-004 | CVE-2026-45099 | LOW | TBD | NEEDS_MANUAL_REVIEW | Terragrunt is a flexible orchestration tool that allows Infrastructure as Code written in OpenTofu or Terraform to scale. Prior to 1.0.4, Terragrunt trusts paths decoded from a downloaded module's .te |
| GAP-005 | CVE-2026-55588 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | ORAS (OCI Registry As Storage) is a CLI and library for managing artifacts in OCI registries. In ORAS CLI versions up to and including 1.3.2, the recursive referrer traversal does not track visited de |
| GAP-006 | CVE-2026-86597 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Insertion of sensitive information into log files in the Snowflake Python, Go, JDBC, Node.js, PHP PDO, and ODBC drivers allowed authentication tokens, query-result encryption keys, pre-signed cloud-st |
| GAP-007 | CVE-2026-40506 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | OpenEMR before 8.2.0 contains a path traversal vulnerability in the standard_tables_manage.php interface where the db GET parameter is passed without validation to temp_dir_cleanup(), which joins the |
| GAP-008 | CVE-2026-70691 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| GAP-009 | CVE-2026-70693 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| GAP-010 | CVE-2026-70697 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Engineering Communication Interface).   The supported version that is affected is 6.2.1. Diffic |
| GAP-011 | CVE-2026-70698 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Vulnerability in the Oracle Agile Engineering Data Management product of Oracle Supply Chain (component: Install).   The supported version that is affected is 6.2.1. Easily exploitable vulnerability a |
| GAP-012 | CVE-2026-85706 | HIGH | TBD | NEEDS_MANUAL_REVIEW | GitLab Community Edition and Enterprise Edition contains a path traversal vulnerability that allows an unauthenticated user to read arbitrary files due to an improper path confinement and missing auth |
| GAP-013 | CVE-2026-19490 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an authentication-bypass vulnerability involving an alternate path or channel. When the NetScaler appliance is configured as an AAA virtual server or |
| GAP-014 | CVE-2026-20079 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Cisco Secure Firewall Management Center (FMC) Software and Cisco Security Cloud Control (SCC) Firewall Management contain an authentication Bypass using an alternate path or channel vulnerability that |


### Recurring unresolved gaps (first reported in an earlier run): 7
| Gap ID | Source | Severity | Assigned Rule | Status | Description |
|---|---|---|---|---|---|
| REC-001 | CVE-2026-50192 | LOW | TBD | NEEDS_MANUAL_REVIEW | Kerberos Agent is an open source video (surveillance) management agent. Prior to version 3.6.26, the Kerberos Hub upload path sends the agent's Hub credentials in the custom `X-Kerberos-Hub-PrivateKey |
| REC-002 | CVE-2026-46370 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Fleet is an open-source device management platform built on osquery. In versions up to and including 4.84.1, the labels host-listing endpoint (GET /api/v1/fleet/labels/{id}/hosts) allowed an authentic |
| REC-003 | CVE-2026-63187 | MEDIUM | TBD | NEEDS_MANUAL_REVIEW | Logto is the modern, open-source auth infrastructure for SaaS and AI apps. From 1.40.1 until 1.41.0, Logto's .github/workflows/commitlint.yml directly interpolated github.event.pull_request.title into |
| REC-004 | CVE-2026-55378 | LOW | TBD | NEEDS_MANUAL_REVIEW | JS Recon is a JavaScript enumeration and SAST tool. From 1.2.1-beta.1 until 1.3.1-beta.2, the PR Branch Checker workflow in .github/workflows/pr_checker.yml places github.head_ref and github.event.pul |
| REC-005 | CVE-2026-71493 | LOW | TBD | NEEDS_MANUAL_REVIEW | Infracost provides cloud cost intelligence for engineers, AI coding agents, and CI/CD. Prior to 0.10.45, the readFile, pathExists, isDir, and matchPaths template functions in internal/config/template/ |
| REC-006 | CVE-2026-71494 | LOW | TBD | NEEDS_MANUAL_REVIEW | Infracost provides cloud cost intelligence for engineers, AI coding agents, and CI/CD. Prior to 0.10.45, internal/hcl/remote_variables_loader.go and related Terraform Cloud, remote-plan, and Terragrun |
| REC-007 | CVE-2026-8452 | HIGH | TBD | NEEDS_MANUAL_REVIEW | Citrix NetScaler ADC and NetScaler Gateway contain an improper restriction of operations within the bounds of a memory buffer vulnerability which could lead to denial of service. |

### Rules updated: 0
No automated rule drafting performed in this run — gaps flagged for manual review.

### No-action items: 24
24 threats fully covered by existing rules. No changes required.

---

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
