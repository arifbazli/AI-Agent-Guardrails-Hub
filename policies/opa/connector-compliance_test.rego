# ===========================================================================
# Unit Tests — Connector Compliance Policies
# Package: harness.connector.compliance_test
# Covers:  CC-001 through CC-008 (8 rules)
# Run with: opa test policies/opa/
# ===========================================================================

package harness.connector.compliance_test

import data.harness.connector.compliance

# ---------------------------------------------------------------------------
# Helper: a fully-compliant connector
# ---------------------------------------------------------------------------

compliant_connector := {
    "identifier": "custom-dev-api",
    "description": "Internal API connector for the development environment",
    "tags": {"owner": "platform-team", "team": "infrastructure"},
    "spec": {
        "credentials": {"token": "<+secrets.getValue(\"api-token\")>"},
        "authentication": {"type": "BearerToken"},
    },
}

clean_input := {"connectors": [compliant_connector]}

# ---------------------------------------------------------------------------
# CC-001 — All connectors must use secret references
# ---------------------------------------------------------------------------

test_cc001_violation_plaintext_password_in_credentials {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"password": "plaintext-password"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-001"]) > 0
}

test_cc001_violation_plaintext_token_in_credentials {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "gitlab-dev-repo",
            "spec": {"credentials": {"token": "my-raw-access-token"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-001"]) > 0
}

test_cc001_pass_harness_secret_reference_for_password {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"password": "<+secrets.getValue(\"github-token\")>"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-001"]) == 0
}

test_cc001_pass_ng_secret_manager_reference {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"password": "${ngSecretManager.obtain(\"git-token\", \"account\")}"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-001"]) == 0
}

# ---------------------------------------------------------------------------
# CC-002 — No expired connector credentials allowed
# ---------------------------------------------------------------------------

test_cc002_violation_expired_credentials {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "legacy-prod-connector",
            "spec": {"credentials": {"expiry_date": "2020-01-01T00:00:00Z"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-002"]) > 0
}

test_cc002_pass_future_expiry_date {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"expiry_date": "2099-12-31T23:59:59Z"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-002"]) == 0
}

test_cc002_pass_no_expiry_date_field {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"token": "<+secrets.getValue(\"token\")>"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-002"]) == 0
}

# ---------------------------------------------------------------------------
# CC-003 — Connectors must use approved authentication types
# ---------------------------------------------------------------------------

test_cc003_violation_username_password_auth_type {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "internal-dev-svc",
            "spec": {"authentication": {"type": "UsernamePassword"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-003"]) > 0
}

test_cc003_violation_basic_auth_type {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "internal-dev-svc",
            "spec": {"authentication": {"type": "BasicAuth"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-003"]) > 0
}

test_cc003_pass_github_app_auth_type {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"authentication": {"type": "GitHubApp"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-003"]) == 0
}

test_cc003_pass_oidc_auth_type {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "k8s-prod-cluster",
            "spec": {"authentication": {"type": "OpenIDConnect"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-003"]) == 0
}

# ---------------------------------------------------------------------------
# CC-004 — Git connectors must use SSH or token auth only
# ---------------------------------------------------------------------------

test_cc004_violation_github_connector_username_password {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-dev-repo",
            "type": "Github",
            "spec": {"authentication": {"type": "UsernamePassword"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-004"]) > 0
}

test_cc004_violation_gitlab_connector_basic_auth {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "gitlab-prod-mono",
            "type": "Gitlab",
            "spec": {"authentication": {"type": "BasicAuth"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-004"]) > 0
}

test_cc004_pass_github_connector_github_app_auth {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "type": "Github",
            "spec": {"authentication": {"type": "GitHubApp"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-004"]) == 0
}

test_cc004_pass_github_connector_ssh_key_auth {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "type": "Github",
            "spec": {"authentication": {"type": "SSHKey"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-004"]) == 0
}

# ---------------------------------------------------------------------------
# CC-005 — Cloud connectors must use IAM roles not keys
# ---------------------------------------------------------------------------

test_cc005_violation_aws_connector_access_key {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "aws-prod-main",
            "type": "Aws",
            "spec": {"credential": {"type": "AccessKey"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-005"]) > 0
}

test_cc005_violation_gcp_connector_service_account_key {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "gcp-prod-infra",
            "type": "Gcp",
            "spec": {"credential": {"type": "ServiceAccountKey"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-005"]) > 0
}

test_cc005_violation_azure_connector_service_principal_secret {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "azure-prod-core",
            "type": "Azure",
            "spec": {"credential": {"type": "ServicePrincipalSecret"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-005"]) > 0
}

test_cc005_pass_aws_connector_irsa_auth {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "aws-prod-main",
            "type": "Aws",
            "spec": {"credential": {"type": "IRSA"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-005"]) == 0
}

test_cc005_pass_gcp_connector_workload_identity {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "gcp-prod-infra",
            "type": "Gcp",
            "spec": {"credential": {"type": "WorkloadIdentity"}},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-005"]) == 0
}

# ---------------------------------------------------------------------------
# CC-006 — Connectors must have owner and team tags
# ---------------------------------------------------------------------------

test_cc006_violation_missing_owner_tag {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "tags": {"team": "platform"},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-006"; v.tag == "owner"]) > 0
}

test_cc006_violation_missing_team_tag {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "tags": {"owner": "platform-team"},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-006"; v.tag == "team"]) > 0
}

test_cc006_pass_all_required_tags_present {
    result := compliance.violation with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "tags": {"owner": "platform-team", "team": "infrastructure"},
        }],
    }
    count([v | v := result[_]; v.rule == "CC-006"]) == 0
}

# ---------------------------------------------------------------------------
# CC-007 — Connector names must follow naming convention
# ---------------------------------------------------------------------------

test_cc007_violation_uppercase_connector_name {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "MyConnector"}],
    }
    count([v | v := result[_]; v.rule == "CC-007"]) > 0
}

test_cc007_violation_too_few_hyphen_segments {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "aws-prod"}],
    }
    count([v | v := result[_]; v.rule == "CC-007"]) > 0
}

test_cc007_pass_valid_three_segment_name {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "aws-prod-main"}],
    }
    count([v | v := result[_]; v.rule == "CC-007"]) == 0
}

test_cc007_pass_valid_four_segment_name {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "github-dev-frontend-app"}],
    }
    count([v | v := result[_]; v.rule == "CC-007"]) == 0
}

# ---------------------------------------------------------------------------
# CC-008 — Connectors must have a description field
# ---------------------------------------------------------------------------

test_cc008_violation_connector_missing_description {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "aws-prod-main"}],
    }
    count([v | v := result[_]; v.rule == "CC-008"]) > 0
}

test_cc008_violation_connector_blank_description {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "aws-prod-main", "description": "   "}],
    }
    count([v | v := result[_]; v.rule == "CC-008"]) > 0
}

test_cc008_pass_connector_with_description {
    result := compliance.violation with input as {
        "connectors": [{"identifier": "aws-prod-main", "description": "AWS connector for the production environment"}],
    }
    count([v | v := result[_]; v.rule == "CC-008"]) == 0
}

# ---------------------------------------------------------------------------
# Overall allow / deny
# ---------------------------------------------------------------------------

test_allow_when_connector_is_fully_compliant {
    compliance.allow with input as clean_input
}

test_deny_when_connector_has_plaintext_credentials {
    not compliance.allow with input as {
        "connectors": [{
            "identifier": "github-prod-api",
            "spec": {"credentials": {"password": "hardcoded-secret"}},
        }],
    }
}
