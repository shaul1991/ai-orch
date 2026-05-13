---
description: AI Orch 외부 CLI tool (jq, gh, goose, codex, claude) 설치 점검과 install 가이드 출력
argument-hint: ""
allowed-tools: [Bash, Read]
---

# AI Orch Preflight

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" preflight
```

## Instructions

1. AI Orch flow가 의존하는 외부 CLI tool (jq, gh, goose, codex, claude) 설치 여부를 점검한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" preflight`를 실행한다.
3. 출력의 MISSING 항목별로 install 명령(macOS 기준 `brew install ...` 또는 docs URL) 을 사용자에게 그대로 노출한다. **자동 설치는 하지 않는다** — 사용자가 직접 복사해서 실행해야 한다.
4. `required` 레벨 tool 이 빠지면 install 후 다시 `/ai-orch:preflight` 또는 `/ai-orch:doctor` 를 실행하도록 안내한다.
5. 모두 OK 면 다음 단계로 `/ai-orch:status` (또는 SDD flow 시작이면 `/ai-orch:feature`) 를 제안한다.
