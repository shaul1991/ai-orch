---
description: 승인된 feature의 AI Orch planning flow 실행
argument-hint: <feature-name>
allowed-tools: [Bash, Read]
---

# AI Orch Plan

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
scripts/ai-orch.sh plan $ARGUMENTS
```

## Instructions

1. 기술 planning flow를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh plan $ARGUMENTS`를 실행한다.
3. 생성 또는 갱신된 planning 산출물을 보고한다.
4. human의 plan/scope review를 위해 멈춘다.
