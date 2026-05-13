#!/usr/bin/env bash
set -euo pipefail

# AI Orch preflight — inventory external CLI tools and print install guidance.
# Does NOT execute any installer; users copy/paste the printed commands.
#
# Exit code:
#   0 when every "required" tool is present (missing tools at other levels
#     are reported as warnings but do not fail the exit).
#   1 when at least one "required" tool is missing.

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"

ACTION="${1:-check}"

OS_FAMILY=other
case "$(uname -s)" in
  Darwin) OS_FAMILY=macos ;;
  Linux)  OS_FAMILY=linux ;;
esac

usage() {
  cat <<'EOF_USAGE'
Usage:
  scripts/preflight.sh           # alias of check
  scripts/preflight.sh check     # report missing tools with install hints
  scripts/preflight.sh install   # alias of check, with extra "copy/paste" reminder
  scripts/preflight.sh list      # same as check (kept for symmetry)

Tracked tools:
  jq     [required]  JSON parsing for ai-orch internals (bump-version, version, status)
  gh     [github]    GitHub CLI for /ai-orch:pr and PR/issue tracking
  goose  [sdd]       Block Goose runner for SDD recipes (specify/plan/implement)
  codex  [provider]  OpenAI Codex CLI when AI_DOC_PROVIDER=codex-acp
  claude [provider]  Claude Code CLI (already running if you invoked /ai-orch:preflight)

This script prints install commands; it never executes installers. Copy and run
them manually so that nothing modifies your system without your action.
EOF_USAGE
}

PRINTED_REQUIRED_MISSING=0
PRINTED_OPTIONAL_MISSING=0

print_row() {
  local name="$1" level="$2" status="$3" detail="$4"
  printf '  %-8s [%-9s] %-8s %s\n' "$name" "$level" "$status" "$detail"
}

print_hint() {
  local label="$1" cmd="$2"
  [ -n "$cmd" ] || return 0
  printf '              %-9s %s\n' "$label" "$cmd"
}

check_tool() {
  local name="$1" level="$2" desc="$3" macos_cmd="$4" linux_cmd="$5" url="$6"

  if command -v "$name" >/dev/null 2>&1; then
    local version=""
    if version="$("$name" --version 2>/dev/null | head -1)" && [ -n "$version" ]; then
      :
    else
      version="(version probe unavailable)"
    fi
    print_row "$name" "$level" "OK" "$version"
    return 0
  fi

  print_row "$name" "$level" "MISSING" "$desc"
  case "$OS_FAMILY" in
    macos) print_hint "macOS:" "$macos_cmd" ;;
    linux) print_hint "Linux:" "$linux_cmd" ;;
  esac
  print_hint "docs:" "$url"

  if [ "$level" = "required" ]; then
    PRINTED_REQUIRED_MISSING=$((PRINTED_REQUIRED_MISSING + 1))
  else
    PRINTED_OPTIONAL_MISSING=$((PRINTED_OPTIONAL_MISSING + 1))
  fi
}

run_checks() {
  echo "[PREFLIGHT_CHECK] external CLI tool inventory (OS family: $OS_FAMILY)"
  echo

  # name | level | description | macOS install | Linux install | docs URL
  check_tool jq required \
    "JSON parsing for ai-orch internals (bump-version, status, version)" \
    "brew install jq" \
    "sudo apt-get install -y jq" \
    "https://jqlang.github.io/jq/"

  check_tool gh github \
    "GitHub CLI for /ai-orch:pr, issue/PR list/view, and AI_GITHUB_* helpers" \
    "brew install gh" \
    "sudo apt-get install -y gh" \
    "https://cli.github.com/"

  check_tool goose sdd \
    "Block Goose recipe runner used by sdd-specify/plan/implement/review/docs" \
    "" \
    "" \
    "https://block.github.io/goose/docs/getting-started/installation"

  check_tool codex provider \
    "OpenAI Codex CLI; required when AI_DOC_PROVIDER=codex-acp (default)" \
    "" \
    "" \
    "https://github.com/openai/codex"

  check_tool claude provider \
    "Claude Code CLI; already running if you invoked this from a Claude session" \
    "" \
    "" \
    "https://docs.anthropic.com/en/docs/claude-code/setup"

  echo

  if [ "$PRINTED_REQUIRED_MISSING" -gt 0 ]; then
    echo "[PREFLIGHT_RESULT] $PRINTED_REQUIRED_MISSING required tool(s) missing. Install the items above and re-run."
    return 1
  fi

  if [ "$PRINTED_OPTIONAL_MISSING" -gt 0 ]; then
    echo "[PREFLIGHT_RESULT] required tools present. $PRINTED_OPTIONAL_MISSING optional/flow-specific tool(s) missing (see above)."
    echo "  Flows that depend on a missing tool will fail when invoked; install the relevant tool first."
  else
    echo "[PREFLIGHT_RESULT] all tracked tools present."
  fi

  return 0
}

case "$ACTION" in
  check|list|"")
    run_checks
    ;;
  install)
    run_checks
    rc=$?
    echo
    echo "[PREFLIGHT_INSTALL_HINT] Copy the install commands above and run them manually."
    echo "  This script does NOT execute installers to avoid modifying your system without consent."
    exit "$rc"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "[PREFLIGHT_FAILED] unknown action: $ACTION" >&2
    usage >&2
    exit 1
    ;;
esac
