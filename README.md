# AI Agent Guardrails Hub

**Policy-as-code guardrails for Harness CI/CD and Pi coding agents.**

[![Policy CI](https://github.com/arifbazli/AI-Agent-Guardrails-Hub/actions/workflows/policy-ci.yml/badge.svg)](https://github.com/arifbazli/AI-Agent-Guardrails-Hub/actions/workflows/policy-ci.yml)
![OPA](https://img.shields.io/badge/OPA-v0.68.0-7d9199?logo=openpolicyagent&logoColor=white)
![Rules](https://img.shields.io/badge/rules-44_enforced_·_31_draft-0f766e)
![Python](https://img.shields.io/badge/python-3.11+-3776ab?logo=python&logoColor=white)

![AI Agent Guardrails Hub flow](docs/assets/guardrails-flow.svg)

## Features

- **Policy CI:** `opa check`, 199 OPA tests and Loop Engine specs on every PR.
- **Loop Engine:** Checks PR-changed pipeline YAML and Pi activity, auto-fixes, and escalates. Fails closed; never edits policies, fixtures or workflows.
- **Threat research:** Weekly NVD and CISA KEV scans flag rule gaps for review.
- **Health checks:** Validate policies and agent specs every 12 hours.

## Roadmap

Self-updating, multi-agent rule pipeline: **triage → draft → verify → review → warn-only → human promotion**. Only additions are automated; blocking rules always need human approval.

## Quick start

```bash
opa test policies/opa/ policies/pi/ -v      # OPA v0.68.0
python3 -m unittest discover -s tests -v    # requires pyyaml
```

> [!WARNING]
> Reference automation—not a production security boundary. Review all auto-fixes before merging.

## Contributing

Add a rule, tests, and [remediation guidance](docs/violation-remediation.md), then open a PR.

**Docs:** [Policy guide](docs/policy-guide.md) · [Maintenance](docs/MAINTENANCE.md)
