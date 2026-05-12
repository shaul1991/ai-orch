---
name: pr
description: 기존 SDD와 self-review 문서로 AI Orch draft PR을 생성한다. 사용자가 `/ai-orch:pr`, draft PR 생성, SDD PR 생성을 요청할 때 사용한다.
---

# AI Orch PR

`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" pr <feature-name>`로 위임한다.

## Instructions

1. 기존 SDD와 self-review 문서를 사용해 draft PR을 생성한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" pr <feature-name>`를 실행한다.
3. draft PR URL 또는 GitHub CLI blocker를 보고한다.
4. draft PR 생성 후 멈춘다. merge하지 않는다.
