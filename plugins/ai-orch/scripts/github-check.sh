#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/github-lib.sh"

require_gh

echo "[GITHUB] gh version:"
gh --version | head -n 1

echo
echo "[GITHUB] auth:"
if login="$(current_gh_account)"; then
  echo "Authenticated as: $login"
else
  echo "Authenticated token found, but active account lookup failed."
fi

if [ -n "${AI_GITHUB_ACCOUNT:-}" ]; then
  echo "Expected account:  $AI_GITHUB_ACCOUNT"
fi

echo
echo "[GITHUB] repository:"
resolve_gh_repo
