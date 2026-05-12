# Acceptance Criteria: Sample Feature

## Status

Human Approved

<!-- Change to `Human Approved` only after human review. -->

## Criteria

- [ ] Given a human-approved requirement, when AI plans the work, then it does not decide missing business rules.
- [ ] Given required SDD documents exist, when implementation starts, then work is limited to `tasks.md`.
- [ ] Given PR draft is created, when AI reaches the stop point, then human review controls merge and release.

## Edge Cases

- Missing SDD document
- Draft status instead of `Human Approved`
- Ambiguous domain rule

## Human Review Points

- [ ] Domain behavior is correct
- [ ] Business policy is correct
- [ ] Customer-facing behavior is acceptable
