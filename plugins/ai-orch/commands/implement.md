---
description: 승인되고 준비된 feature의 AI Orch 구현 flow 실행
argument-hint: <feature-name>
allowed-tools: [Bash, Read, Edit, Glob, Grep]
---

# AI Orch Implement

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
scripts/ai-orch.sh implement $ARGUMENTS
```

## Instructions

1. SDD gate, 구현 flow, 테스트를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh implement $ARGUMENTS`를 실행한다.
3. `docs/specs/{feature}/tasks.md`에서 승인된 task만 구현한다.
4. business/domain/security 모호성이 있으면 `[HUMAN_DECISION_REQUIRED]`로 멈춘다.
5. 변경 파일, 테스트, 남은 risk를 보고한다.
