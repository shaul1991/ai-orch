#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/load-env.sh"
load_project_env "$PROJECT_ROOT"

require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "[GITHUB_FAILED] GitHub CLI is not installed. Install it with: brew install gh"
    exit 1
  fi

  if ! gh auth token >/dev/null 2>&1; then
    echo "[GITHUB_FAILED] GitHub CLI is not authenticated. Run: gh auth login"
    exit 1
  fi

  require_expected_gh_account
}

current_gh_account() {
  local status
  status="$(gh auth status 2>&1 || true)"

  printf '%s\n' "$status" | awk '
    / account / {
      login = $0
      sub(/^.* account /, "", login)
      sub(/[[:space:](].*$/, "", login)
    }
    /Active account: true/ {
      print login
      found = 1
      exit
    }
    END {
      if (!found) {
        exit 1
      }
    }
  '
}

require_expected_gh_account() {
  if [ -z "${AI_GITHUB_ACCOUNT:-}" ]; then
    return 0
  fi

  local login
  if ! login="$(current_gh_account)"; then
    echo "[GITHUB_FAILED] GitHub CLI is authenticated, but active account lookup failed." >&2
    echo "Run: gh auth status" >&2
    exit 1
  fi

  if [ "$login" != "$AI_GITHUB_ACCOUNT" ]; then
    echo "[GITHUB_FAILED] Active GitHub account mismatch." >&2
    echo "Expected: $AI_GITHUB_ACCOUNT" >&2
    echo "Actual:   $login" >&2
    echo "Run: gh auth switch --user $AI_GITHUB_ACCOUNT" >&2
    exit 1
  fi
}

resolve_repo_from_origin() {
  local remote repo

  if ! remote="$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null)"; then
    return 1
  fi

  case "$remote" in
    https://github.com/*)
      repo="${remote#https://github.com/}"
      ;;
    http://github.com/*)
      repo="${remote#http://github.com/}"
      ;;
    git@github.com:*)
      repo="${remote#git@github.com:}"
      ;;
    ssh://git@github.com/*)
      repo="${remote#ssh://git@github.com/}"
      ;;
    *)
      return 1
      ;;
  esac

  repo="${repo%.git}"

  if [ -z "$repo" ] || [ "$repo" = "$remote" ]; then
    return 1
  fi

  echo "$repo"
}

resolve_gh_repo() {
  if [ -n "${AI_GITHUB_REPO:-}" ]; then
    echo "$AI_GITHUB_REPO"
    return 0
  fi

  if repo="$(resolve_repo_from_origin)"; then
    echo "$repo"
    return 0
  fi

  if repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"; then
    echo "$repo"
    return 0
  fi

  echo "[GITHUB_FAILED] Could not resolve GitHub repository." >&2
  echo "Set AI_GITHUB_REPO=owner/repo in .ai-orch/setting.local.json or add an origin remote." >&2
  exit 1
}
