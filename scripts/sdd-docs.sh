#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TARGET_REPO="$(pwd -P)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$TARGET_REPO"
cd "$TARGET_REPO"

TOPIC="${1:-}"
OUTPUT="${2:-}"

if [ -z "$TOPIC" ] || [ -z "$OUTPUT" ]; then
  echo "Usage: scripts/sdd-docs.sh <topic> <output-markdown-path>"
  exit 1
fi

PROVIDER="${AI_DOC_PROVIDER:-codex-acp}"
MODEL="${AI_DOC_MODEL:-gpt-5.5}"

goose run \
  --provider "$PROVIDER" \
  --model "$MODEL" \
  --recipe "$PROJECT_ROOT/.goose/recipes/sdd-research-docs.yaml" \
  --params "topic=$TOPIC" \
  --params "output=$OUTPUT"
