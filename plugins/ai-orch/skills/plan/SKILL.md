---
name: plan
description: 승인된 feature의 AI Orch planning flow를 실행한다. 사용자가 `/ai-orch:plan`, SDD 기술 계획, tasks/test plan 생성을 요청할 때 사용한다.
---

# AI Orch Plan

`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" plan <feature-name>`로 위임한다.

## Instructions

1. 기술 planning flow를 실행한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" plan <feature-name>`를 실행한다.
3. 생성 또는 갱신된 planning 산출물을 보고한다.
4. human의 plan/scope review를 위해 멈춘다.
