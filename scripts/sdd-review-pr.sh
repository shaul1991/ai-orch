#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/sdd-review-pr.sh <feature-name>"
  exit 1
fi

PROVIDER="${AI_REVIEW_PROVIDER:-claude-code}"
MODEL="${AI_REVIEW_MODEL:-default}"

goose run \
  --provider "$PROVIDER" \
  --model "$MODEL" \
  --recipe .goose/recipes/sdd-review-pr.yaml \
  --params "feature=$FEATURE"
