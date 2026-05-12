# Self Review: Sample Feature

## Requirement Coverage

| Requirement | Implemented | Evidence |
|---|---:|---|
| FR-001: Verify required feature documents | Yes | `scripts/check-sdd-docs.sh sample-feature` |
| FR-002: Require `Human Approved` | Yes | `requirements.md`, `acceptance-criteria.md`, gate script |
| FR-003: Reject unresolved clarification markers | Yes | Gate script scans feature Markdown files |
| FR-004: Preserve human decision boundary | Yes | `.specify/memory/constitution.md`, `AGENTS.md`, `docs/ai-governance.md` |

## Acceptance Criteria Coverage

| Criteria | Status | Evidence |
|---|---:|---|
| AC-001: AI does not decide business rules | Passed | Governance docs and recipes |
| AC-002: Work is limited to `tasks.md` | Passed | Implementation recipe and tasks |
| AC-003: PR draft is AI stop point | Passed | Review recipe and PR helper |
| AC-004: Spec Kit-compatible artifacts exist | Passed | `docs/specs/sample-feature/` |

## Traceability Coverage

| Requirement | Task | Verification |
|---|---|---|
| FR-001 | T001, T005 | `scripts/check-sdd-docs.sh sample-feature` |
| FR-002 | T002, T005 | `scripts/check-sdd-docs.sh sample-feature` |
| FR-003 | T003, T005 | `scripts/check-sdd-docs.sh sample-feature` |
| FR-004 | T004, T006 | `scripts/run-tests.sh` |

## Changed Files

- Template files only.

## Test Results

- `scripts/check-sdd-docs.sh sample-feature`: Passed
- `scripts/run-tests.sh`: Passed

## Security Review

No security-sensitive application behavior changed.

## Performance Review

No runtime behavior changed.

## Regression Risk

Low for this template-only setup.

## Human Review Checklist

- [ ] Domain behavior
- [ ] Business policy
- [ ] UX/API contract
- [ ] Edge cases
- [ ] Merge decision
