---
name: review
description: AI Orch test, self-review, PR 준비 flow를 실행한다. 사용자가 `/ai-orch:review`, SDD self-review, PR 준비를 요청할 때 사용한다.
---

# AI Orch Review

`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" review <feature-name>`로 위임한다.

## Instructions

1. 테스트와 self-review/PR 준비 flow를 실행한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" review <feature-name>`를 실행한다.
3. 테스트 결과와 `self-review.md` 상태를 보고한다.
4. PR draft 준비 후 멈춘다. review, merge, release는 human 권한이다.
