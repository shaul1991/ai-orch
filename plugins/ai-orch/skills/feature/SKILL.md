---
name: feature
description: AI Orch feature specification flow를 시작한다. 사용자가 새 feature SDD 초안, `/ai-orch:feature`, feature 요구사항 문서 생성을 요청할 때 사용한다.
---

# AI Orch Feature

`"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" feature <feature-name> [feature-description]`로 위임한다.

## Instructions

1. feature SDD 문서 초안만 작성한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" feature <feature-name> [feature-description]`를 실행한다.
3. specify flow 완료 후 멈춘다.
4. `requirements.md`와 `acceptance-criteria.md`에 `Human Approved`를 표시하지 않는다. 승인은 human 권한이다.
