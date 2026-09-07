# ===========================================================================
# Unit Tests — Code Security Policies
# Package: harness.code.security_test
# Covers:  CS-001 through CS-009 (9 rules)
# Run with: opa test policies/opa/
# ===========================================================================

package harness.code.security_test

import data.harness.code.security

# ---------------------------------------------------------------------------
# Helper: minimal fully-passing input
# ---------------------------------------------------------------------------

clean_input := {
    "files": [{"path": "src/app.go", "content": "// Copyright 2026 Deloitte. All rights reserved.\n\npackage main\n\nfunc main() {}\n"}],
    "commit": {"branch": "feature/my-feature", "is_merge_commit": false},
    "repository": {
        "name": "my-repo",
        "branch_protection": {"enabled": true, "require_pull_request_reviews": true},
    },
    "pull_request": {"number": 1, "checks": {"sast": {"passed": true}}},
    "environment": {"variables": {"APP_ENV": "staging"}},
}

# ---------------------------------------------------------------------------
# CS-001 — No hardcoded API keys or tokens in code
# ---------------------------------------------------------------------------

test_cs001_violation_aws_access_key_in_file {
    result := security.violation with input as {
        "files": [{"path": "config.js", "content": "const key = \"AKIAIOSFODNN7EXAMPLE\""}],
    }
    count([v | v := result[_]; v.rule == "CS-001"]) > 0
}

test_cs001_violation_api_key_assignment_in_file {
    result := security.violation with input as {
        "files": [{"path": "config.py", "content": "api_key = \"abcdefghijklmnopqrstuvwxyz1234\""}],
    }
    count([v | v := result[_]; v.rule == "CS-001"]) > 0
}

test_cs001_pass_no_api_key_in_file {
    result := security.violation with input as {
        "files": [{"path": "config.js", "content": "const baseUrl = \"https://api.example.com\"\nconst version = \"v1\""}],
    }
    count([v | v := result[_]; v.rule == "CS-001"]) == 0
}

# ---------------------------------------------------------------------------
# CS-002 — No hardcoded passwords or credentials
# ---------------------------------------------------------------------------

test_cs002_violation_hardcoded_password_in_source {
    result := security.violation with input as {
        "files": [{"path": "db.py", "content": "password = \"mySuperSecret123\""}],
    }
    count([v | v := result[_]; v.rule == "CS-002"]) > 0
}

test_cs002_violation_hardcoded_db_password {
    result := security.violation with input as {
        "files": [{"path": "config.go", "content": "db_password = \"mysecretdbpass\""}],
    }
    count([v | v := result[_]; v.rule == "CS-002"]) > 0
}

test_cs002_pass_password_from_env_var {
    result := security.violation with input as {
        "files": [{"path": "db.py", "content": "password = os.environ['DB_PASSWORD']"}],
    }
    count([v | v := result[_]; v.rule == "CS-002"]) == 0
}

test_cs002_violation_unquoted_password {
    # password_patterns previously required surrounding quotes, so an
    # unquoted literal assignment bypassed detection entirely.
    result := security.violation with input as {
        "files": [{"path": "config.py", "content": "PASSWORD=mySuperSecret123"}],
    }
    count([v | v := result[_]; v.rule == "CS-002"]) > 0
}

# ---------------------------------------------------------------------------
# CS-003 — No use of deprecated or insecure functions
# ---------------------------------------------------------------------------

test_cs003_violation_eval_call {
    result := security.violation with input as {
        "files": [{"path": "app.js", "content": "const result = eval(userInput)"}],
    }
    count([v | v := result[_]; v.rule == "CS-003"]) > 0
}

test_cs003_violation_md5_hash {
    result := security.violation with input as {
        "files": [{"path": "crypto.py", "content": "digest = MD5(data)"}],
    }
    count([v | v := result[_]; v.rule == "CS-003"]) > 0
}

test_cs003_violation_pickle_loads {
    result := security.violation with input as {
        "files": [{"path": "loader.py", "content": "obj = pickle.loads(raw_bytes)"}],
    }
    count([v | v := result[_]; v.rule == "CS-003"]) > 0
}

test_cs003_pass_sha256_instead_of_insecure_hash {
    result := security.violation with input as {
        "files": [{"path": "crypto.py", "content": "from hashlib import sha256\ndigest = sha256(data).hexdigest()"}],
    }
    count([v | v := result[_]; v.rule == "CS-003"]) == 0
}

# ---------------------------------------------------------------------------
# CS-004 — No direct commits to main/master branch
# ---------------------------------------------------------------------------

test_cs004_violation_direct_commit_to_main {
    result := security.violation with input as {
        "commit": {"branch": "main", "is_merge_commit": false},
    }
    count([v | v := result[_]; v.rule == "CS-004"]) > 0
}

test_cs004_violation_direct_commit_to_master {
    result := security.violation with input as {
        "commit": {"branch": "master", "is_merge_commit": false},
    }
    count([v | v := result[_]; v.rule == "CS-004"]) > 0
}

test_cs004_pass_merge_commit_to_main {
    result := security.violation with input as {
        "commit": {"branch": "main", "is_merge_commit": true},
    }
    count([v | v := result[_]; v.rule == "CS-004"]) == 0
}

test_cs004_pass_direct_commit_to_feature_branch {
    result := security.violation with input as {
        "commit": {"branch": "feature/my-feature", "is_merge_commit": false},
    }
    count([v | v := result[_]; v.rule == "CS-004"]) == 0
}

# ---------------------------------------------------------------------------
# CS-005 — Branch protection rules must be enabled
# ---------------------------------------------------------------------------

test_cs005_violation_branch_protection_disabled {
    result := security.violation with input as {
        "repository": {"name": "my-repo", "branch_protection": {"enabled": false}},
    }
    count([v | v := result[_]; v.rule == "CS-005"]) > 0
}

test_cs005_violation_pr_reviews_not_required {
    result := security.violation with input as {
        "repository": {
            "name": "my-repo",
            "branch_protection": {"enabled": true, "require_pull_request_reviews": false},
        },
    }
    count([v | v := result[_]; v.rule == "CS-005"]) > 0
}

test_cs005_pass_branch_protection_fully_configured {
    result := security.violation with input as {
        "repository": {
            "name": "my-repo",
            "branch_protection": {"enabled": true, "require_pull_request_reviews": true},
        },
    }
    count([v | v := result[_]; v.rule == "CS-005"]) == 0
}

# ---------------------------------------------------------------------------
# CS-006 — Code must pass SAST scan before merge
# ---------------------------------------------------------------------------

test_cs006_violation_sast_scan_failed {
    result := security.violation with input as {
        "pull_request": {"number": 42, "checks": {"sast": {"passed": false}}},
    }
    count([v | v := result[_]; v.rule == "CS-006"]) > 0
}

test_cs006_pass_sast_scan_passed {
    result := security.violation with input as {
        "pull_request": {"number": 42, "checks": {"sast": {"passed": true}}},
    }
    count([v | v := result[_]; v.rule == "CS-006"]) == 0
}

# ---------------------------------------------------------------------------
# CS-007 — No sensitive data in environment variables
# ---------------------------------------------------------------------------

test_cs007_violation_plaintext_api_key_env_var {
    result := security.violation with input as {
        "environment": {"variables": {"API_KEY": "my-plain-text-key"}},
    }
    count([v | v := result[_]; v.rule == "CS-007"]) > 0
}

test_cs007_violation_plaintext_password_env_var {
    result := security.violation with input as {
        "environment": {"variables": {"DB_PASSWORD": "s3cr3tpassword"}},
    }
    count([v | v := result[_]; v.rule == "CS-007"]) > 0
}

test_cs007_pass_secret_reference_in_env_var {
    result := security.violation with input as {
        "environment": {"variables": {"API_KEY": "<+secrets.getValue(\"api-key\")>"}},
    }
    count([v | v := result[_]; v.rule == "CS-007"]) == 0
}

test_cs007_pass_non_sensitive_env_var {
    result := security.violation with input as {
        "environment": {"variables": {"APP_ENV": "production", "LOG_LEVEL": "info"}},
    }
    count([v | v := result[_]; v.rule == "CS-007"]) == 0
}

# ---------------------------------------------------------------------------
# CS-008 — Code files must have license headers
# ---------------------------------------------------------------------------

test_cs008_violation_go_source_file_missing_license_header {
    result := security.violation with input as {
        "files": [{"path": "src/app.go", "content": "package main\n\nfunc main() {}"}],
    }
    count([v | v := result[_]; v.rule == "CS-008"]) > 0
}

test_cs008_violation_python_source_file_missing_license_header {
    result := security.violation with input as {
        "files": [{"path": "src/service.py", "content": "def run():\n    pass"}],
    }
    count([v | v := result[_]; v.rule == "CS-008"]) > 0
}

test_cs008_pass_source_file_with_copyright_header {
    result := security.violation with input as {
        "files": [{"path": "src/app.go", "content": "// Copyright 2026 Deloitte. All rights reserved.\n\npackage main\n\nfunc main() {}"}],
    }
    count([v | v := result[_]; v.rule == "CS-008"]) == 0
}

test_cs008_pass_source_file_with_spdx_header {
    result := security.violation with input as {
        "files": [{"path": "src/app.js", "content": "// SPDX-License-Identifier: Apache-2.0\n\nconsole.log('hello')"}],
    }
    count([v | v := result[_]; v.rule == "CS-008"]) == 0
}

test_cs008_pass_non_source_file_no_license_check {
    result := security.violation with input as {
        "files": [{"path": "README.md", "content": "# My Project\n\nNo license header required."}],
    }
    count([v | v := result[_]; v.rule == "CS-008"]) == 0
}

# ---------------------------------------------------------------------------
# CS-009 — No debug or test code left in production files
# ---------------------------------------------------------------------------

test_cs009_violation_console_log_in_js_file {
    result := security.violation with input as {
        "files": [{"path": "src/app.js", "content": "// Copyright 2026 Deloitte\nconsole.log('debug value')"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) > 0
}

test_cs009_violation_todo_comment_in_source {
    result := security.violation with input as {
        "files": [{"path": "src/service.py", "content": "# Copyright 2026 Deloitte\n# TODO: fix this later\ndef run(): pass"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) > 0
}

test_cs009_violation_pdb_set_trace_in_python {
    result := security.violation with input as {
        "files": [{"path": "src/handler.py", "content": "# Copyright 2026 Deloitte\nimport pdb\npdb.set_trace()"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) > 0
}

test_cs009_violation_fstring_debug_print {
    # The debug pattern previously required the quote to immediately follow
    # the parenthesis, so an f-string debug print (print(f"debug: ...")) bypassed it.
    result := security.violation with input as {
        "files": [{"path": "src/handler.py", "content": "# Copyright 2026 Deloitte\nprint(f\"debug: {value}\")"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) > 0
}

test_cs009_pass_clean_go_source_file {
    result := security.violation with input as {
        "files": [{"path": "src/app.go", "content": "// Copyright 2026 Deloitte. All rights reserved.\n\npackage main\n\nfunc main() {}\n"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) == 0
}

test_cs009_pass_non_source_file_debug_not_checked {
    result := security.violation with input as {
        "files": [{"path": "notes.txt", "content": "TODO: remember to update the docs"}],
    }
    count([v | v := result[_]; v.rule == "CS-009"]) == 0
}

# ---------------------------------------------------------------------------
# Overall allow / deny
# ---------------------------------------------------------------------------

test_allow_when_all_security_checks_pass {
    security.allow with input as clean_input
}

test_deny_when_secret_is_hardcoded {
    not security.allow with input as {
        "files": [{"path": "config.py", "content": "password = \"mySuperSecret123\""}],
    }
}
