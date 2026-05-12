---
description: AI Orch 문서/리서치 flow 실행
argument-hint: <topic> <output-markdown-path>
allowed-tools: [Bash, Read]
---

# AI Orch Docs

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
scripts/ai-orch.sh docs $ARGUMENTS
```

## Instructions

1. 문서/리서치 flow를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh docs $ARGUMENTS`를 실행한다.
3. 출력 문서 경로와 blocker를 보고한다.
4. 위임된 flow가 명시하지 않는 한 source code는 수정하지 않는다.
