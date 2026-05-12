---
description: AI Orch 현재 브랜치 flow 체크리스트와 local 실행 이력 표시
argument-hint: "[feature-name]"
allowed-tools: [Bash, Read]
---

# AI Orch Status

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" status $ARGUMENTS
```

## Instructions

1. 현재 git branch 기준 AI Orch flow 진행현황을 조회한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" status $ARGUMENTS`를 실행한다.
3. 출력된 checklist와 artifact link를 그대로 요약한다.
4. 다음 미완료 flow가 있으면 한 줄로 안내하되, 사람 승인/리뷰/merge는 사용자가 직접 수행해야 한다고 구분한다.
