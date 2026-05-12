#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

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
  --recipe .goose/recipes/sdd-research-docs.yaml \
  --params "topic=$TOPIC" \
  --params "output=$OUTPUT"
