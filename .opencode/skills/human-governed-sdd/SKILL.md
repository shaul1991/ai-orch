# Human-Governed SDD Skill

## Purpose

Use this skill when working on any feature implementation in this repository.

## Authority Boundary

Human owns:

- Domain decisions
- Business policy
- Product scope
- PR review
- Merge
- Deployment

AI owns:

- Technical analysis
- Technical planning
- Code implementation
- Tests
- Self-review
- PR draft

## Required Inputs

Before implementation, confirm these files exist:

- `docs/specs/{feature}/requirements.md`
- `docs/specs/{feature}/acceptance-criteria.md`
- `docs/specs/{feature}/technical-plan.md`
- `docs/specs/{feature}/tasks.md`
- `docs/specs/{feature}/test-plan.md`

## Required Behavior

1. Read approved requirements.
2. Check for business ambiguity.
3. If ambiguity exists, stop.
4. Implement only approved tasks.
5. Write or update tests.
6. Run tests.
7. Create `self-review.md`.
8. Prepare PR draft.
9. Stop.

## Forbidden

Never:

- Decide business rules
- Change domain policy
- Merge PRs
- Deploy
- Force push
- Modify auth/payment/pricing policy without explicit approval
