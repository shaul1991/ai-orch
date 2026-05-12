#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

STATE="${1:-open}"
LIMIT="${GH_PR_LIMIT:-20}"

require_gh
REPO="$(resolve_gh_repo)"

gh pr list --repo "$REPO" --state "$STATE" --limit "$LIMIT"
