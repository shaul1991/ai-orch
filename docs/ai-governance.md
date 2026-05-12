# AI Governance Rules

## 1. Authority Boundary

Human is responsible for:

- Domain model decisions
- Business policy decisions
- Product priority
- Scope approval
- PR review
- Merge approval
- Release approval

AI is responsible for:

- Codebase analysis
- Technical planning
- Architecture proposal
- Code implementation
- Test implementation
- Refactoring within approved scope
- Self-review
- PR draft creation

## 2. Hard Rules

AI must not:

- Decide business policy
- Change domain rules without approved spec
- Add features outside approved scope
- Merge pull requests
- Deploy to production
- Resolve human review comments without confirmation
- Modify authentication, authorization, payment, pricing, or customer-impacting policy without explicit approval

AI must:

- Read approved requirements before implementation
- Produce a technical plan before editing code
- Produce a test plan before implementation
- Run tests after implementation
- Produce self-review before PR
- Stop after PR draft and return control to human

## 3. Escalation Rule

When business or domain ambiguity is found, AI must stop and write:

```text
[HUMAN_DECISION_REQUIRED]

- Question:
- Context:
- Options:
- Recommended technical impact:
- Files affected:
```
