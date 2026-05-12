#!/usr/bin/env bash
set -euo pipefail

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
