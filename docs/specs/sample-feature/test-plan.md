# Test Plan: Sample Feature

## Test Strategy

Validate that the template guard scripts can run against a sample feature and that shell scripts are syntactically valid.

## Unit Tests

- `bash -n scripts/*.sh` through `scripts/run-tests.sh`

## Integration Tests

- `scripts/check-sdd-docs.sh sample-feature`

## Regression Tests

- `scripts/run-tests.sh`

## Manual Verification

- Run `scripts/check-sdd-docs.sh sample-feature`.
- Run `scripts/run-tests.sh`.

## Not Tested

- Project-specific application behavior.

## Risks

- `scripts/run-tests.sh` must be replaced with real project test commands before production use.
- `AI_TEST_COMMANDS` can be used to inject project-specific test commands without editing the template.
