#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

require_gh

echo "[GITHUB] gh version:"
gh --version | head -n 1

echo
echo "[GITHUB] auth status:"
gh auth status

echo
echo "[GITHUB] repository:"
resolve_gh_repo
