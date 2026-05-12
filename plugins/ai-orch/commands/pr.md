---
description: 기존 SDD와 self-review 문서로 AI Orch draft PR 생성
argument-hint: <feature-name>
allowed-tools: [Bash, Read]
---

# AI Orch PR

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" pr $ARGUMENTS
```

## Instructions

1. 기존 SDD와 self-review 문서를 사용해 draft PR을 생성한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" pr $ARGUMENTS`를 실행한다.
3. draft PR URL 또는 GitHub CLI blocker를 보고한다.
4. draft PR 생성 후 멈춘다. merge하지 않는다.
