# Analysis: Sample Feature

## Cross-Artifact Consistency

| Check | Result | Notes |
|---|---|---|
| `spec.md` aligns with `requirements.md` | Pass | FR-001 through FR-004 are represented. |
| `acceptance-criteria.md` aligns with `test-plan.md` | Pass | Gate and run-test validation are included. |
| `tasks.md` contains task IDs and file paths | Pass | T001 through T006 include paths or commands. |
| `traceability.md` links requirements, tasks, and tests | Pass | All functional requirements are mapped. |
| Constitution stop points are preserved | Pass | No business/domain decision is delegated to AI. |

## Risks

- Real projects must replace sample content with feature-specific requirements and acceptance criteria.
- `scripts/run-tests.sh` should be customized when application code is added.
