# Human-Governed SDD Workflow

## Overview

This repository uses goose as the main orchestration layer and oh-my-openagent as the specialist implementation/review layer.

The workflow is compatible with GitHub Spec Kit concepts while preserving Human-Governed SDD as the higher authority.

The default working language is Korean.

Default AI routing:

- Codex: documents, research, summaries, and non-code analysis
- Claude Code: architecture design, implementation planning, coding, refactoring, tests, and code self-review

These defaults are configurable per task through the wrapper scripts in `scripts/`.

## Responsibility Split

### Human

- Defines business requirements
- Defines domain rules
- Approves scope
- Reviews PR
- Decides merge
- Decides release

### AI

- Analyzes code
- Creates technical plan
- Creates task breakdown
- Creates test plan
- Implements code
- Writes or updates tests
- Performs self-review
- Creates PR draft

## Workflow

1. AI may draft `spec.md`, `requirements.md`, `acceptance-criteria.md`, and `clarifications.md` through `scripts/sdd-specify.sh`.
2. Human reviews requirements and acceptance criteria.
3. Human marks `requirements.md` and `acceptance-criteria.md` as `Human Approved`.
4. AI runs clarification analysis through `scripts/sdd-clarify.sh` when ambiguity remains.
5. goose runs `sdd-plan.yaml` through `scripts/sdd-plan.sh`.
6. Claude Code creates or updates `technical-plan.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, `tasks.md`, `test-plan.md`, and `traceability.md`.
7. Human reviews the plan and scope.
8. AI runs cross-artifact readiness analysis through `scripts/sdd-analyze.sh`.
9. `scripts/check-sdd-docs.sh <feature>` must pass.
10. goose runs `sdd-implement.yaml` through `scripts/sdd-implement.sh`.
11. Claude Code implements only approved tasks.
12. Claude Code runs tests.
13. goose runs `sdd-review-pr.yaml` through `scripts/sdd-review-pr.sh`.
14. Claude Code writes `self-review.md`.
15. AI creates PR draft.
16. AI stops.
17. Human reviews and decides merge.

## Provider Overrides

Defaults:

```json
{
  "AI_DOC_PROVIDER": "codex-acp",
  "AI_DOC_MODEL": "gpt-5.5",
  "AI_ARCH_PROVIDER": "claude-code",
  "AI_ARCH_MODEL": "default",
  "AI_CODE_PROVIDER": "claude-code",
  "AI_CODE_MODEL": "default",
  "AI_REVIEW_PROVIDER": "claude-code",
  "AI_REVIEW_MODEL": "default"
}
```

Override per command:

```bash
AI_CODE_PROVIDER=codex-acp AI_CODE_MODEL=gpt-5.5 scripts/sdd-implement.sh sample-feature
AI_DOC_PROVIDER=claude-code AI_DOC_MODEL=default scripts/sdd-docs.sh "topic" docs/output.md
```

## AI Stop Point

The AI must stop after PR draft creation.  
Merge and release are always human decisions.
