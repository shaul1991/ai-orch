# Project Agent Rules

This repository follows Human-Governed Spec-Driven Development.

## Primary Language

The primary working language for this repository is Korean.

- Write user-facing explanations, planning notes, review notes, and repository documentation in Korean by default.
- Keep code identifiers, commands, file paths, API names, and quoted source text in their original language.
- Use another language only when the user explicitly asks for it or the upstream project convention requires it.

## Core Principle

Human owns domain and business decisions.  
AI owns technical planning, implementation, testing, self-review, and PR draft only.

## Default Agent Routing

Default routing for this project:

- Codex handles documents, research, summaries, governance notes, and non-code analysis.
- Claude Code handles coding, architecture design, implementation planning, refactoring, tests, and code review.
- The user may override this routing per task.

Use the wrapper scripts in `scripts/` when possible because they expose provider/model overrides through environment variables.

Default override variables:

- `AI_DOC_PROVIDER`, `AI_DOC_MODEL`
- `AI_ARCH_PROVIDER`, `AI_ARCH_MODEL`
- `AI_CODE_PROVIDER`, `AI_CODE_MODEL`
- `AI_REVIEW_PROVIDER`, `AI_REVIEW_MODEL`

## Required Reading Order

Before any implementation, read:

1. `docs/ai-governance.md`
2. `docs/project-settings.md`
3. `docs/specs/{feature}/requirements.md`
4. `docs/specs/{feature}/acceptance-criteria.md`
5. Existing code related to the requested change

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
