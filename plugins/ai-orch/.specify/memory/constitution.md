# Project Constitution

Version: 1.0.0
Updated: 2026-05-12

## Core Principles

### I. Human-Governed Domain Authority

Human reviewers own domain rules, business policy, product priority, scope approval, PR review, merge, and release decisions. AI agents may draft, analyze, implement approved work, test, self-review, and prepare draft PRs, but must not decide missing business behavior.

### II. Korean-First Repository Communication

Repository documentation, planning notes, review notes, and user-facing explanations are written in Korean by default. Code identifiers, commands, file paths, API names, and quoted upstream text keep their original language.

### III. Spec-First Implementation Gate

Source code changes require an approved feature specification under `docs/specs/{feature}/`. The implementation gate requires both the existing Human-Governed SDD documents and the Spec Kit-compatible documents:

- `spec.md`
- `requirements.md`
- `acceptance-criteria.md`
- `clarifications.md`
- `technical-plan.md`
- `plan.md`
- `research.md`
- `data-model.md`
- `contracts/`
- `quickstart.md`
- `tasks.md`
- `test-plan.md`
- `traceability.md`
- `analysis.md`
- `checklist.md`

`requirements.md` and `acceptance-criteria.md` must contain `Human Approved` before implementation starts.

### IV. Traceable Work Units

Every implementation task must use a stable task ID such as `T001`, include the relevant user story or requirement when applicable, and name exact file paths. Requirements, tasks, and tests must be connected through `traceability.md`.

### V. Stop on Ambiguity

AI agents must stop and emit `[HUMAN_DECISION_REQUIRED]` when business rules, domain behavior, security policy, authorization, payment, pricing, user permission, or customer-facing policy is ambiguous or conflicts with existing behavior.

### VI. Draft PR Stop Point

AI may create or prepare a draft PR only. After draft PR creation, control returns to the human reviewer. AI must not merge, deploy, force push, or perform destructive database actions.

## Governance

- This constitution is the durable project-level SDD policy.
- `docs/ai-governance.md`, `AGENTS.md`, and `.goose/recipes/*.yaml` must remain consistent with this constitution.
- Spec Kit upstream templates may be adopted, but this constitution takes precedence where upstream defaults conflict with Human-Governed SDD.
- Changes to this constitution require explicit human approval.
