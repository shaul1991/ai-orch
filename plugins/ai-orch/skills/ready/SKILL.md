---
name: ready
description: AI Orch readiness analysis와 SDD gate를 실행한다. 사용자가 `/ai-orch:ready`, 구현 전 readiness, SDD gate 확인을 요청할 때 사용한다.
---

# AI Orch Ready

`"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" ready <feature-name>`로 위임한다.

## Instructions

1. readiness analysis와 implementation gate를 실행한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" ready <feature-name>`를 실행한다.
3. SDD gate 통과 여부를 보고한다.
4. gate가 실패하면 구현으로 진행하지 않는다.
