#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
REPO_ROOT="$(cd -P "$PROJECT_ROOT/../.." && pwd -P)"
cd "$REPO_ROOT"

usage() {
  cat <<'EOF_USAGE'
Usage:
  scripts/bump-version.sh patch
  scripts/bump-version.sh minor
  scripts/bump-version.sh major
  scripts/bump-version.sh set <x.y.z>
  scripts/bump-version.sh show

ai-orch plugin 의 버전을 한 번에 갱신한다. 다음 4 위치를 동시에 업데이트한다.

- .claude-plugin/marketplace.json (.metadata.version, .plugins[].version)
- plugins/ai-orch/.claude-plugin/plugin.json (.version)
- plugins/ai-orch/.codex-plugin/plugin.json (.version)
- scripts/ai-orch-init.sh (PLUGIN_VERSION constant)

PR 머지 전에 한 번 실행한다. 같은 PR 안에서 두 번 실행해도 안전 (idempotent 하지 않으므로 신중히).
EOF_USAGE
}

MANIFEST_MARKETPLACE=".claude-plugin/marketplace.json"
MANIFEST_PLUGIN="plugins/ai-orch/.claude-plugin/plugin.json"
MANIFEST_CODEX="plugins/ai-orch/.codex-plugin/plugin.json"
INIT_SCRIPT="scripts/ai-orch-init.sh"

read_current_version() {
  jq -r .version "$MANIFEST_PLUGIN"
}

check_consistent() {
  local current="$1"
  local v_market_meta v_market_entry v_plugin v_codex v_init
  v_market_meta="$(jq -r .metadata.version "$MANIFEST_MARKETPLACE")"
  v_market_entry="$(jq -r .plugins[0].version "$MANIFEST_MARKETPLACE")"
  v_plugin="$(jq -r .version "$MANIFEST_PLUGIN")"
  v_codex="$(jq -r .version "$MANIFEST_CODEX")"
  v_init="$(grep '^PLUGIN_VERSION=' "$INIT_SCRIPT" | sed -E 's/^PLUGIN_VERSION="([^"]+)".*/\1/')"

  local failed=()
  [ "$v_market_meta"  = "$current" ] || failed+=("$MANIFEST_MARKETPLACE .metadata.version=$v_market_meta")
  [ "$v_market_entry" = "$current" ] || failed+=("$MANIFEST_MARKETPLACE .plugins[0].version=$v_market_entry")
  [ "$v_plugin"       = "$current" ] || failed+=("$MANIFEST_PLUGIN .version=$v_plugin")
  [ "$v_codex"        = "$current" ] || failed+=("$MANIFEST_CODEX .version=$v_codex")
  [ "$v_init"         = "$current" ] || failed+=("$INIT_SCRIPT PLUGIN_VERSION=$v_init")

  if [ ${#failed[@]} -gt 0 ]; then
    echo "[BUMP_VERSION_INCONSISTENT] expected $current but found:" >&2
    printf '  - %s\n' "${failed[@]}" >&2
    return 1
  fi
}

write_json_field() {
  local file="$1"
  local jq_filter="$2"
  local tmp
  tmp="$(mktemp)"
  jq "$jq_filter" "$file" > "$tmp"
  mv "$tmp" "$file"
}

apply_version() {
  local new="$1"

  write_json_field "$MANIFEST_MARKETPLACE" \
    '.metadata.version = "'"$new"'" | .plugins[0].version = "'"$new"'"'

  write_json_field "$MANIFEST_PLUGIN" \
    '.version = "'"$new"'"'

  write_json_field "$MANIFEST_CODEX" \
    '.version = "'"$new"'"'

  # In-place edit for the shell constant.
  if sed --version >/dev/null 2>&1; then
    sed -i -E 's/^PLUGIN_VERSION="[^"]+"/PLUGIN_VERSION="'"$new"'"/' "$INIT_SCRIPT"
  else
    sed -i '' -E 's/^PLUGIN_VERSION="[^"]+"/PLUGIN_VERSION="'"$new"'"/' "$INIT_SCRIPT"
  fi
}

compute_next() {
  local current="$1" part="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$current"

  case "$part" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
    *)
      echo "[BUMP_VERSION_FAILED] unknown bump part: $part" >&2
      return 1
      ;;
  esac

  printf '%s.%s.%s\n' "$major" "$minor" "$patch"
}

validate_semver() {
  local v="$1"
  if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[BUMP_VERSION_FAILED] not a valid semver: $v" >&2
    return 1
  fi
}

main() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "[BUMP_VERSION_FAILED] jq is required. install via: brew install jq" >&2
    exit 1
  fi

  local cmd="${1:-}"
  case "$cmd" in
    show)
      local current
      current="$(read_current_version)"
      validate_semver "$current"
      check_consistent "$current"
      echo "$current"
      ;;
    patch|minor|major)
      local current next
      current="$(read_current_version)"
      validate_semver "$current"
      check_consistent "$current"
      next="$(compute_next "$current" "$cmd")"
      validate_semver "$next"
      apply_version "$next"
      check_consistent "$next"
      echo "[BUMP_VERSION_DONE] $current -> $next"
      ;;
    set)
      local current next
      next="${2:-}"
      validate_semver "$next"
      current="$(read_current_version)"
      validate_semver "$current"
      check_consistent "$current"
      apply_version "$next"
      check_consistent "$next"
      echo "[BUMP_VERSION_DONE] $current -> $next"
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      echo "[BUMP_VERSION_FAILED] unknown command: $cmd" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
