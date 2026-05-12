#!/usr/bin/env bash
set -euo pipefail

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/create-pr-draft.sh <feature-name>"
  exit 1
fi

BASE="docs/specs/$FEATURE"

if [ ! -f "$BASE/self-review.md" ]; then
  echo "[PR_DRAFT_FAILED] Missing required file: $BASE/self-review.md"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "[PR_DRAFT] GitHub CLI not found. Print PR draft instead."
  cat "$BASE/self-review.md"
  exit 0
fi

TITLE="SDD: $FEATURE"

BODY_FILE="$(mktemp)"
trap 'rm -f "$BODY_FILE"' EXIT

cat > "$BODY_FILE" <<EOF_PR
## Summary

This PR was prepared under Human-Governed SDD.

## SDD Documents

- Requirements: \`$BASE/requirements.md\`
- Acceptance Criteria: \`$BASE/acceptance-criteria.md\`
- Technical Plan: \`$BASE/technical-plan.md\`
- Tasks: \`$BASE/tasks.md\`
- Test Plan: \`$BASE/test-plan.md\`
- Self Review: \`$BASE/self-review.md\`

## Human Review Required

- [ ] Domain behavior
- [ ] Business policy
- [ ] Scope compliance
- [ ] Code quality
- [ ] Test coverage
- [ ] Merge decision
EOF_PR

gh pr create --draft --title "$TITLE" --body-file "$BODY_FILE"
