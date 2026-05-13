---
name: preflight
description: AI Orch 외부 CLI tool (jq, gh, goose, codex, claude) 설치 점검과 install 가이드를 출력한다. 사용자가 `/ai-orch:preflight`, ai-orch preflight, "goose/codex/gh 설치 안내", "어떤 도구가 설치돼야 하는지 확인" 등을 요청할 때 사용한다.
---

# AI Orch Preflight

`"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" preflight`로 위임한다.

## Instructions

1. AI Orch flow가 의존하는 외부 CLI tool (jq, gh, goose, codex, claude) 설치 여부를 점검한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" preflight`를 실행한다.
3. 출력의 MISSING 항목별로 install 명령(macOS 기준 `brew install ...` 또는 docs URL) 을 사용자에게 그대로 노출한다. **자동 설치는 하지 않는다** — 사용자가 직접 복사해서 실행해야 한다.
4. `required` 레벨 tool 이 빠지면 install 후 다시 `/ai-orch:preflight` 또는 `/ai-orch:doctor` 를 실행하도록 안내한다.
5. 모두 OK 면 다음 단계로 `/ai-orch:status` (또는 SDD flow 시작이면 `/ai-orch:feature`) 를 제안한다.
