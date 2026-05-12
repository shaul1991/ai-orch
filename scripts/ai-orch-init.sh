#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_VERSION="0.3.0"

cd "$PROJECT_ROOT"

ensure_gitignore_line() {
  local line="$1"

  if [ ! -f ".gitignore" ] || ! grep -Fxq "$line" ".gitignore"; then
    printf '%s\n' "$line" >> ".gitignore"
  fi
}

ensure_gitignore() {
  touch ".gitignore"

  if ! grep -Fxq "/.ai-orch/*" ".gitignore"; then
    {
      printf '\n# AI Orch local state\n'
      printf '/.ai-orch/*\n'
      printf '!/.ai-orch/\n'
      printf '!/.ai-orch/README.md\n'
    } >> ".gitignore"
  else
    ensure_gitignore_line "!/.ai-orch/"
    ensure_gitignore_line "!/.ai-orch/README.md"
  fi
}

write_local_state_readme() {
  mkdir -p ".ai-orch"

  cat > ".ai-orch/README.md" <<EOF_README
# AI Orch Local State

\`.ai-orch/\`는 AI Orch의 local/개인별 실행 이력 cache를 저장하는 디렉터리다.

현재 plugin version: \`$PLUGIN_VERSION\`

## Git Policy

- 이 파일만 git에 추적한다.
- 실제 실행 이력은 git에 커밋하지 않는다.
- branch별 status와 run log는 개인 로컬 상태로만 유지한다.

## Generated Paths

\`\`\`text
.ai-orch/
├── README.md          # tracked
├── branches/          # ignored
│   └── {branch}.md    # branch별 flow checklist
├── state/             # ignored
│   └── {branch}.state # script가 읽는 key-value cache
└── runs/              # ignored
    └── *.md           # flow 실행 event log
\`\`\`

## Source Of Truth

- 공유 산출물: \`docs/specs/{feature}/...\`
- local 실행 상태: \`.ai-orch/branches/{branch}.md\`
- PR/merge/release 판단: human-owned

## Initialization

\`scripts/ai-orch.sh init\`은 이 파일과 \`.gitignore\`의 AI Orch local state 규칙을 보장한다.
EOF_README
}

ensure_gitignore
write_local_state_readme

echo "[AI_ORCH_INIT_DONE] ensured .ai-orch/README.md and .gitignore local state rules."
echo "[AI_ORCH_INIT_NEXT] run: scripts/ai-orch.sh status"
