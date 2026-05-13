#!/usr/bin/env bash
set -euo pipefail

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/check-sdd-docs.sh <feature-name>"
  exit 1
fi

BASE="docs/specs/$FEATURE"
FAILURES=()

add_failure() {
  FAILURES+=("$1")
}

CONSTITUTION_FOUND=""
for candidate in \
  ".ai-orch/specify/memory/constitution.md" \
  ".specify/memory/constitution.md"; do
  if [ -f "$candidate" ]; then
    CONSTITUTION_FOUND="$candidate"
    break
  fi
done

if [ -z "$CONSTITUTION_FOUND" ]; then
  add_failure "Missing required file: .ai-orch/specify/memory/constitution.md (legacy fallback: .specify/memory/constitution.md)"
fi

REQUIRED_FILES=(
  "$BASE/spec.md"
  "$BASE/requirements.md"
  "$BASE/acceptance-criteria.md"
  "$BASE/clarifications.md"
  "$BASE/technical-plan.md"
  "$BASE/plan.md"
  "$BASE/research.md"
  "$BASE/data-model.md"
  "$BASE/quickstart.md"
  "$BASE/tasks.md"
  "$BASE/test-plan.md"
  "$BASE/traceability.md"
  "$BASE/analysis.md"
  "$BASE/checklist.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    add_failure "Missing required file: $file"
  fi
done

if [ ! -d "$BASE/contracts" ]; then
  add_failure "Missing required directory: $BASE/contracts"
elif ! find "$BASE/contracts" -mindepth 1 -type f | grep -q .; then
  add_failure "contracts directory must contain at least one contract note or contract file: $BASE/contracts"
fi

if [ -f "$BASE/requirements.md" ] && ! grep -q "Human Approved" "$BASE/requirements.md"; then
  add_failure "requirements.md must contain 'Human Approved'"
fi

if [ -f "$BASE/acceptance-criteria.md" ] && ! grep -q "Human Approved" "$BASE/acceptance-criteria.md"; then
  add_failure "acceptance-criteria.md must contain 'Human Approved'"
fi

if [ -d "$BASE" ] && grep -R "\[NEEDS CLARIFICATION" "$BASE" --include='*.md' >/dev/null 2>&1; then
  add_failure "Feature documents contain unresolved [NEEDS CLARIFICATION] markers"
fi

if [ -f "$BASE/tasks.md" ] && ! grep -Eq '^- \[[ xX]\] T[0-9]{3}' "$BASE/tasks.md"; then
  add_failure "tasks.md must contain task checklist items with IDs like T001"
fi

if [ -f "$BASE/tasks.md" ] && ! grep -Eq '`[^`]*(docs/|scripts/|src/|tests/|backend/|frontend/)[^`]*`' "$BASE/tasks.md"; then
  add_failure "tasks.md must include exact file paths or commands in backticks"
fi

if [ -f "$BASE/traceability.md" ] && ! grep -Eq 'FR-[0-9]{3}' "$BASE/traceability.md"; then
  add_failure "traceability.md must reference requirement IDs like FR-001"
fi

if [ -f "$BASE/traceability.md" ] && ! grep -Eq 'T[0-9]{3}' "$BASE/traceability.md"; then
  add_failure "traceability.md must reference task IDs like T001"
fi

if [ -f "$BASE/test-plan.md" ] && ! grep -q "Test Strategy" "$BASE/test-plan.md"; then
  add_failure "test-plan.md must include a Test Strategy section"
fi

if [ "${#FAILURES[@]}" -gt 0 ]; then
  for failure in "${FAILURES[@]}"; do
    echo "[SDD_GATE_FAILED] $failure"
  done
  exit 1
fi

echo "[SDD_GATE_PASSED] All required SDD documents exist and are approved."
