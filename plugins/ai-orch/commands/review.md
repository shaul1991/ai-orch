---
description: AI Orch test, self-review, PR 준비 flow 실행
argument-hint: <feature-name>
allowed-tools: [Bash, Read, Glob, Grep]
---

# AI Orch Review

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
scripts/ai-orch.sh review $ARGUMENTS
```

## Instructions

1. 테스트와 self-review/PR 준비 flow를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh review $ARGUMENTS`를 실행한다.
3. 테스트 결과와 `self-review.md` 상태를 보고한다.
4. PR draft 준비 후 멈춘다. review, merge, release는 human 권한이다.
