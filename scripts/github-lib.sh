#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT/.env"

require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "[GITHUB_FAILED] GitHub CLI is not installed. Install it with: brew install gh"
    exit 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "[GITHUB_FAILED] GitHub CLI is not authenticated. Run: gh auth login"
    exit 1
  fi
}

resolve_gh_repo() {
  if [ -n "${GH_REPO:-}" ]; then
    echo "$GH_REPO"
    return 0
  fi

  if repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"; then
    echo "$repo"
    return 0
  fi

  echo "[GITHUB_FAILED] Could not resolve GitHub repository." >&2
  echo "Set GH_REPO=owner/repo in .env or add an origin remote." >&2
  exit 1
}
