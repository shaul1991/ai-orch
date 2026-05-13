#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TARGET_REPO="$(pwd -P)"
PLUGIN_VERSION="0.4.5"

cd "$TARGET_REPO"

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
      printf '!/.ai-orch/setting.json\n'
      printf '!/.ai-orch/settings.example.json\n'
    } >> ".gitignore"
  else
    ensure_gitignore_line "!/.ai-orch/"
    ensure_gitignore_line "!/.ai-orch/README.md"
    ensure_gitignore_line "!/.ai-orch/setting.json"
    ensure_gitignore_line "!/.ai-orch/settings.example.json"
  fi
}

write_local_state_readme() {
  mkdir -p ".ai-orch"

  cat > ".ai-orch/README.md" <<'EOF_README'
# AI Orch Local State

`.ai-orch/`는 AI Orch의 local/개인별 실행 이력 cache 및 plugin이 target repo에 bootstrap한 참조 artifact를 모두 격리해 두는 디렉터리다.

현재 plugin version은 `.ai-orch/init.json`의 `pluginVersion` 또는 `scripts/ai-orch.sh version`으로 확인한다.

## Git 정책

- `README.md`, `setting.json`, `settings.example.json`만 git에 추적한다.
- 다른 모든 `.ai-orch/` 하위 항목 (recipes, constitution, governance docs, sample-feature 템플릿, shared protection policy, init.json, branch state, run log 등) 은 git에 commit 하지 않는다. plugin 버전이 올라가도 target repo의 git history는 영향을 받지 않는다.
- branch별 status와 run log는 개인 로컬 상태로만 유지한다.

## 생성 경로

```text
.ai-orch/
├── README.md                          # tracked
├── setting.json                       # tracked, AI Orch 공유 설정
├── settings.example.json              # tracked, 설정 key/default 안내
├── init.json                          # ignored, init marker + pluginVersion
├── setting.local.json                 # ignored, 개인별 설정 override
├── protect.local                      # ignored, 개인별 추가 deny policy
├── protect.allow.local                # ignored, 사용자 확인 후 등록한 allow policy
├── protect.shared                     # ignored, plugin이 bootstrap한 공유 보호 정책
├── goose/recipes/                     # ignored, plugin이 bootstrap한 SDD recipe
├── specify/memory/constitution.md     # ignored, plugin이 bootstrap한 SDD constitution
├── docs/ai-governance.md              # ignored, plugin이 bootstrap한 governance reference
├── docs/project-settings.md           # ignored, plugin이 bootstrap한 project settings reference
├── templates/sample-feature/          # ignored, plugin이 bootstrap한 SDD template
├── branches/{branch}.md               # ignored, branch별 flow checklist
├── state/{branch}.state               # ignored, script가 읽는 key-value cache
└── runs/*.md                          # ignored, flow 실행 event log
```

## 기준 정보

- 공유 산출물: `docs/specs/{feature}/...` (target repo 실제 작업 경로)
- local 실행 상태: `.ai-orch/branches/{branch}.md`
- PR/merge/release 판단: human-owned

## 초기화

`scripts/ai-orch.sh init`은 이 파일과 `.gitignore`의 AI Orch local state 규칙을 보장한다.

## 보호 정책

- 공유 보호 정책: `.ai-orch/protect.shared`
- 개인별 추가 차단: `.ai-orch/protect.local`
- 사용자 확인 후 local 허용: `.ai-orch/protect.allow.local`
- 접근 확인: `scripts/ai-orch.sh protect check-read <path>`
EOF_README
}

write_settings_templates() {
  mkdir -p ".ai-orch"

  if [ ! -f ".ai-orch/setting.json" ]; then
    cat > ".ai-orch/setting.json" <<'EOF_SETTING'
{
  "AI_DOC_PROVIDER": "codex-acp",
  "AI_DOC_MODEL": "gpt-5.5",
  "AI_ARCH_PROVIDER": "claude-code",
  "AI_ARCH_MODEL": "default",
  "AI_CODE_PROVIDER": "claude-code",
  "AI_CODE_MODEL": "default",
  "AI_REVIEW_PROVIDER": "claude-code",
  "AI_REVIEW_MODEL": "default",
  "AI_LOCAL_TESTS": "run",
  "AI_GITHUB_BASE_BRANCH": "main",
  "AI_GITHUB_ISSUE_LIMIT": "20",
  "AI_GITHUB_PR_LIMIT": "20"
}
EOF_SETTING
  fi

  if [ ! -f ".ai-orch/settings.example.json" ]; then
    cat > ".ai-orch/settings.example.json" <<'EOF_EXAMPLE'
{
  "_comment": "개인별 override가 필요하면 이 예시의 값을 .ai-orch/setting.local.json에 복사한다. AI Orch는 AI_로 시작하는 key만 export한다. access token이나 secret은 넣지 않는다.",
  "AI_DOC_PROVIDER": "codex-acp",
  "_AI_DOC_PROVIDER": "문서, 리서치, 요약 provider. 기본값: codex-acp.",
  "AI_DOC_MODEL": "gpt-5.5",
  "_AI_DOC_MODEL": "문서, 리서치, 요약 model. 기본값: gpt-5.5.",
  "AI_ARCH_PROVIDER": "claude-code",
  "_AI_ARCH_PROVIDER": "아키텍처와 구현 계획 provider. 기본값: claude-code.",
  "AI_ARCH_MODEL": "default",
  "_AI_ARCH_MODEL": "아키텍처와 구현 계획 model. 기본값: default.",
  "AI_CODE_PROVIDER": "claude-code",
  "_AI_CODE_PROVIDER": "코딩, 리팩터링, 테스트 구현 provider. 기본값: claude-code.",
  "AI_CODE_MODEL": "default",
  "_AI_CODE_MODEL": "코딩, 리팩터링, 테스트 구현 model. 기본값: default.",
  "AI_REVIEW_PROVIDER": "claude-code",
  "_AI_REVIEW_PROVIDER": "self-review와 PR draft provider. 기본값: claude-code.",
  "AI_REVIEW_MODEL": "default",
  "_AI_REVIEW_MODEL": "self-review와 PR draft model. 기본값: default.",
  "AI_LOCAL_TESTS": "run",
  "_AI_LOCAL_TESTS": "local ai-orch flow에서 scripts/run-tests.sh 실행 여부. run 또는 skip. 기본값: run. GitHub Actions에는 적용하지 않는다.",
  "AI_GITHUB_ACCOUNT": "",
  "_AI_GITHUB_ACCOUNT": "여러 GitHub 계정을 쓰는 환경에서 active account를 확인하기 위한 선택값. 기본값: 미설정.",
  "AI_GITHUB_REPO": "",
  "_AI_GITHUB_REPO": "origin remote가 없거나 GitHub helper 대상 repo를 고정할 때 쓰는 선택값. 기본값: git origin remote 사용.",
  "AI_GITHUB_BASE_BRANCH": "main",
  "_AI_GITHUB_BASE_BRANCH": "draft PR base branch. 기본값: main.",
  "AI_GITHUB_ISSUE_LIMIT": "20",
  "_AI_GITHUB_ISSUE_LIMIT": "issue 목록 조회 기본 limit. 기본값: 20.",
  "AI_GITHUB_PR_LIMIT": "20",
  "_AI_GITHUB_PR_LIMIT": "PR 목록 조회 기본 limit. 기본값: 20."
}
EOF_EXAMPLE
  fi

  if [ ! -f ".ai-orch/setting.local.json" ]; then
    printf '{\n}\n' > ".ai-orch/setting.local.json"
  fi
}

ensure_agents_md() {
  if [ -f "AGENTS.md" ] && [ -s "AGENTS.md" ]; then
    return 0
  fi

  local source_root source_file
  source_root="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd -P)"

  if [ -z "$source_root" ]; then
    echo "[AI_ORCH_INIT_WARN] Could not resolve source root to locate AGENTS.md template."
    return 0
  fi

  source_file="$source_root/AGENTS.md"

  if [ ! -f "$source_file" ]; then
    echo "[AI_ORCH_INIT_WARN] AGENTS.md template not found at $source_file."
    return 0
  fi

  if [ "$source_file" = "$TARGET_REPO/AGENTS.md" ]; then
    return 0
  fi

  cp "$source_file" "AGENTS.md"
  echo "[AI_ORCH_INIT_WROTE_AGENTS] copied AGENTS.md template from $source_file"
}

bootstrap_template() {
  local rel_src="$1"
  local rel_dst="$2"
  local label="$3"
  local source_file="$PROJECT_ROOT/$rel_src"
  local target_file="$TARGET_REPO/$rel_dst"

  if [ ! -f "$source_file" ]; then
    echo "[AI_ORCH_INIT_WARN] template not found at $source_file; skipped $rel_dst."
    return 0
  fi

  if [ "$source_file" = "$target_file" ]; then
    return 0
  fi

  if [ -e "$target_file" ]; then
    echo "[AI_ORCH_INIT_WARN] $rel_dst exists in target; canonical version is in plugin source at $rel_src."
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"
  cp "$source_file" "$target_file"
  echo "[AI_ORCH_INIT_WROTE_${label}] $rel_dst"
}

ensure_goose_recipes() {
  local recipe
  for recipe in \
    sdd-specify.yaml \
    sdd-clarify.yaml \
    sdd-plan.yaml \
    sdd-analyze.yaml \
    sdd-implement.yaml \
    sdd-review-pr.yaml \
    sdd-research-docs.yaml; do
    bootstrap_template ".goose/recipes/$recipe" ".ai-orch/goose/recipes/$recipe" "RECIPE"
  done
}

ensure_specify_memory() {
  bootstrap_template ".specify/memory/constitution.md" ".ai-orch/specify/memory/constitution.md" "CONSTITUTION"
}

ensure_governance_docs() {
  bootstrap_template "docs/ai-governance.md" ".ai-orch/docs/ai-governance.md" "AI_GOVERNANCE"
  bootstrap_template "docs/project-settings.md" ".ai-orch/docs/project-settings.md" "PROJECT_SETTINGS"
}

ensure_shared_protect() {
  bootstrap_template "ai-orch.protect" ".ai-orch/protect.shared" "PROTECT_SHARED"
}

ensure_sample_feature() {
  local source_dir="$PROJECT_ROOT/docs/specs/sample-feature"
  local target_dir="$TARGET_REPO/.ai-orch/templates/sample-feature"

  if [ ! -d "$source_dir" ]; then
    echo "[AI_ORCH_INIT_WARN] sample-feature template directory not found at $source_dir."
    return 0
  fi

  if [ "$source_dir" = "$target_dir" ]; then
    return 0
  fi

  if [ -e "$target_dir" ]; then
    echo "[AI_ORCH_INIT_WARN] .ai-orch/templates/sample-feature/ exists in target; canonical version is in plugin source at docs/specs/sample-feature/."
    return 0
  fi

  mkdir -p "$(dirname "$target_dir")"
  cp -R "$source_dir" "$target_dir"
  echo "[AI_ORCH_INIT_WROTE_SAMPLE_FEATURE] .ai-orch/templates/sample-feature/"
}

ensure_claude_symlink() {
  if [ ! -e "AGENTS.md" ]; then
    echo "[AI_ORCH_INIT_WARN] AGENTS.md missing; skipping CLAUDE.md symlink."
    return 0
  fi

  if [ -L "CLAUDE.md" ]; then
    return 0
  fi

  if [ -e "CLAUDE.md" ]; then
    echo "[AI_ORCH_INIT_WARN] CLAUDE.md already exists and is not a symlink. Leaving it unchanged."
    return 0
  fi

  ln -s "AGENTS.md" "CLAUDE.md"
}

write_init_marker() {
  mkdir -p ".ai-orch"

  cat > ".ai-orch/init.json" <<EOF_INIT
{
  "initialized": true,
  "pluginVersion": "$PLUGIN_VERSION",
  "updatedAt": "$(date '+%Y-%m-%dT%H:%M:%S%z')",
  "settings": {
    "shared": ".ai-orch/setting.json",
    "example": ".ai-orch/settings.example.json",
    "local": ".ai-orch/setting.local.json"
  },
  "protection": {
    "shared": ".ai-orch/protect.shared",
    "localDeny": ".ai-orch/protect.local",
    "localAllow": ".ai-orch/protect.allow.local"
  },
  "agentFiles": {
    "source": "AGENTS.md",
    "claude": "CLAUDE.md"
  }
}
EOF_INIT
}

write_local_protect_template() {
  mkdir -p ".ai-orch"

  if [ ! -f ".ai-orch/protect.local" ]; then
    cat > ".ai-orch/protect.local" <<'EOF_PROTECT'
# AI Orch local 보호 정책
#
# 이 파일은 git에서 무시된다.
# 개인별 추가 deny pattern을 여기에 둔다.
#
# 문법:
#   deny <glob>
#
# 예시:
# deny private-notes/*
EOF_PROTECT
  fi
}

ensure_gitignore
write_local_state_readme
write_settings_templates
write_local_protect_template
ensure_agents_md
ensure_goose_recipes
ensure_specify_memory
ensure_governance_docs
ensure_shared_protect
ensure_sample_feature
ensure_claude_symlink
write_init_marker

echo "[AI_ORCH_INIT_DONE] ensured .ai-orch settings, protection files, and .gitignore local state rules."
echo "[AI_ORCH_INIT_NEXT] run: /ai-orch:status"
