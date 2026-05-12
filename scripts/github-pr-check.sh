#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

PR_NUMBER="${1:-}"

require_gh
REPO="$(resolve_gh_repo)"

if [ -n "$PR_NUMBER" ]; then
  gh pr checks "$PR_NUMBER" --repo "$REPO"
else
  gh pr checks --repo "$REPO"
fi
