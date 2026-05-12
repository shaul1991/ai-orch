#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TARGET_REPO="$(pwd -P)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$TARGET_REPO"
cd "$TARGET_REPO"

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/sdd-implement.sh <feature-name>"
  exit 1
fi

PROVIDER="${AI_CODE_PROVIDER:-claude-code}"
MODEL="${AI_CODE_MODEL:-default}"

goose run \
  --provider "$PROVIDER" \
  --model "$MODEL" \
  --recipe .goose/recipes/sdd-implement.yaml \
  --params "feature=$FEATURE"
