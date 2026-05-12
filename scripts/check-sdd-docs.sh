#!/usr/bin/env bash
set -euo pipefail

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/check-sdd-docs.sh <feature-name>"
  exit 1
fi

BASE="docs/specs/$FEATURE"

REQUIRED_FILES=(
  "$BASE/requirements.md"
  "$BASE/acceptance-criteria.md"
  "$BASE/technical-plan.md"
  "$BASE/tasks.md"
  "$BASE/test-plan.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "[SDD_GATE_FAILED] Missing required file: $file"
    exit 1
  fi
done

if ! grep -q "Human Approved" "$BASE/requirements.md"; then
  echo "[SDD_GATE_FAILED] requirements.md must contain 'Human Approved'"
  exit 1
fi

if ! grep -q "Human Approved" "$BASE/acceptance-criteria.md"; then
  echo "[SDD_GATE_FAILED] acceptance-criteria.md must contain 'Human Approved'"
  exit 1
fi

echo "[SDD_GATE_PASSED] All required SDD documents exist and are approved."
