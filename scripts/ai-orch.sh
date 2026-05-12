#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

usage() {
  cat <<'EOF_USAGE'
Usage:
  scripts/ai-orch.sh <flow> [args...]

Flows:
  help
      Show this help.

  doctor
      Check local script syntax and the sample SDD gate.

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

Examples:
  scripts/ai-orch.sh docs "운영 정책 정리" docs/output.md
  scripts/ai-orch.sh feature login "로그인 기능"
  scripts/ai-orch.sh plan login
  scripts/ai-orch.sh ready login
  scripts/ai-orch.sh implement login
  scripts/ai-orch.sh review login
  scripts/ai-orch.sh pr login
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

print_plan() {
  local flow="$1"
  local feature="${2:-}"

  echo "[AI_ORCH_PLAN] flow=$flow${feature:+ feature=$feature}"

  case "$flow" in
    doctor)
      cat <<'EOF_PLAN'
1. Run scripts/run-tests.sh.
2. Validate shell script syntax.
3. Validate sample SDD gate.
EOF_PLAN
      ;;
    docs)
      cat <<'EOF_PLAN'
1. Run scripts/sdd-docs.sh with topic and output path.
2. Load .env through the wrapper.
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
6. Run scripts/run-tests.sh.
EOF_PLAN
      ;;
    review)
      cat <<'EOF_PLAN'
1. Run scripts/run-tests.sh.
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
3. Run scripts/run-tests.sh.
4. Run scripts/sdd-review-pr.sh.
5. Stop before merge or release.
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
      usage
      ;;
    doctor)
      print_plan "$flow"
      scripts/run-tests.sh
      ;;
    docs)
      local topic="${1:-}"
      local output="${2:-}"
      need_arg "$topic" "docs flow requires <topic>."
      need_arg "$output" "docs flow requires <output-markdown-path>."
      print_plan "$flow"
      scripts/sdd-docs.sh "$topic" "$output"
      ;;
    specify)
      local feature="${1:-}"
      local description="${2:-}"
      need_arg "$feature" "specify flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-specify.sh "$feature" "$description"
      ;;
    feature)
      local feature="${1:-}"
      local description="${2:-}"
      need_arg "$feature" "feature flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-specify.sh "$feature" "$description"
      ;;
    clarify)
      local feature="${1:-}"
      need_arg "$feature" "clarify flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-clarify.sh "$feature"
      ;;
    plan)
      local feature="${1:-}"
      need_arg "$feature" "plan flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-plan.sh "$feature"
      ;;
    ready)
      local feature="${1:-}"
      need_arg "$feature" "ready flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-analyze.sh "$feature"
      scripts/check-sdd-docs.sh "$feature"
      ;;
    implement)
      local feature="${1:-}"
      need_arg "$feature" "implement flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/check-sdd-docs.sh "$feature"
      scripts/sdd-implement.sh "$feature"
      scripts/run-tests.sh
      ;;
    review)
      local feature="${1:-}"
      need_arg "$feature" "review flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/run-tests.sh
      scripts/sdd-review-pr.sh "$feature"
      ;;
    pr)
      local feature="${1:-}"
      need_arg "$feature" "pr flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/create-pr-draft.sh "$feature"
      ;;
    release-check)
      local feature="${1:-}"
      need_arg "$feature" "release-check flow requires <feature-name>."
      print_plan "$flow" "$feature"
      scripts/sdd-analyze.sh "$feature"
      scripts/check-sdd-docs.sh "$feature"
      scripts/run-tests.sh
      scripts/sdd-review-pr.sh "$feature"
      ;;
    explain)
      local target_flow="${1:-}"
      need_arg "$target_flow" "explain requires <flow>."
      print_plan "$target_flow" "${2:-}"
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
