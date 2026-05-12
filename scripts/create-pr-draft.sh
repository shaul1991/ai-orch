#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TARGET_REPO="$(pwd -P)"

source "$SCRIPT_DIR/github-lib.sh"
cd "$TARGET_REPO"

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

require_gh
REPO="$(resolve_gh_repo)"

TITLE="SDD: $FEATURE"

BODY_FILE="$(mktemp)"
trap 'rm -f "$BODY_FILE"' EXIT

cat > "$BODY_FILE" <<EOF_PR
## Summary

This PR was prepared under Human-Governed SDD.

## SDD Documents

- Constitution: \`.specify/memory/constitution.md\`
- Spec: \`$BASE/spec.md\`
- Requirements: \`$BASE/requirements.md\`
- Acceptance Criteria: \`$BASE/acceptance-criteria.md\`
- Clarifications: \`$BASE/clarifications.md\`
- Technical Plan: \`$BASE/technical-plan.md\`
- Spec Kit Plan: \`$BASE/plan.md\`
- Research: \`$BASE/research.md\`
- Data Model: \`$BASE/data-model.md\`
- Contracts: \`$BASE/contracts/\`
- Quickstart: \`$BASE/quickstart.md\`
- Tasks: \`$BASE/tasks.md\`
- Test Plan: \`$BASE/test-plan.md\`
- Traceability: \`$BASE/traceability.md\`
- Analysis: \`$BASE/analysis.md\`
- Checklist: \`$BASE/checklist.md\`
- Self Review: \`$BASE/self-review.md\`

## Human Review Required

- [ ] Domain behavior
- [ ] Business policy
- [ ] Scope compliance
- [ ] Code quality
- [ ] Test coverage
- [ ] Merge decision
EOF_PR

ARGS=(pr create --repo "$REPO" --draft --title "$TITLE" --body-file "$BODY_FILE")

if [ -n "${AI_GITHUB_BASE_BRANCH:-}" ]; then
  ARGS+=(--base "$AI_GITHUB_BASE_BRANCH")
fi

gh "${ARGS[@]}"
