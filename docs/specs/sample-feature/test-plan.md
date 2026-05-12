# Test Plan: Sample Feature

## Test Strategy

Validate that the template guard scripts can run against a sample feature.

## Unit Tests

None configured.

## Integration Tests

None configured.

## Regression Tests

None configured.

## Manual Verification

- Run `scripts/check-sdd-docs.sh sample-feature`.
- Run `scripts/run-tests.sh`.

## Not Tested

- Project-specific application behavior.

## Risks

- `scripts/run-tests.sh` must be replaced with real project test commands before production use.
