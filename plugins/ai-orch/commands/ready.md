---
description: AI Orch readiness analysis와 SDD gate 실행
argument-hint: <feature-name>
allowed-tools: [Bash, Read]
---

# AI Orch Ready

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
scripts/ai-orch.sh ready $ARGUMENTS
```

## Instructions

1. readiness analysis와 implementation gate를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh ready $ARGUMENTS`를 실행한다.
3. SDD gate 통과 여부를 보고한다.
4. gate가 실패하면 구현으로 진행하지 않는다.
