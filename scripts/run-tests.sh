#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"

if [ -n "${AI_TEST_COMMANDS:-}" ]; then
  echo "[TEST] Running AI_TEST_COMMANDS."
  while IFS= read -r command; do
    if [ -z "$command" ]; then
      continue
    fi
    echo "[TEST] $command"
    bash -lc "$command"
  done <<< "$AI_TEST_COMMANDS"
  exit 0
fi

cd "$PROJECT_ROOT"

echo "[TEST] Checking shell script syntax."

STATUS=0
for script in scripts/*.sh; do
  if ! bash -n "$script"; then
    STATUS=1
  fi
done

if [ "$STATUS" -ne 0 ]; then
  echo "[TEST_FAILED] Shell syntax check failed."
  exit "$STATUS"
fi

echo "[TEST] Checking sample SDD gate."
scripts/check-sdd-docs.sh sample-feature

echo "[TEST] Checking protected file policy."
AI_PROTECT_IGNORE_LOCAL=1 scripts/ai-protect.sh check-read .ai-orch/settings.example.json >/dev/null

if AI_PROTECT_IGNORE_LOCAL=1 scripts/ai-protect.sh check-read .env >/dev/null 2>&1; then
  echo "[TEST_FAILED] .env read should be protected."
  exit 1
fi

if AI_PROTECT_IGNORE_LOCAL=1 scripts/ai-protect.sh check-write .env >/dev/null 2>&1; then
  echo "[TEST_FAILED] .env write should be protected."
  exit 1
fi

if AI_PROTECT_IGNORE_LOCAL=1 scripts/ai-guard.sh cat .env >/dev/null 2>&1; then
  echo "[TEST_FAILED] ai-guard should block protected .env access."
  exit 1
fi

echo "[TEST] Checking shared policy fallback when target lacks ai-orch.protect."
PLUGIN_ROOT="$(pwd -P)"
FALLBACK_TMP="$(mktemp -d)"
if (
  cd "$FALLBACK_TMP" && \
  AI_PROTECT_IGNORE_LOCAL=1 "$PLUGIN_ROOT/scripts/ai-protect.sh" check-read .env >/dev/null 2>&1
); then
  echo "[TEST_FAILED] Fallback to bundled ai-orch.protect did not fire (.env was not blocked)."
  rm -rf "$FALLBACK_TMP"
  exit 1
fi
rm -rf "$FALLBACK_TMP"

echo "[TEST] Checking github-lib honors AI_ORCH_TARGET_REPO."
GHLIB_TMP="$(mktemp -d)"
(
  cd "$GHLIB_TMP"
  git init -q
  git remote add origin git@github.com:test-owner/test-repo.git
)
REPO_OUT="$(AI_ORCH_TARGET_REPO="$GHLIB_TMP" bash -c \
  'source "'"$PLUGIN_ROOT"'/scripts/github-lib.sh"; resolve_repo_from_origin' 2>/dev/null || true)"
if [ "$REPO_OUT" != "test-owner/test-repo" ]; then
  echo "[TEST_FAILED] github-lib did not honor AI_ORCH_TARGET_REPO (got: '$REPO_OUT')."
  rm -rf "$GHLIB_TMP"
  exit 1
fi
rm -rf "$GHLIB_TMP"

exit 0
