---
name: docs
description: AI Orch 문서/리서치 flow를 실행한다. 사용자가 ai-orch docs, SDD 문서화, research 문서 작성, `/ai-orch:docs`를 요청할 때 사용한다.
---

# AI Orch Docs

`"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" docs <topic> <output-markdown-path>`로 위임한다.

## Instructions

1. 문서/리서치 flow를 실행한다고 간단히 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" docs <topic> <output-markdown-path>`를 실행한다.
3. 출력 문서 경로와 blocker를 보고한다.
4. 위임된 flow가 명시하지 않는 한 source code는 수정하지 않는다.
