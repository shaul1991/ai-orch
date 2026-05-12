#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT/.env"
cd "$PROJECT_ROOT"

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
