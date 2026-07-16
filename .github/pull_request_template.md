## Summary

<!-- What does this PR do? One or two sentences. -->

## Type of change

- [ ] New OPA rule (`policy/`)
- [ ] Bug fix (`fix/`)
- [ ] Documentation (`docs/`)
- [ ] New feature (`feat/`)
- [ ] Test (`test/`)

## Checklist

- [ ] Branch name follows convention: `policy/` · `fix/` · `docs/` · `feat/` · `test/`
- [ ] Every new OPA rule has a matching test in `_test.rego` (PASS + FAIL case)
- [ ] New rule documented in `docs/violation-remediation.md` with anchor link
- [ ] New rule added to the rule table in `README.md`
- [ ] `opa test policies/opa/` passes locally (Harness rules)
- [ ] `opa test policies/pi/` passes locally (Pi rules)
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] Loop Engine will validate this PR automatically once opened

## Related issues

<!-- e.g. Closes #123 -->

## Notes for reviewers

<!-- Any context that helps the reviewer — schema changes, edge cases, etc. -->
