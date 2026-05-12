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

- `.specify/memory/constitution.md`
- `docs/specs/{feature}/spec.md`
- `docs/specs/{feature}/requirements.md`
- `docs/specs/{feature}/acceptance-criteria.md`
- `docs/specs/{feature}/clarifications.md`
- `docs/specs/{feature}/technical-plan.md`
- `docs/specs/{feature}/plan.md`
- `docs/specs/{feature}/research.md`
- `docs/specs/{feature}/data-model.md`
- `docs/specs/{feature}/contracts/`
- `docs/specs/{feature}/quickstart.md`
- `docs/specs/{feature}/tasks.md`
- `docs/specs/{feature}/test-plan.md`
- `docs/specs/{feature}/traceability.md`
- `docs/specs/{feature}/analysis.md`
- `docs/specs/{feature}/checklist.md`

## Required Behavior

1. Read approved requirements.
2. Check for business ambiguity.
3. If ambiguity exists, stop.
4. Verify `scripts/check-sdd-docs.sh {feature}` passes.
5. Implement only approved tasks.
6. Write or update tests.
7. Run tests.
8. Create `self-review.md`.
9. Prepare PR draft.
10. Stop.

## Forbidden

Never:

- Decide business rules
- Change domain policy
- Merge PRs
- Deploy
- Force push
- Modify auth/payment/pricing policy without explicit approval
