# AI Agent Guardrails Hub

**Policy-as-code guardrails for Harness CI/CD and Pi coding agents.**

![AI Agent Guardrails Hub flow](docs/assets/guardrails-flow.svg)

## Features

- **Policy checks:** 44 OPA/Rego rules for pipelines, connectors, delegates, Bash, code, and workflow gates.
- **Auto-fix loop:** Evaluates PRs, attempts fixes, and escalates unresolved issues.
- **Threat research:** Weekly NVD and CISA KEV scans flag gaps for review.
- **Health checks:** Validate policies and agent specifications every 12 hours.

## Quick start

Requires [OPA](https://www.openpolicyagent.org/) v0.68.0.

```bash
opa test policies/opa/ policies/pi/ -v
```

> [!WARNING]
> Reference automation—not a production security boundary. Workflows can commit auto-fixes to PR pipeline YAML and create issues. Review all fixes before merging.

## Contributing

Add a rule, tests, and [remediation guidance](docs/violation-remediation.md), then open a PR.

**Docs:** [Policy guide](docs/policy-guide.md) · [Maintenance](docs/MAINTENANCE.md)
