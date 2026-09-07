# Maintenance Runbook — agent_guardrails

> Operational guide for keeping the self-healing guardrail system healthy.
> Last verified: 2026-06-16

This runbook tells you exactly what to check, when to check it, and what
to do when something breaks. Most of the system runs itself — your job
is to review, approve, and occasionally fix.

---

## 1. Daily

Nothing required. The system runs unattended:

- Loop Engine fires automatically on every human-opened PR.
- Health Check runs every 12 hours.

No action needed unless an issue or escalation appears (see Section 5).

---

## 2. Weekly — Monday, 5 minutes

The Research Agent runs every Monday at 08:00 UTC and creates a GitHub
Issue with new findings. This is the one recurring task that needs a
human decision.

1. Open Issues, filter by label `research-proposal`.
2. Read the scan summary in the issue body:
   - Sources scanned (NVD, CISA KEV, OWASP, Harness release notes)
   - Number of gaps found
   - Number of rules proposed
3. Open the branch named in the issue
   (`research/auto-YYYY-MM-DD-*`) and review:
   - `policies/research/update-log.md` — full scan detail
   - `policies/opa/research-proposals.rego` — drafted rule skeletons
4. Decide for each proposed rule:
   - Merge — open a PR manually (base `main`, compare the research
     branch), let Loop Engine validate it, then merge.
   - Defer — leave the issue open, revisit next week.
   - Dismiss — close the issue with a one-line reason.
5. Close the issue once it has been merged or dismissed.

GitHub Enterprise Cloud blocks GitHub Actions from opening pull
requests, so the Research Agent creates an Issue instead of a PR.
This is expected behaviour, not a bug.

---

## 3. Monthly — 30 minutes

1. Run unit tests locally:
   opa test policies/opa/ -v
   opa test policies/pi/ -v
   All 44 rules should pass. Investigate immediately if any fail.

2. Review `loop-log.md` for recurring escalations.
   Same rule failing repeatedly means the auto-fix logic for that
   rule needs improvement — see Section 6.

3. Clear resolved escalation issues — filter Issues by label
   `loop-engine-escalation`, close anything already fixed.

4. Merge outstanding research proposals that were deferred during
   weekly review.

---

## 4. Quarterly — 1 hour

Review and refresh hardcoded values inside the policy files, since
these drift over time as infrastructure changes:

| File | What to check |
|---|---|
| policies/opa/pipeline-guardrails.rego | Approved registries list (PG-003) still current |
| policies/opa/delegate-validation.rego | Approved delegate versions list (DV-002) still current |
| policies/pi/bash-security.rego | Bash command whitelist (PI-003) still complete |
| policies/pi/code-standards.rego | Approved Pi agent versions (PI-009) still current |

Also:
- Check the OPA CLI version pinned in loop-engine.yml against the
  latest OPA release on GitHub.
- Check actions/checkout and actions/setup-python versions are not
  flagged as deprecated in the Actions tab.
- Confirm NVD and CISA KEV URLs in policies/research/threat-feed.yaml
  still resolve, using: research_agent.py --test-connections

---

## 5. When Something Breaks

### Step-by-step triage

1. Check the Actions tab first. Click the failed run, read the error
   in the job log.
2. Check if a GitHub Issue was already created. Loop Engine, Research
   Agent, and Health Check all auto-file an issue on failure with the
   relevant labels: loop-engine-escalation, research-proposal,
   health-check-failure.
3. Assign the issue to Copilot. The pattern in this repo is: issue
   appears, you assign it to the Copilot agent, it opens a fix PR,
   Loop Engine validates the PR automatically, you review and merge.
4. If Copilot cannot resolve it, fix manually using the table below,
   then open a PR yourself.

### Common failures and fixes

| Symptom | Cause | Fix |
|---|---|---|
| OPA checksum mismatch | Pinned OPA version checksum stale | Update the pinned checksum to match the currently released OPA version. Do not disable checksum verification — OPA evaluates every guardrail in this repo, so an unverified binary is a supply-chain risk, not a workaround. |
| opa: No such file or directory | OPA_PATH not exported before use | Confirm Export OPA path step runs before evaluation step |
| git push rejected, fetch first | Two jobs committed to same branch at once | Confirm jobs run sequentially via needs:, not in parallel |
| unrecognized arguments in loop_engine.py | Workflow passes a flag the script does not accept | Check argparse block matches every flag used in the yml |
| could not add label, not found | Required label does not exist yet | Re-run — label-creation step is idempotent and self-heals |
| GitHub Actions is not permitted to create or approve pull requests | GitHub Enterprise Cloud org policy | Expected — workflow creates an Issue instead of a PR |
| action_required status, workflow never starts | PR opened by a bot, not a human | Open the PR as a human — bot PRs require org approval in GHE |
| Same rule escalates every run | Auto-fix logic does not handle that violation's schema shape | See Section 6 |
| Research scan shows 0 items reviewed | First run only establishes baseline | Expected on first run, re-run with --force-scan for immediate full scan |

---

## 6. Improving the Auto-Fix Logic

If loop-log.md shows the same rule escalating across multiple PRs:

1. Find the _fix_* method matching the rule in scripts/loop_engine.py
   (for example _fix_registry for PG-003).
2. Reproduce the failure locally with the actual violating YAML.
3. Confirm the fixer writes to the correct file — get_fix_target()
   must never return a .rego policy path, only the pipeline YAML
   that triggered the violation.
4. Confirm the OPA re-evaluation step reads the fixed file from disk
   rather than the original input, via yaml_to_opa_input().
5. Add a test case to the relevant _test.rego file covering the
   scenario that was escalating.

---

## 7. Adding a New OPA Rule

1. Branch: policy/your-short-description
2. Add the rule to the correct file under policies/opa/ or
   policies/pi/.
3. Add a matching test in the corresponding _test.rego file — every
   rule needs at least one PASS and one FAIL test case.
4. Document the rule in docs/violation-remediation.md with an anchor
   link.
5. Add a row to the rule table in README.md.
6. Open a PR. Loop Engine validates automatically; Guardrail
   Enforcement Agent reviews for compliance.
7. Merge once green.

---

## 8. Key Files Reference

| File | Purpose |
|---|---|
| policies/research/loop-log.md | History of every Loop Engine attempt |
| policies/research/update-log.md | History of every Research Agent scan |
| docs/violation-remediation.md | Fix guidance for every rule, by ID |
| docs/policy-guide.md | How to write a new OPA rule correctly |
| scripts/loop_engine.py | All auto-fix logic lives here |
| scripts/research_agent.py | All CVE/OWASP/CISA scanning logic lives here |

---

## 9. Escalation Contacts

| Issue Type | First Action |
|---|---|
| Policy or compliance question | Reference docs/policy-guide.md, then ask in the team channel |
| GitHub Enterprise org-level setting needed | Raise with Deloitte IT / GitHub Enterprise admin |
| Recurring auto-fix failure | Assign the escalation issue to Copilot; if unresolved follow Section 6 |
| New CVE class not covered by any rule | Wait for the weekly Research Agent issue, or trigger a manual scan |

---

## Quick Checklist

WEEKLY (Monday, 5 min)
- Check Issues, label: research-proposal
- Review update-log.md and research-proposals.rego
- Merge good proposals, dismiss the rest

MONTHLY (30 min)
- opa test policies/opa/ -v
- opa test policies/pi/ -v
- Review loop-log.md for repeat escalations
- Close resolved escalation issues

QUARTERLY (1 hour)
- Refresh approved registries (PG-003)
- Refresh approved delegate versions (DV-002)
- Refresh bash whitelist (PI-003)
- Refresh approved Pi versions (PI-009)
- Check OPA / Actions versions for deprecation warnings
