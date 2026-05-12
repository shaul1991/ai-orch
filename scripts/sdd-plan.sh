#!/usr/bin/env bash
set -euo pipefail

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/sdd-plan.sh <feature-name>"
  exit 1
fi

PROVIDER="${AI_ARCH_PROVIDER:-claude-code}"
MODEL="${AI_ARCH_MODEL:-default}"

goose run \
  --provider "$PROVIDER" \
  --model "$MODEL" \
  --recipe .goose/recipes/sdd-plan.yaml \
  --params "feature=$FEATURE"
