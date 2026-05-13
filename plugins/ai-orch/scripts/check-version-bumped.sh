#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
REPO_ROOT="$(cd -P "$PROJECT_ROOT/../.." && pwd -P)"
cd "$REPO_ROOT"

BASE_REF="${1:-origin/main}"
MANIFEST="plugins/ai-orch/.claude-plugin/plugin.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "[VERSION_CHECK_FAILED] jq is required. install via: brew install jq" >&2
  exit 1
fi

if ! git rev-parse --verify -q "$BASE_REF" >/dev/null; then
  echo "[VERSION_CHECK_SKIP] base ref $BASE_REF not available; nothing to compare."
  exit 0
fi

base_version="$(git show "$BASE_REF:$MANIFEST" 2>/dev/null | jq -r .version)"
head_version="$(jq -r .version "$MANIFEST")"

if [ -z "$base_version" ] || [ "$base_version" = "null" ]; then
  echo "[VERSION_CHECK_SKIP] $MANIFEST not present in $BASE_REF; first-time addition."
  exit 0
fi

if [ "$base_version" = "$head_version" ]; then
  echo "[VERSION_CHECK_FAILED] plugin version unchanged ($head_version) vs $BASE_REF."
  echo "Run: scripts/bump-version.sh patch   # or minor / major"
  exit 1
fi

# Idempotency / consistency: enforce that bump-version.sh's other files are aligned.
scripts/bump-version.sh show >/dev/null

echo "[VERSION_CHECK_PASSED] $base_version -> $head_version"
