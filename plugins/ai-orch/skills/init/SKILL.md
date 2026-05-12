---
name: init
description: AI Orch 최초 필수 초기화를 수행한다. local 상태, settings, 보호 정책, CLAUDE.md symlink를 준비한다. 사용자가 `/ai-orch:init`, ai-orch init, plugin 설치 후 초기화를 요청할 때 사용한다.
---

# AI Orch Init

`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" init`으로 위임한다.

## Instructions

1. AI Orch 사용 전 최초 필수 초기화를 실행한다고 간단히 설명한다.
2. `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/ai-orch.sh" init`을 실행한다.
3. `.ai-orch/init.json` local marker, settings, 보호 정책, `.gitignore`, `AGENTS.md` template, `CLAUDE.md -> AGENTS.md` symlink가 준비되었는지 요약한다.
4. 다음 단계로 `/ai-orch:status`를 안내한다.
