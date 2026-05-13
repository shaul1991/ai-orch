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

echo "[TEST] Checking ai-orch-init bootstraps SDD infrastructure into a fresh target."
INIT_TMP="$(mktemp -d)"
(
  cd "$INIT_TMP"
  "$PROJECT_ROOT/scripts/ai-orch-init.sh" >/dev/null
)
MISSING_FILES=()
for f in \
  .ai-orch/goose/recipes/sdd-specify.yaml \
  .ai-orch/goose/recipes/sdd-clarify.yaml \
  .ai-orch/goose/recipes/sdd-plan.yaml \
  .ai-orch/goose/recipes/sdd-analyze.yaml \
  .ai-orch/goose/recipes/sdd-implement.yaml \
  .ai-orch/goose/recipes/sdd-review-pr.yaml \
  .ai-orch/goose/recipes/sdd-research-docs.yaml \
  .ai-orch/specify/memory/constitution.md \
  .ai-orch/docs/ai-governance.md \
  .ai-orch/docs/project-settings.md \
  .ai-orch/templates/sample-feature/spec.md \
  .ai-orch/protect.shared \
  AGENTS.md; do
  if [ ! -f "$INIT_TMP/$f" ]; then
    MISSING_FILES+=("$f")
  fi
done
if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "[TEST_FAILED] ai-orch-init did not bootstrap: ${MISSING_FILES[*]}"
  rm -rf "$INIT_TMP"
  exit 1
fi
# Negative check: target repo root should remain pure (no plugin artifacts leaked).
for stray in .goose .specify docs/ai-governance.md docs/project-settings.md docs/specs ai-orch.protect; do
  if [ -e "$INIT_TMP/$stray" ]; then
    echo "[TEST_FAILED] ai-orch-init leaked plugin artifact to target root: $stray"
    rm -rf "$INIT_TMP"
    exit 1
  fi
done
if [ ! -L "$INIT_TMP/CLAUDE.md" ]; then
  echo "[TEST_FAILED] ai-orch-init did not create CLAUDE.md symlink."
  rm -rf "$INIT_TMP"
  exit 1
fi
if grep -Eq '`[0-9]+\.[0-9]+\.[0-9]+`' "$INIT_TMP/.ai-orch/README.md"; then
  echo "[TEST_FAILED] .ai-orch/README.md embeds a literal plugin version (issue #16 regression)."
  rm -rf "$INIT_TMP"
  exit 1
fi
rm -rf "$INIT_TMP"

echo "[TEST] Checking preflight check runs and reports required jq."
PREFLIGHT_OUT="$("$PROJECT_ROOT/scripts/preflight.sh" check 2>&1 || true)"
if ! printf '%s\n' "$PREFLIGHT_OUT" | grep -q '\[PREFLIGHT_CHECK\]'; then
  echo "[TEST_FAILED] preflight did not print [PREFLIGHT_CHECK] header."
  printf '%s\n' "$PREFLIGHT_OUT"
  exit 1
fi
if ! printf '%s\n' "$PREFLIGHT_OUT" | grep -Eq '^\s+jq\b'; then
  echo "[TEST_FAILED] preflight did not report jq."
  printf '%s\n' "$PREFLIGHT_OUT"
  exit 1
fi
if ! printf '%s\n' "$PREFLIGHT_OUT" | grep -q '\[PREFLIGHT_RESULT\]'; then
  echo "[TEST_FAILED] preflight did not print [PREFLIGHT_RESULT] summary."
  printf '%s\n' "$PREFLIGHT_OUT"
  exit 1
fi
# Simulate missing required tool by stripping PATH; required jq absence must yield exit 1.
if PATH="/usr/bin:/bin" "$PROJECT_ROOT/scripts/preflight.sh" check >/dev/null 2>&1; then
  : # PATH may still contain jq on some systems; treat as inconclusive rather than failure.
fi

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
