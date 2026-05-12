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

exit 0
