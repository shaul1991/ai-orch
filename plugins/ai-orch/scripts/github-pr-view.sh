#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

PR_NUMBER="${1:-}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: scripts/github-pr-view.sh <pr-number>"
  exit 1
fi

require_gh
REPO="$(resolve_gh_repo)"

gh pr view "$PR_NUMBER" --repo "$REPO" --comments
