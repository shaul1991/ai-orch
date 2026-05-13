# AI Governance Rules

## 0. Project Defaults

Primary language:

- Korean is the default language for explanations, planning notes, review notes, and repository documentation.
- Keep code, commands, file paths, API names, and proper nouns in their original form.

Default AI routing:

- Codex is responsible for documentation, research, summaries, governance notes, and non-code analysis.
- Claude Code is responsible for architecture design, implementation planning, coding, refactoring, tests, and code self-review.
- The user may override the routing per task.

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
- Read, edit, delete, summarize, or expose secret/critical files protected by `ai-orch.protect` or `.ai-orch/protect.local` without explicit local human confirmation

AI must:

- Read approved requirements before implementation
- Produce a technical plan before editing code
- Produce a test plan before implementation
- Run tests after implementation
- Produce self-review before PR
- Stop after PR draft and return control to human
- Use `scripts/ai-orch.sh protect check-read <path>` or `scripts/ai-orch.sh protect check-write <path>` before accessing a suspected secret/critical path

## 3. Protected File Access

Protected file policy:

- Shared deny/allow policy: `ai-orch.protect`
- Local user-specific deny policy: `.ai-orch/protect.local`
- Local user-confirmed allow policy: `.ai-orch/protect.allow.local`

If a protected path is required, AI must stop at the guard output and ask the human to confirm. Only after the human explicitly approves may the local allow command be run, for example:

```bash
scripts/ai-orch.sh protect allow-read .env
```

## 4. Escalation Rule

When business or domain ambiguity is found, AI must stop and write:

```text
[HUMAN_DECISION_REQUIRED]

- Question:
- Context:
- Options:
- Recommended technical impact:
- Files affected:
```
