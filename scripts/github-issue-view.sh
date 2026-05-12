#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

ISSUE_NUMBER="${1:-}"

if [ -z "$ISSUE_NUMBER" ]; then
  echo "Usage: scripts/github-issue-view.sh <issue-number>"
  exit 1
fi

require_gh
REPO="$(resolve_gh_repo)"

gh issue view "$ISSUE_NUMBER" --repo "$REPO" --comments
