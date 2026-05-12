# Project Agent Rules

This repository follows Human-Governed Spec-Driven Development.

## Core Principle

Human owns domain and business decisions.  
AI owns technical planning, implementation, testing, self-review, and PR draft only.

## Required Reading Order

Before any implementation, read:

1. `docs/ai-governance.md`
2. `docs/specs/{feature}/requirements.md`
3. `docs/specs/{feature}/acceptance-criteria.md`
4. Existing code related to the requested change

## Implementation Gate

Do not modify source code unless all of these exist:

- `requirements.md`
- `acceptance-criteria.md`
- `technical-plan.md`
- `tasks.md`
- `test-plan.md`

## Stop Conditions

Stop immediately when:

- Business rule is missing
- Domain behavior is ambiguous
- Requirement conflicts with existing behavior
- Security or authorization policy is unclear
- Payment, pricing, user permission, or customer-facing policy is affected
- PR draft is created

## Forbidden Actions

Never run:

- `git merge`
- `gh pr merge`
- `git push --force`
- production deploy commands
- destructive database commands
- migration rollback commands without explicit human approval
