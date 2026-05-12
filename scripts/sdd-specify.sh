#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT/.env"
cd "$PROJECT_ROOT"

FEATURE="${1:-}"
DESCRIPTION="${2:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: scripts/sdd-specify.sh <feature-name> [feature-description]"
  exit 1
fi

PROVIDER="${AI_DOC_PROVIDER:-codex-acp}"
MODEL="${AI_DOC_MODEL:-gpt-5.5}"

goose run \
  --provider "$PROVIDER" \
  --model "$MODEL" \
  --recipe .goose/recipes/sdd-specify.yaml \
  --params "feature=$FEATURE" \
  --params "description=$DESCRIPTION"
