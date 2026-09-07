# ===========================================================================
# Unit Tests — Harness Pipeline Guardrail Policies
# Package: harness.pipeline.guardrails_test
# Covers:  PG-001 through PG-009 (9 rules)
# Run with: opa test policies/opa/
# ===========================================================================

package harness.pipeline.guardrails_test

import data.harness.pipeline.guardrails

# ---------------------------------------------------------------------------
# Helper: minimal fully-passing pipeline (empty stages)
# ---------------------------------------------------------------------------

clean_pipeline := {
    "pipeline": {
        "name": "deploy-pipeline",
        "description": "Main deployment pipeline",
        "tags": {
            "owner": "platform-team",
            "cost-centre": "CC-1234",
        },
        "stages": [],
    },
}

# ---------------------------------------------------------------------------
# PG-001 — Approval gate required before production deploy
# ---------------------------------------------------------------------------

test_pg001_violation_production_stage_no_approval {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}}],
                    "rollbackSteps": [{"step": {"name": "rollback", "type": "K8sRollingRollback", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-001"]) > 0
}

test_pg001_violation_prod_env_name_prefix_no_approval {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "prod-stage",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"name": "prod-eu-west"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}}],
                    "rollbackSteps": [{"step": {"name": "rollback", "type": "K8sRollingRollback", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-001"]) > 0
}

test_pg001_pass_production_stage_with_harness_approval {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [
                        {"step": {"name": "approve", "type": "HarnessApproval", "spec": {}}},
                        {"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}},
                    ],
                    "rollbackSteps": [{"step": {"name": "rollback", "type": "K8sRollingRollback", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-001"]) == 0
}

test_pg001_violation_approval_step_after_deploy_step {
    # has_approval_step previously only checked membership, not ordering — an
    # approval step placed AFTER the deploy step still counted as compliant.
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [
                        {"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}},
                        {"step": {"name": "approve", "type": "HarnessApproval", "spec": {}}},
                    ],
                    "rollbackSteps": [{"step": {"name": "rollback", "type": "K8sRollingRollback", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-001"]) > 0
}

test_pg001_pass_non_production_stage_no_approval_needed {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-dev",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Development"},
                    "spec": {"delegateSelectors": ["dev-delegate"]},
                },
                "execution": {"steps": [{"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}}]},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-001"]) == 0
}

# ---------------------------------------------------------------------------
# PG-002 — No plaintext secrets in pipeline YAML
# ---------------------------------------------------------------------------

test_pg002_violation_plaintext_secret_in_env_variables {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"envVariables": {"API_KEY": "my-hardcoded-secret-value"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-002"]) > 0
}

test_pg002_violation_plaintext_secret_in_env {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"env": {"DB_PASSWORD": "plaintextpassword123"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-002"]) > 0
}

test_pg002_pass_secret_reference_in_env_variables {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"envVariables": {"API_KEY": "<+secrets.getValue(\"my-api-key\")>"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-002"]) == 0
}

test_pg002_pass_pipeline_variable_reference {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"envVariables": {"API_TOKEN": "<+pipeline.variables.api_token>"}},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-002"]) == 0
}

# ---------------------------------------------------------------------------
# PG-003 — Container images must use approved registries
# ---------------------------------------------------------------------------

test_pg003_violation_public_docker_image {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"image": "nginx:latest"},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-003"]) > 0
}

test_pg003_violation_unregistered_gcr_project {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"image": "gcr.io/external-project/app:1.0"},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-003"]) > 0
}

test_pg003_pass_approved_gcr_registry {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"image": "gcr.io/deloitte-platform/app:1.2.3"},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-003"]) == 0
}

test_pg003_pass_approved_ghcr_registry {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "spec": {"execution": {"steps": [{
                "step": {
                    "name": "run-step",
                    "type": "Run",
                    "spec": {"image": "ghcr.io/deloitte-global-cloud-services/myapp:v2"},
                },
            }]}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-003"]) == 0
}

# ---------------------------------------------------------------------------
# PG-004 — Pipeline stage timeout must be set
# ---------------------------------------------------------------------------

test_pg004_violation_stage_missing_timeout {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{"name": "build", "spec": {"execution": {"steps": []}}}]},
    }
    count([v | v := result[_]; v.rule == "PG-004"]) > 0
}

test_pg004_violation_invalid_timeout_format {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{"name": "build", "timeout": "60seconds", "spec": {"execution": {"steps": []}}}]},
    }
    count([v | v := result[_]; v.rule == "PG-004"]) > 0
}

test_pg004_pass_timeout_in_hours {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{"name": "build", "timeout": "1h", "spec": {"execution": {"steps": []}}}]},
    }
    count([v | v := result[_]; v.rule == "PG-004"]) == 0
}

test_pg004_pass_timeout_in_minutes {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{"name": "build", "timeout": "30m", "spec": {"execution": {"steps": []}}}]},
    }
    count([v | v := result[_]; v.rule == "PG-004"]) == 0
}

# ---------------------------------------------------------------------------
# PG-005 — Delegate selector must be specified for deploy stages
# ---------------------------------------------------------------------------

test_pg005_violation_deployment_stage_empty_delegate_selectors {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {
                "infrastructure": {"spec": {"delegateSelectors": []}},
                "execution": {"steps": []},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-005"]) > 0
}

test_pg005_pass_deployment_stage_with_named_delegate {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {
                "infrastructure": {"spec": {"delegateSelectors": ["prod-eu-west-delegate-01"]}},
                "execution": {"steps": []},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-005"]) == 0
}

test_pg005_pass_non_deployment_stage_no_selector_needed {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "build",
            "type": "CI",
            "spec": {"execution": {"steps": []}},
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-005"]) == 0
}

# ---------------------------------------------------------------------------
# PG-006 — No wildcard delegate selector
# ---------------------------------------------------------------------------

test_pg006_violation_wildcard_in_infra_delegate_selectors {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {
                "infrastructure": {"spec": {"delegateSelectors": ["*"]}},
                "execution": {"steps": []},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-006"]) > 0
}

test_pg006_pass_named_delegate_selector {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {
                "infrastructure": {"spec": {"delegateSelectors": ["prod-eu-west-delegate-01"]}},
                "execution": {"steps": []},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-006"]) == 0
}

test_pg006_violation_wildcard_in_flat_delegate_selectors {
    # has_delegate_selector (PG-005) treats the flat stage.spec.delegateSelectors
    # path as equally valid to the nested infra path — PG-006 must catch a
    # wildcard there too, not just under infrastructure.spec.
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy",
            "type": "Deployment",
            "spec": {
                "delegateSelectors": ["*"],
                "execution": {"steps": []},
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-006"]) > 0
}

# ---------------------------------------------------------------------------
# PG-007 — Rollback strategy required for production deployments
# ---------------------------------------------------------------------------

test_pg007_violation_production_deployment_no_rollback_block {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "approve", "type": "HarnessApproval", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-007"]) > 0
}

test_pg007_violation_production_deployment_empty_rollback_steps {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "approve", "type": "HarnessApproval", "spec": {}}}],
                    "rollbackSteps": [],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-007"]) > 0
}

test_pg007_pass_production_deployment_with_rollback_steps {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-prod",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Production"},
                    "spec": {"delegateSelectors": ["prod-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "approve", "type": "HarnessApproval", "spec": {}}}],
                    "rollbackSteps": [{"step": {"name": "rollback", "type": "K8sRollingRollback", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-007"]) == 0
}

test_pg007_pass_non_production_deployment_no_rollback_required {
    result := guardrails.violation with input as {
        "pipeline": {"stages": [{
            "name": "deploy-staging",
            "type": "Deployment",
            "spec": {
                "infrastructure": {
                    "environment": {"type": "Staging"},
                    "spec": {"delegateSelectors": ["staging-delegate"]},
                },
                "execution": {
                    "steps": [{"step": {"name": "deploy", "type": "K8sRollingDeploy", "spec": {}}}],
                },
            },
        }]},
    }
    count([v | v := result[_]; v.rule == "PG-007"]) == 0
}

# ---------------------------------------------------------------------------
# PG-008 — Pipeline must have a description
# ---------------------------------------------------------------------------

test_pg008_violation_pipeline_missing_description {
    result := guardrails.violation with input as {
        "pipeline": {"name": "test-pipeline", "stages": []},
    }
    count([v | v := result[_]; v.rule == "PG-008"]) > 0
}

test_pg008_violation_pipeline_blank_description {
    result := guardrails.violation with input as {
        "pipeline": {"name": "test-pipeline", "description": "   ", "stages": []},
    }
    count([v | v := result[_]; v.rule == "PG-008"]) > 0
}

test_pg008_pass_pipeline_with_description {
    result := guardrails.violation with input as {
        "pipeline": {"name": "test-pipeline", "description": "Main CI/CD deployment pipeline", "stages": []},
    }
    count([v | v := result[_]; v.rule == "PG-008"]) == 0
}

# ---------------------------------------------------------------------------
# PG-009 — Required pipeline tags must be present
# ---------------------------------------------------------------------------

test_pg009_violation_missing_owner_tag {
    result := guardrails.violation with input as {
        "pipeline": {
            "name": "test-pipeline",
            "description": "A pipeline",
            "tags": {"cost-centre": "CC-001"},
            "stages": [],
        },
    }
    count([v | v := result[_]; v.rule == "PG-009"; v.tag == "owner"]) > 0
}

test_pg009_violation_missing_cost_centre_tag {
    result := guardrails.violation with input as {
        "pipeline": {
            "name": "test-pipeline",
            "description": "A pipeline",
            "tags": {"owner": "platform-team"},
            "stages": [],
        },
    }
    count([v | v := result[_]; v.rule == "PG-009"; v.tag == "cost-centre"]) > 0
}

test_pg009_pass_all_required_tags_present {
    result := guardrails.violation with input as {
        "pipeline": {
            "name": "test-pipeline",
            "description": "A pipeline",
            "tags": {"owner": "platform-team", "cost-centre": "CC-001"},
            "stages": [],
        },
    }
    count([v | v := result[_]; v.rule == "PG-009"]) == 0
}

# ---------------------------------------------------------------------------
# Overall allow / deny
# ---------------------------------------------------------------------------

test_allow_when_pipeline_is_fully_compliant {
    guardrails.allow with input as clean_pipeline
}

test_deny_when_pipeline_missing_description_and_tags {
    not guardrails.allow with input as {"pipeline": {"name": "incomplete", "stages": []}}
}
