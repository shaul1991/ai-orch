#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TARGET_REPO="$(pwd -P)"

source "$SCRIPT_DIR/load-env.sh"

cd "$TARGET_REPO"

AI_ORCH_ENV_LOADED=0

usage() {
  cat <<'EOF_USAGE'
Usage:
  scripts/ai-orch.sh <flow> [args...]

Best flow:
  feature -> Human Approved -> plan -> ready -> implement -> review -> pr -> human review -> merge

Flows:
  help
      Show this help.

  init
      Required first-time setup. Initialize .ai-orch local state, settings,
      protection policy files, and CLAUDE.md -> AGENTS.md symlink.

  protect <action> [args...]
      Check or manage protected secret/critical file access.

  doctor
      Check local script syntax and the sample SDD gate.

  preflight
      Inventory external CLI tools (jq, gh, goose, codex, claude) and print
      install hints for any missing ones. Does not auto-install.

  docs <topic> <output-markdown-path>
      Run the documentation/research flow.

  specify <feature-name> [feature-description]
      Draft spec, requirements, acceptance criteria, and clarifications.

  clarify <feature-name>
      Review feature documents for ambiguity and update clarifications.

  plan <feature-name>
      Run the planning flow and produce technical plan, tasks, tests, and traceability.

  ready <feature-name>
      Run readiness analysis and the SDD gate.

  implement <feature-name>
      Run the implementation flow after passing the SDD gate, then run tests.

  review <feature-name>
      Run tests, then run self-review and PR draft preparation recipe.

  pr <feature-name>
      Create a draft PR directly from existing SDD/self-review documents.

  feature <feature-name> [feature-description]
      Start a new feature flow: specify only. Human approval is required before plan/implement.

  release-check <feature-name>
      Run readiness gate, tests, and review flow. Does not merge or release.

  explain <flow>
      Print the execution plan for a flow without running it.

  status [feature-name]
      Show the current branch flow checklist and local artifacts.

  version
      Print the plugin version. Reads .ai-orch/init.json when available,
      otherwise falls back to the bundled PLUGIN_VERSION constant.

Examples:
  scripts/ai-orch.sh init
  scripts/ai-orch.sh protect list
  scripts/ai-orch.sh docs "운영 정책 정리" docs/output.md
  scripts/ai-orch.sh feature login "로그인 기능"
  scripts/ai-orch.sh plan login
  scripts/ai-orch.sh ready login
  scripts/ai-orch.sh implement login
  scripts/ai-orch.sh review login
  scripts/ai-orch.sh pr login
  scripts/ai-orch.sh status
EOF_USAGE
}

need_arg() {
  local value="${1:-}"
  local message="$2"

  if [ -z "$value" ]; then
    echo "[AI_ORCH_FAILED] $message"
    usage
    exit 1
  fi
}

current_branch() {
  local branch

  branch="$(git branch --show-current 2>/dev/null || true)"

  if [ -n "$branch" ]; then
    echo "$branch"
    return 0
  fi

  if branch="$(git rev-parse --short HEAD 2>/dev/null)"; then
    echo "detached-$branch"
    return 0
  fi

  echo "no-git"
}

ai_orch_initialized() {
  [ -f ".ai-orch/README.md" ] &&
    [ -f ".ai-orch/init.json" ] &&
    [ -f ".ai-orch/setting.json" ] &&
    [ -f ".ai-orch/settings.example.json" ] &&
    [ -f ".gitignore" ] &&
    grep -Fxq "/.ai-orch/*" ".gitignore" &&
    grep -Fxq "!/.ai-orch/" ".gitignore" &&
    grep -Fxq "!/.ai-orch/README.md" ".gitignore" &&
    grep -Fxq "!/.ai-orch/setting.json" ".gitignore" &&
    grep -Fxq "!/.ai-orch/settings.example.json" ".gitignore"
}

branch_slug() {
  local branch="$1"
  printf '%s' "$branch" | sed 's#[/[:space:]]#-#g; s#[^[:alnum:]._-]#-#g; s#--*#-#g; s#^-##; s#-$##'
}

state_file_for_branch() {
  local branch="$1"
  echo ".ai-orch/state/$(branch_slug "$branch").state"
}

status_file_for_branch() {
  local branch="$1"
  echo ".ai-orch/branches/$(branch_slug "$branch").md"
}

state_get() {
  local key="$1"
  local file="$2"

  [ -f "$file" ] || return 0

  awk -F= -v key="$key" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$file"
}

state_set() {
  local key="$1"
  local value="$2"
  local file="$3"
  local tmp="${file}.tmp.$$"

  mkdir -p "$(dirname "$file")"

  if [ -f "$file" ]; then
    awk -F= -v key="$key" '$1 != key' "$file" > "$tmp"
  else
    : > "$tmp"
  fi

  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$file"
}

flow_state_key() {
  case "$1" in
    feature|specify)
      echo "FEATURE"
      ;;
    clarify)
      echo "CLARIFY"
      ;;
    plan)
      echo "PLAN"
      ;;
    ready)
      echo "READY"
      ;;
    implement)
      echo "IMPLEMENT"
      ;;
    review)
      echo "REVIEW"
      ;;
    pr)
      echo "PR"
      ;;
    docs)
      echo "DOCS"
      ;;
    init)
      echo "INIT"
      ;;
    protect)
      echo "PROTECT"
      ;;
    release-check)
      echo "RELEASE_CHECK"
      ;;
    *)
      echo "$1" | tr '[:lower:]-' '[:upper:]_'
      ;;
  esac
}

human_approved() {
  local feature="$1"
  local base="docs/specs/$feature"

  [ -n "$feature" ] || return 1
  [ -f "$base/requirements.md" ] || return 1
  [ -f "$base/acceptance-criteria.md" ] || return 1

  grep -q 'Human Approved' "$base/requirements.md" &&
    grep -q 'Human Approved' "$base/acceptance-criteria.md"
}

checkbox_for_flow() {
  local flow="$1"
  local state_file="$2"
  local key status

  key="FLOW_$(flow_state_key "$flow")"
  status="$(state_get "$key" "$state_file")"

  if [ "$status" = "done" ]; then
    printf '[x]'
  else
    printf '[ ]'
  fi
}

checkbox_for_human_approve() {
  local feature="$1"

  if human_approved "$feature"; then
    printf '[x]'
  else
    printf '[ ]'
  fi
}

flow_status_value() {
  local key="$1"
  local state_file="$2"
  local status

  status="$(state_get "FLOW_$key" "$state_file")"
  echo "${status:-pending}"
}

flow_last_run_value() {
  local key="$1"
  local state_file="$2"
  local last_run

  last_run="$(state_get "FLOW_${key}_AT" "$state_file")"
  echo "${last_run:--}"
}

human_approve_artifacts() {
  local feature="$1"

  if [ -n "$feature" ]; then
    echo "\`docs/specs/$feature/requirements.md\`, \`docs/specs/$feature/acceptance-criteria.md\`"
  else
    echo "-"
  fi
}

artifact_links_for_flow() {
  local flow="$1"
  local feature="$2"
  local state_file="$3"
  local artifacts=""
  local base="docs/specs/$feature"
  local docs_output pr_url

  add_artifact() {
    local path="$1"
    if [ -e "$path" ]; then
      if [ -n "$artifacts" ]; then
        artifacts="$artifacts, "
      fi
      artifacts="${artifacts}\`$path\`"
    fi
  }

  case "$flow" in
    docs)
      docs_output="$(state_get DOCS_OUTPUT "$state_file")"
      if [ -n "$docs_output" ]; then
        add_artifact "$docs_output"
      fi
      ;;
    init)
      add_artifact ".ai-orch/README.md"
      add_artifact ".ai-orch/init.json"
      add_artifact ".ai-orch/setting.json"
      add_artifact ".ai-orch/settings.example.json"
      add_artifact "CLAUDE.md"
      add_artifact ".gitignore"
      ;;
    protect)
      add_artifact ".ai-orch/protect.shared"
      add_artifact ".ai-orch/protect.local"
      add_artifact ".ai-orch/protect.allow.local"
      ;;
    feature)
      add_artifact "$base/spec.md"
      add_artifact "$base/requirements.md"
      add_artifact "$base/acceptance-criteria.md"
      add_artifact "$base/clarifications.md"
      ;;
    clarify)
      add_artifact "$base/clarifications.md"
      ;;
    plan)
      add_artifact "$base/technical-plan.md"
      add_artifact "$base/plan.md"
      add_artifact "$base/tasks.md"
      add_artifact "$base/test-plan.md"
      add_artifact "$base/traceability.md"
      ;;
    ready)
      add_artifact "$base/analysis.md"
      add_artifact "$base/checklist.md"
      ;;
    implement)
      add_artifact "$base/tasks.md"
      add_artifact "$base/test-plan.md"
      ;;
    review)
      add_artifact "$base/self-review.md"
      ;;
    pr)
      pr_url="$(state_get PR_URL "$state_file")"
      if [ -n "$pr_url" ]; then
        artifacts="[$pr_url]($pr_url)"
      fi
      ;;
    release-check)
      add_artifact "$base/analysis.md"
      add_artifact "$base/checklist.md"
      add_artifact "$base/self-review.md"
      ;;
  esac

  if [ -n "$artifacts" ]; then
    echo "$artifacts"
  else
    echo "-"
  fi
}

render_branch_status() {
  local branch="$1"
  local feature="${2:-}"
  local state_file status_file updated
  local feature_value

  state_file="$(state_file_for_branch "$branch")"
  status_file="$(status_file_for_branch "$branch")"

  if [ -z "$feature" ]; then
    feature="$(state_get FEATURE "$state_file")"
  fi

  feature_value="${feature:-unknown}"
  updated="$(date '+%Y-%m-%d %H:%M:%S %z')"

  mkdir -p "$(dirname "$status_file")"

  cat > "$status_file" <<EOF_STATUS
# AI Orch Branch Status

Branch: \`$branch\`
Feature: \`$feature_value\`
Updated: $updated

## Best Flow

\`\`\`text
feature -> Human Approved -> plan -> ready -> implement -> review -> pr -> human review -> merge
\`\`\`

## Flow Checklist

$(checkbox_for_flow feature "$state_file") feature -> $(checkbox_for_human_approve "$feature") human approve -> $(checkbox_for_flow plan "$state_file") plan -> $(checkbox_for_flow ready "$state_file") ready -> $(checkbox_for_flow implement "$state_file") implement -> $(checkbox_for_flow review "$state_file") review -> $(checkbox_for_flow pr "$state_file") pr -> [ ] human review -> [ ] merge

## Artifacts

| Flow | Status | Last Run | Artifacts |
|---|---|---|---|
| feature | $(flow_status_value FEATURE "$state_file") | $(flow_last_run_value FEATURE "$state_file") | $(artifact_links_for_flow feature "$feature" "$state_file") |
| human approve | $(if human_approved "$feature"; then echo done; else echo pending; fi) | - | $(human_approve_artifacts "$feature") |
| plan | $(flow_status_value PLAN "$state_file") | $(flow_last_run_value PLAN "$state_file") | $(artifact_links_for_flow plan "$feature" "$state_file") |
| ready | $(flow_status_value READY "$state_file") | $(flow_last_run_value READY "$state_file") | $(artifact_links_for_flow ready "$feature" "$state_file") |
| implement | $(flow_status_value IMPLEMENT "$state_file") | $(flow_last_run_value IMPLEMENT "$state_file") | $(artifact_links_for_flow implement "$feature" "$state_file") |
| review | $(flow_status_value REVIEW "$state_file") | $(flow_last_run_value REVIEW "$state_file") | $(artifact_links_for_flow review "$feature" "$state_file") |
| pr | $(flow_status_value PR "$state_file") | $(flow_last_run_value PR "$state_file") | $(artifact_links_for_flow pr "$feature" "$state_file") |
| human review | human-owned | - | - |
| merge | human-owned | - | - |

## Auxiliary Runs

| Flow | Status | Last Run | Artifacts |
|---|---|---|---|
| init | $(flow_status_value INIT "$state_file") | $(flow_last_run_value INIT "$state_file") | $(artifact_links_for_flow init "$feature" "$state_file") |
| docs | $(flow_status_value DOCS "$state_file") | $(flow_last_run_value DOCS "$state_file") | $(artifact_links_for_flow docs "$feature" "$state_file") |
| clarify | $(flow_status_value CLARIFY "$state_file") | $(flow_last_run_value CLARIFY "$state_file") | $(artifact_links_for_flow clarify "$feature" "$state_file") |
| release-check | $(flow_status_value RELEASE_CHECK "$state_file") | $(flow_last_run_value RELEASE_CHECK "$state_file") | $(artifact_links_for_flow release-check "$feature" "$state_file") |

## Notes

- This file is local cache and is ignored by git.
- Shared source of truth remains in \`docs/specs/{feature}/...\`.
- Human review and merge are never auto-completed by AI Orch.
EOF_STATUS

  echo "$status_file"
}

print_status_summary() {
  local branch feature state_file status_file

  if ! ai_orch_initialized; then
  echo "Current branch flow:"
    echo "  [AI_ORCH_NOT_INITIALIZED] first required command: /ai-orch:init"
    return 0
  fi

  branch="$(current_branch)"
  state_file="$(state_file_for_branch "$branch")"
  feature="$(state_get FEATURE "$state_file")"
  status_file="$(render_branch_status "$branch" "$feature")"

  echo "Current branch flow:"
  echo "  $(checkbox_for_flow feature "$state_file") feature -> $(checkbox_for_human_approve "$feature") human approve -> $(checkbox_for_flow plan "$state_file") plan -> $(checkbox_for_flow ready "$state_file") ready -> $(checkbox_for_flow implement "$state_file") implement -> $(checkbox_for_flow review "$state_file") review -> $(checkbox_for_flow pr "$state_file") pr -> [ ] human review -> [ ] merge"
  echo "  branch=$branch feature=${feature:-unknown} status=${status_file}"
}

print_status_detail() {
  local feature="${1:-}"
  local branch state_file status_file

  branch="$(current_branch)"
  state_file="$(state_file_for_branch "$branch")"

  if ! ai_orch_initialized; then
    echo "[AI_ORCH_NOT_INITIALIZED] First required command: /ai-orch:init"
    return 1
  fi

  if [ -n "$feature" ]; then
    state_set FEATURE "$feature" "$state_file"
  fi

  status_file="$(render_branch_status "$branch" "$feature")"

  cat "$status_file"
}

record_flow() {
  local flow="$1"
  local feature="$2"
  local status="$3"
  local output_file="${4:-}"
  local artifact="${5:-}"
  local branch state_file key now run_id run_file pr_url

  branch="$(current_branch)"
  state_file="$(state_file_for_branch "$branch")"
  key="$(flow_state_key "$flow")"
  now="$(date '+%Y-%m-%d %H:%M:%S %z')"
  run_id="$(date '+%Y%m%dT%H%M%S%z')-$(branch_slug "$branch")-$flow"
  run_file=".ai-orch/runs/$run_id.md"

  mkdir -p ".ai-orch/runs"

  if [ -n "$feature" ]; then
    state_set FEATURE "$feature" "$state_file"
  fi

  state_set "FLOW_$key" "$status" "$state_file"
  state_set "FLOW_${key}_AT" "$now" "$state_file"

  if [ "$flow" = "docs" ] && [ -n "$artifact" ]; then
    state_set DOCS_OUTPUT "$artifact" "$state_file"
  fi

  if [ "$flow" = "pr" ] && [ -n "$output_file" ] && [ -f "$output_file" ]; then
    pr_url="$(grep -Eo 'https://[^[:space:]]+' "$output_file" | head -n 1 || true)"
    if [ -n "$pr_url" ]; then
      state_set PR_URL "$pr_url" "$state_file"
    fi
  fi

  render_branch_status "$branch" "$feature" >/dev/null

  cat > "$run_file" <<EOF_RUN
# AI Orch Run

- Branch: \`$branch\`
- Feature: \`${feature:-unknown}\`
- Flow: \`$flow\`
- Status: \`$status\`
- Time: $now
- Branch status: \`$(status_file_for_branch "$branch")\`
EOF_RUN
}

run_and_record() {
  local flow="$1"
  local feature="$2"
  local artifact="${3:-}"
  local output_file exit_code

  shift 3 || true

  if [ "$flow" != "init" ] && ! ai_orch_initialized; then
    echo "[AI_ORCH_NOT_INITIALIZED] First required command: /ai-orch:init"
    return 1
  fi

  output_file="$(mktemp)"

  set +e
  "$@" 2>&1 | tee "$output_file"
  exit_code=${PIPESTATUS[0]}
  set -e

  if [ "$exit_code" -eq 0 ]; then
    record_flow "$flow" "$feature" "done" "$output_file" "$artifact"
  else
    record_flow "$flow" "$feature" "failed" "$output_file" "$artifact"
  fi

  rm -f "$output_file"
  return "$exit_code"
}

run_ready_flow() {
  local feature="$1"
  "$SCRIPT_DIR/sdd-analyze.sh" "$feature"
  "$SCRIPT_DIR/check-sdd-docs.sh" "$feature"
}

load_ai_orch_env_once() {
  if [ "$AI_ORCH_ENV_LOADED" = "0" ]; then
    load_project_env "$TARGET_REPO"
    AI_ORCH_ENV_LOADED=1
  fi
}

local_tests_enabled() {
  local mode

  load_ai_orch_env_once
  mode="$(printf '%s' "${AI_LOCAL_TESTS:-run}" | tr '[:upper:]' '[:lower:]')"

  case "$mode" in
    run|true|1|yes|on|"")
      return 0
      ;;
    skip|false|0|no|off)
      return 1
      ;;
    *)
      echo "[AI_ORCH_WARN] Unknown AI_LOCAL_TESTS value: ${AI_LOCAL_TESTS}. Running local tests."
      return 0
      ;;
  esac
}

run_local_tests() {
  local context="$1"

  if local_tests_enabled; then
    "$SCRIPT_DIR/run-tests.sh"
  else
    echo "[AI_ORCH_TESTS_SKIPPED] context=$context AI_LOCAL_TESTS=${AI_LOCAL_TESTS:-skip}"
    echo "[AI_ORCH_TESTS_NOTE] GitHub Actions still runs scripts/run-tests.sh on main pushes and pull requests."
  fi
}

run_implement_flow() {
  local feature="$1"
  "$SCRIPT_DIR/check-sdd-docs.sh" "$feature"
  "$SCRIPT_DIR/sdd-implement.sh" "$feature"
  run_local_tests "implement"
}

run_review_flow() {
  local feature="$1"
  run_local_tests "review"
  "$SCRIPT_DIR/sdd-review-pr.sh" "$feature"
}

run_release_check_flow() {
  local feature="$1"
  "$SCRIPT_DIR/sdd-analyze.sh" "$feature"
  "$SCRIPT_DIR/check-sdd-docs.sh" "$feature"
  run_local_tests "release-check"
  "$SCRIPT_DIR/sdd-review-pr.sh" "$feature"
}

print_help() {
  usage
  echo
  print_status_summary
}

print_plan() {
  local flow="$1"
  local feature="${2:-}"

  echo "[AI_ORCH_PLAN] flow=$flow${feature:+ feature=$feature}"

  case "$flow" in
    init)
      cat <<'EOF_PLAN'
1. Run scripts/ai-orch-init.sh.
2. Create or refresh static .ai-orch/README.md (plugin version is recorded in .ai-orch/init.json, not in README).
3. Create .ai-orch/setting.json, .ai-orch/settings.example.json, and .ai-orch/setting.local.json when missing.
4. Create .ai-orch/protect.local template when missing.
5. Bootstrap plugin reference artifacts into .ai-orch/: goose/recipes/, specify/memory/constitution.md, docs/{ai-governance,project-settings}.md, templates/sample-feature/, protect.shared.
6. Ensure CLAUDE.md points to AGENTS.md as a symlink when missing.
7. Write .ai-orch/init.json local marker with pluginVersion.
8. Ensure .gitignore ignores local state while keeping shared .ai-orch files trackable.
9. Record init completion in the current branch local state.
10. Print the next status command.
EOF_PLAN
      ;;
    protect)
      cat <<'EOF_PLAN'
1. Run scripts/ai-protect.sh with the requested action.
2. Load shared policy from .ai-orch/protect.shared (legacy fallback: ai-orch.protect at repo root, then bundled plugin policy).
3. Load local deny policy from .ai-orch/protect.local when present.
4. Load user-confirmed local allow policy from .ai-orch/protect.allow.local when present.
5. Block protected access unless the path is explicitly allowed locally.
EOF_PLAN
      ;;
    preflight)
      cat <<'EOF_PLAN'
1. Run scripts/preflight.sh.
2. Probe each tracked CLI tool (jq, gh, goose, codex, claude) for presence and version.
3. For any missing tool, print the install command for the detected OS and the docs URL.
4. Exit 0 if every required-level tool is present; warn (not fail) for optional/flow-specific tools.
EOF_PLAN
      ;;
    doctor)
      cat <<'EOF_PLAN'
1. Run scripts/preflight.sh check (warn on any missing optional tools).
2. Run scripts/run-tests.sh.
3. Validate shell script syntax.
4. Validate sample SDD gate.
EOF_PLAN
      ;;
    docs)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-docs.sh with topic and output path.
2. Load .ai-orch/setting.local.json and .ai-orch/setting.json through the wrapper.
3. Execute Goose with .goose/recipes/sdd-research-docs.yaml.
4. Write the requested Markdown document.
EOF_PLAN
      ;;
    specify|feature)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-specify.sh.
2. Load AI_DOC_PROVIDER / AI_DOC_MODEL.
3. Execute Goose with .goose/recipes/sdd-specify.yaml.
4. Draft spec.md, requirements.md, acceptance-criteria.md, and clarifications.md.
5. Stop for human review. AI must not mark Human Approved.
EOF_PLAN
      ;;
    clarify)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-clarify.sh.
2. Load AI_DOC_PROVIDER / AI_DOC_MODEL.
3. Execute Goose with .goose/recipes/sdd-clarify.yaml.
4. Update clarifications.md with unresolved decisions or resolved notes.
5. Stop if HUMAN_DECISION_REQUIRED is needed.
EOF_PLAN
      ;;
    plan)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-plan.sh.
2. Load AI_ARCH_PROVIDER / AI_ARCH_MODEL.
3. Execute Goose with .goose/recipes/sdd-plan.yaml.
4. Produce technical-plan.md, plan.md, research.md, data-model.md, contracts/, quickstart.md, tasks.md, test-plan.md, and traceability.md.
5. Stop for human plan/scope review.
EOF_PLAN
      ;;
    ready)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-analyze.sh.
2. Load AI_REVIEW_PROVIDER / AI_REVIEW_MODEL.
3. Execute Goose with .goose/recipes/sdd-analyze.yaml.
4. Produce or update analysis.md and checklist.md.
5. Run scripts/check-sdd-docs.sh to enforce the implementation gate.
EOF_PLAN
      ;;
    implement)
      cat <<'EOF_PLAN'
1. Run scripts/check-sdd-docs.sh.
2. Run scripts/sdd-implement.sh.
3. Load AI_CODE_PROVIDER / AI_CODE_MODEL.
4. Execute Goose with .goose/recipes/sdd-implement.yaml.
5. Implement only approved tasks.
6. Run scripts/run-tests.sh unless local settings set AI_LOCAL_TESTS=skip.
EOF_PLAN
      ;;
    review)
      cat <<'EOF_PLAN'
1. Run scripts/run-tests.sh unless local settings set AI_LOCAL_TESTS=skip.
2. Run scripts/sdd-review-pr.sh.
3. Load AI_REVIEW_PROVIDER / AI_REVIEW_MODEL.
4. Execute Goose with .goose/recipes/sdd-review-pr.yaml.
5. Produce self-review.md and prepare PR draft text or draft PR.
6. Stop and return control to human.
EOF_PLAN
      ;;
    pr)
      cat <<'EOF_PLAN'
1. Run scripts/create-pr-draft.sh.
2. Load GitHub configuration through github-lib.sh.
3. Verify gh is installed and authenticated.
4. Create a draft PR with SDD document links.
5. Stop. Human owns review, merge, and release.
EOF_PLAN
      ;;
    release-check)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-analyze.sh.
2. Run scripts/check-sdd-docs.sh.
3. Run scripts/run-tests.sh unless local settings set AI_LOCAL_TESTS=skip.
4. Run scripts/sdd-review-pr.sh.
5. Stop before merge or release.
EOF_PLAN
      ;;
    status)
      cat <<'EOF_PLAN'
1. Resolve the current git branch.
2. Read local state from .ai-orch/state/{branch}.state.
3. Check Human Approved markers in requirements.md and acceptance-criteria.md.
4. Render .ai-orch/branches/{branch}.md with checklist and artifact links.
5. Print the rendered status document.
EOF_PLAN
      ;;
    *)
      echo "[AI_ORCH_FAILED] Unknown flow for explain: $flow"
      usage
      exit 1
      ;;
  esac
}

run_flow() {
  local flow="$1"
  shift || true

  case "$flow" in
    help|-h|--help)
      print_help
      ;;
    init)
      print_plan "$flow"
      run_and_record "$flow" "" ".ai-orch/README.md" "$SCRIPT_DIR/ai-orch-init.sh"
      ;;
    protect)
      print_plan "$flow"
      if [ "$#" -eq 0 ]; then
        "$SCRIPT_DIR/ai-protect.sh" list
      else
        "$SCRIPT_DIR/ai-protect.sh" "$@"
      fi
      ;;
    doctor)
      print_plan "$flow"
      "$SCRIPT_DIR/preflight.sh" check || true
      echo
      "$SCRIPT_DIR/run-tests.sh"
      ;;
    preflight)
      print_plan "$flow"
      "$SCRIPT_DIR/preflight.sh" "${1:-check}"
      ;;
    docs)
      local topic="${1:-}"
      local output="${2:-}"
      need_arg "$topic" "docs flow requires <topic>."
      need_arg "$output" "docs flow requires <output-markdown-path>."
      print_plan "$flow"
      run_and_record "$flow" "" "$output" "$SCRIPT_DIR/sdd-docs.sh" "$topic" "$output"
      ;;
    specify)
      local feature="${1:-}"
      local description="${2:-}"
      need_arg "$feature" "specify flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" "$SCRIPT_DIR/sdd-specify.sh" "$feature" "$description"
      ;;
    feature)
      local feature="${1:-}"
      local description="${2:-}"
      need_arg "$feature" "feature flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" "$SCRIPT_DIR/sdd-specify.sh" "$feature" "$description"
      ;;
    clarify)
      local feature="${1:-}"
      need_arg "$feature" "clarify flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" "$SCRIPT_DIR/sdd-clarify.sh" "$feature"
      ;;
    plan)
      local feature="${1:-}"
      need_arg "$feature" "plan flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" "$SCRIPT_DIR/sdd-plan.sh" "$feature"
      ;;
    ready)
      local feature="${1:-}"
      need_arg "$feature" "ready flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" run_ready_flow "$feature"
      ;;
    implement)
      local feature="${1:-}"
      need_arg "$feature" "implement flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" run_implement_flow "$feature"
      ;;
    review)
      local feature="${1:-}"
      need_arg "$feature" "review flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" run_review_flow "$feature"
      ;;
    pr)
      local feature="${1:-}"
      need_arg "$feature" "pr flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" "$SCRIPT_DIR/create-pr-draft.sh" "$feature"
      ;;
    release-check)
      local feature="${1:-}"
      need_arg "$feature" "release-check flow requires <feature-name>."
      print_plan "$flow" "$feature"
      run_and_record "$flow" "$feature" "" run_release_check_flow "$feature"
      ;;
    status)
      print_plan "$flow" "${1:-}"
      print_status_detail "${1:-}"
      ;;
    explain)
      local target_flow="${1:-}"
      need_arg "$target_flow" "explain requires <flow>."
      print_plan "$target_flow" "${2:-}"
      ;;
    version)
      local marker="$TARGET_REPO/.ai-orch/init.json"
      if [ -f "$marker" ] && command -v jq >/dev/null 2>&1; then
        local recorded
        recorded="$(jq -r '.pluginVersion // empty' "$marker" 2>/dev/null)"
        if [ -n "$recorded" ]; then
          echo "$recorded"
          return 0
        fi
      fi
      grep '^PLUGIN_VERSION=' "$SCRIPT_DIR/ai-orch-init.sh" | head -1 \
        | sed -E 's/^PLUGIN_VERSION="([^"]+)".*/\1/'
      ;;
    *)
      echo "[AI_ORCH_FAILED] Unknown flow: $flow"
      usage
      exit 1
      ;;
  esac
}

FLOW="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

run_flow "$FLOW" "$@"
