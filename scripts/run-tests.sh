#!/usr/bin/env bash
set -euo pipefail

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

exit 0
