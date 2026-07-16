# ===========================================================================
# Unit Tests — Delegate Validation Policies
# Package: harness.delegate.validation_test
# Covers:  DV-001 through DV-008 (8 rules)
# Run with: opa test policies/opa/
# ===========================================================================

package harness.delegate.validation_test

import data.harness.delegate.validation

# ---------------------------------------------------------------------------
# Helper: a fully-compliant delegate and clean input
# ---------------------------------------------------------------------------

compliant_delegate := {
    "name": "prod-eu-west-delegate-01",
    "status": "ENABLED",
    "connected": true,
    "version": "24.01.81202",
    "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
    "security_context": {"run_as_user": 1000, "privileged": false},
    "spec": {"runAsRoot": false},
    "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
    "scope": {"type": "PROJECT", "project_identifier": "my-project"},
}

clean_input := {
    "delegates": [compliant_delegate],
    "policy": {"approved_delegate_versions": ["24.01.81202", "23.12.80308"]},
}

# ---------------------------------------------------------------------------
# DV-001 — Delegates must be active and connected
# ---------------------------------------------------------------------------

test_dv001_violation_delegate_status_not_enabled {
    result := validation.violation with input as {
        "delegates": [{"name": "prod-eu-west-delegate-01", "status": "DISABLED", "connected": false}],
        "policy": {"approved_delegate_versions": []},
    }
    count([v | v := result[_]; v.rule == "DV-001"]) > 0
}

test_dv001_violation_delegate_enabled_but_not_connected {
    result := validation.violation with input as {
        "delegates": [{"name": "prod-eu-west-delegate-01", "status": "ENABLED", "connected": false}],
        "policy": {"approved_delegate_versions": []},
    }
    count([v | v := result[_]; v.rule == "DV-001"]) > 0
}

test_dv001_pass_delegate_enabled_and_connected {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-001"]) == 0
}

# ---------------------------------------------------------------------------
# DV-002 — Delegates must run approved versions only
# ---------------------------------------------------------------------------

test_dv002_violation_unapproved_delegate_version {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "22.06.77229",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202", "23.12.80308"]},
    }
    count([v | v := result[_]; v.rule == "DV-002"]) > 0
}

test_dv002_pass_approved_delegate_version {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202", "23.12.80308"]},
    }
    count([v | v := result[_]; v.rule == "DV-002"]) == 0
}

test_dv002_pass_spec_version_field_takes_precedence {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "old-version",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false, "version": "24.01.81202"},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-002"]) == 0
}

# ---------------------------------------------------------------------------
# DV-003 — Delegates must carry org-approved tag
# ---------------------------------------------------------------------------

test_dv003_violation_missing_org_approved_tag {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-003"]) > 0
}

test_dv003_pass_org_approved_tag_present {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-003"]) == 0
}

# ---------------------------------------------------------------------------
# DV-004 — Delegates must not run as root user
# ---------------------------------------------------------------------------

test_dv004_violation_run_as_user_zero {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 0, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-004"]) > 0
}

test_dv004_violation_run_as_root_true_in_spec {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": true},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-004"]) > 0
}

test_dv004_violation_privileged_mode_enabled {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": true},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-004"]) > 0
}

test_dv004_pass_non_root_non_privileged_delegate {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-004"]) == 0
}

# ---------------------------------------------------------------------------
# DV-005 — Delegate must have resource limits defined
# ---------------------------------------------------------------------------

test_dv005_violation_missing_cpu_limit {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-005"]) > 0
}

test_dv005_violation_missing_memory_limit {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-005"]) > 0
}

test_dv005_pass_both_cpu_and_memory_limits_defined {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "2", "memory": "4Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-005"]) == 0
}

# ---------------------------------------------------------------------------
# DV-006 — Delegates must be assigned to correct scope
# ---------------------------------------------------------------------------

test_dv006_violation_invalid_scope_type {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "UNKNOWN"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-006"]) > 0
}

test_dv006_violation_project_scope_missing_project_identifier {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "PROJECT"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-006"]) > 0
}

test_dv006_pass_org_scope {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-006"]) == 0
}

test_dv006_pass_project_scope_with_project_identifier {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "PROJECT", "project_identifier": "my-project"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-006"]) == 0
}

# ---------------------------------------------------------------------------
# DV-007 — Delegate names must follow naming convention
# ---------------------------------------------------------------------------

test_dv007_violation_uppercase_delegate_name {
    result := validation.violation with input as {
        "delegates": [{
            "name": "MyDelegate",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-007"]) > 0
}

test_dv007_violation_missing_delegate_suffix_and_index {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-007"]) > 0
}

test_dv007_pass_valid_delegate_name {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-007"]) == 0
}

test_dv007_pass_minimal_valid_delegate_name {
    result := validation.violation with input as {
        "delegates": [{
            "name": "dev-delegate-02",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-007"]) == 0
}

# ---------------------------------------------------------------------------
# DV-008 — Delegates must have owner and cost-centre tags
# ---------------------------------------------------------------------------

test_dv008_violation_missing_owner_tag {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-008"; v.tag == "owner"]) > 0
}

test_dv008_violation_missing_cost_centre_tag {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-008"; v.tag == "cost-centre"]) > 0
}

test_dv008_pass_bare_tag_format {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner", "cost-centre"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-008"]) == 0
}

test_dv008_pass_key_value_tag_format {
    result := validation.violation with input as {
        "delegates": [{
            "name": "prod-eu-west-delegate-01",
            "status": "ENABLED",
            "connected": true,
            "version": "24.01.81202",
            "tags": ["org-approved", "owner:platform-team", "cost-centre:CC-001"],
            "security_context": {"run_as_user": 1000, "privileged": false},
            "spec": {"runAsRoot": false},
            "resources": {"limits": {"cpu": "1", "memory": "2Gi"}},
            "scope": {"type": "ORG"},
        }],
        "policy": {"approved_delegate_versions": ["24.01.81202"]},
    }
    count([v | v := result[_]; v.rule == "DV-008"]) == 0
}

# ---------------------------------------------------------------------------
# Overall allow / deny
# ---------------------------------------------------------------------------

test_allow_when_delegate_is_fully_compliant {
    validation.allow with input as clean_input
}

test_deny_when_delegate_is_disabled {
    not validation.allow with input as {
        "delegates": [{"name": "prod-eu-west-delegate-01", "status": "DISABLED", "connected": false}],
        "policy": {"approved_delegate_versions": []},
    }
}
