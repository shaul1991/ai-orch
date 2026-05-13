# Acceptance Criteria: Sample Feature

## Status

Human Approved

<!-- Change to `Human Approved` only after human review. -->

## Criteria

- [x] AC-001: Given a human-approved requirement, when AI plans the work, then it does not decide missing business rules.
- [x] AC-002: Given required SDD documents exist, when implementation starts, then work is limited to `tasks.md`.
- [x] AC-003: Given PR draft is created, when AI reaches the stop point, then human review controls merge and release.
- [x] AC-004: Given `spec-kit` compatibility is enabled, when the SDD gate runs, then `spec.md`, `clarifications.md`, `plan.md`, `traceability.md`, `analysis.md`, and `checklist.md` are present.

## Edge Cases

- Missing SDD document
- Draft status instead of `Human Approved`
- Ambiguous domain rule
- Unresolved clarification marker
- Task without a task ID or target path

## Human Review Points

- [x] Domain behavior is correct
- [x] Business policy is correct
- [x] Customer-facing behavior is acceptable
