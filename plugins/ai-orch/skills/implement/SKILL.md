---
name: implement
description: 승인되고 준비된 feature의 AI Orch 구현 flow를 실행한다. 사용자가 `/ai-orch:implement`, SDD 구현, 승인된 tasks 구현을 요청할 때 사용한다.
---

# AI Orch Implement

`scripts/ai-orch.sh implement <feature-name>`로 위임한다.

## Instructions

1. SDD gate, 구현 flow, 테스트를 실행한다고 간단히 설명한다.
2. repository root에서 `scripts/ai-orch.sh implement <feature-name>`를 실행한다.
3. `docs/specs/{feature}/tasks.md`에서 승인된 task만 구현한다.
4. business/domain/security 모호성이 있으면 `[HUMAN_DECISION_REQUIRED]`로 멈춘다.
5. 변경 파일, 테스트, 남은 risk를 보고한다.
