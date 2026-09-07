# ===========================================================================
# Unit Tests — Research Agent Proposed Policy Rules (DRAFT)
# Package: harness.research.proposals_test
# Covers:  RRP-012, RRP-017 — the two rules found to have real logic bugs
#          during audit and fixed in research-proposals.rego. Most of the
#          other 29 draft rules in this file still have no test coverage;
#          add tests here as each rule is reviewed for promotion.
# Run with: opa test policies/opa/
# ===========================================================================

package harness.research.proposals_test

import data.harness.research.proposals

# ---------------------------------------------------------------------------
# RRP-012 — Inter-stage artifact attestation / SLSA provenance
# ---------------------------------------------------------------------------

test_rrp012_violation_deployment_stage_no_provenance_verify {
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {"execution": {"steps": [{"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}}]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-012"]) > 0
}

test_rrp012_pass_deployment_stage_with_provenance_verify {
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {"execution": {"steps": [
                {"step": {"name": "verify", "type": "CosignVerify", "spec": {}}},
                {"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}},
            ]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-012"]) == 0
}

test_rrp012_pass_non_deployment_stage_type_not_flagged {
    # deploy_stage_types must match pipeline-guardrails.rego's PG-005/PG-007
    # convention exactly (exact "Deployment" only) — "Deploy" is not a
    # recognised stage type anywhere in the active policy set, so it must
    # not be treated as a deploy stage here either.
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deploy",
            "spec": {"execution": {"steps": []}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-012"]) == 0
}

# ---------------------------------------------------------------------------
# RRP-017 — Hardcoded plaintext credentials in pipeline YAML
# ---------------------------------------------------------------------------

test_rrp017_violation_plaintext_secret_value_matched_by_key_name {
    # Regression test for the fixed key/value iteration bug: env_key must
    # bind to the variable NAME (checked against secret_like_patterns), and
    # a realistic secret value like "hunter2" — which contains no
    # "password=" substring — must still be caught because the key itself
    # ("DB_PASSWORD") looks like a credential name.
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run",
                    "type": "Run",
                    "spec": {"envVariables": {"DB_PASSWORD": "hunter2"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-017"]) > 0
}

test_rrp017_pass_secret_reference {
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run",
                    "type": "Run",
                    "spec": {"envVariables": {"DB_PASSWORD": "<+secrets.getValue(\"db-password\")>"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-017"]) == 0
}

test_rrp017_pass_non_secret_key_name {
    result := proposals.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run",
                    "type": "Run",
                    "spec": {"envVariables": {"LOG_LEVEL": "debug"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "RRP-017"]) == 0
}
