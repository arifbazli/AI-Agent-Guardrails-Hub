# AI Agent Guardrails Hub

Self-healing OPA/Rego guardrails for Harness CI/CD pipelines and Pi
coding-agent workflows. A multi-agent hub evaluates policy, auto-fixes
failures up to a severity-gated retry budget, then escalates to a human.

Diagrams: [architecture](docs/assets/architecture.svg) ·
[file structure](docs/assets/file-structure.svg)

## Structure

| Path | Contents |
|---|---|
| `.github/agents/` | 4 agent specs — Benchmark, Guardrail, Pi Guardrail, Research |
| `.github/workflows/` | Loop Engine (per-PR) · Research Agent (weekly) · Health Check (12h) |
| `policies/opa/`, `policies/pi/` | Rego policies + tests (see below) |
| `policies/pipeline/` | Harness-native approval/stage-gate config |
| `scripts/` | `loop_engine.py` · `research_agent.py` · `scan_health_check.py` |
| `docs/` | Policy-writing guide, per-rule remediation, maintenance runbook |

## Policies — 44 enforced rules (+ 31 draft)

| File | Rules | Covers |
|---|---|---|
| `pipeline-guardrails.rego` | PG-001–009 | Approvals, secrets, registries, rollback |
| `code-security.rego` | CS-001–009 | Hardcoded secrets, insecure functions, branch protection |
| `connector-compliance.rego` | CC-001–008 | Secret refs, credential expiry, auth type |
| `delegate-validation.rego` | DV-001–008 | Connectivity, version, privilege, resource limits |
| `bash-security.rego` | PI-001–003 | Bash security level, command whitelist/blocklist |
| `workflow-gates.rego` | PI-004/005/010 | Test-before-PR, human approval, audit log |
| `code-standards.rego` | PI-006–009 | Lint, secrets, test coverage, agent version |
| `research-proposals.rego` | RRP-001–031 (draft) | Threat-driven proposals awaiting review |

Retry budget on FAIL: **CRITICAL/HIGH** = 3 attempts · **MEDIUM** = 1 · **LOW** = advisory only.

## Quick start

```bash
opa test policies/opa/ policies/pi/ -v
```

Open a PR against `main` — the Loop Engine runs automatically and comments the result.

> GHE org policy blocks Actions from opening PRs, so the Research Agent
> files a GitHub Issue instead — a human drafts and opens the rule PR.

## Contributing

New rule → add `.rego` + `_test.rego` + an entry in
[`docs/violation-remediation.md`](docs/violation-remediation.md) → open a PR.
Exceptions go through an issue labeled `policy-exception`.

## Docs

[Policy guide](docs/policy-guide.md) ·
[Violation remediation](docs/violation-remediation.md) ·
[Maintenance runbook](docs/MAINTENANCE.md)
