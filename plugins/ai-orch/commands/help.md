---
description: AI Orch command와 flow 목록 표시
argument-hint: ""
allowed-tools: [Bash, Read]
---

# AI Orch Help

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" help
```

## Instructions

1. AI Orch에서 사용할 수 있는 command와 flow 목록을 표시한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" help`를 실행한다.
3. Best flow를 한 줄로 안내한다: `feature -> Human Approved -> plan -> ready -> implement -> review -> pr -> human review -> merge`.
4. 출력에 포함된 현재 branch flow checklist를 요약한다.
5. 실행 flow를 선택하지 않는다. 사용자가 다음 command를 선택하도록 멈춘다.
