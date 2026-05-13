# Quickstart: Sample Feature

## Prerequisites

- Bash-compatible shell
- Git checkout of this repository

## Validation

```bash
scripts/check-sdd-docs.sh sample-feature
scripts/run-tests.sh
```

Expected result:

```text
[SDD_GATE_PASSED] All required SDD documents exist and are approved.
```

`scripts/run-tests.sh` should also finish with exit code 0.
