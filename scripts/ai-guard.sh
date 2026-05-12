#!/usr/bin/env bash
set -euo pipefail

COMMAND="$*"

FORBIDDEN_PATTERNS=(
  "git merge"
  "gh pr merge"
  "git push --force"
  "kubectl apply"
  "terraform apply"
  "serverless deploy"
  "npm publish"
  "composer publish"
  "php artisan migrate:rollback"
  "php artisan db:wipe"
)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "[AI_GUARD_BLOCKED] Forbidden command: $pattern"
    exit 1
  fi
done

exec "$@"
