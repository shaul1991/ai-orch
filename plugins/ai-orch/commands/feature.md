---
description: AI Orch feature specification flow 시작
argument-hint: <feature-name> [feature-description]
allowed-tools: [Bash, Read]
---

# AI Orch Feature

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" feature $ARGUMENTS
```

## Instructions

1. feature SDD 문서 초안만 작성한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" feature $ARGUMENTS`를 실행한다.
3. specify flow 완료 후 멈춘다.
4. `requirements.md`와 `acceptance-criteria.md`에 `Human Approved`를 표시하지 않는다. 승인은 human 권한이다.
