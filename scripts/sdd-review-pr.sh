#!/usr/bin/env bash
set -euo pipefail

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
