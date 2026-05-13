#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

TITLE="${1:-}"
BODY_OR_FILE="${2:-}"
LABELS="${3:-}"

if [ -z "$TITLE" ]; then
  echo "Usage: scripts/github-issue-create.sh <title> [body-or-body-file] [comma-separated-labels]"
  exit 1
fi

require_gh
REPO="$(resolve_gh_repo)"

ARGS=(issue create --repo "$REPO" --title "$TITLE")

if [ -n "$BODY_OR_FILE" ]; then
  if [ -f "$BODY_OR_FILE" ]; then
    ARGS+=(--body-file "$BODY_OR_FILE")
  else
    ARGS+=(--body "$BODY_OR_FILE")
  fi
else
  ARGS+=(--body "")
fi

if [ -n "$LABELS" ]; then
  ARGS+=(--label "$LABELS")
fi

gh "${ARGS[@]}"
