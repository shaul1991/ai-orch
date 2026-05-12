#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_POLICY="$PROJECT_ROOT/ai-orch.protect"
LOCAL_DENY_POLICY="$PROJECT_ROOT/.ai-orch/protect.local"
LOCAL_ALLOW_POLICY="$PROJECT_ROOT/.ai-orch/protect.allow.local"

if [ "${AI_PROTECT_IGNORE_LOCAL:-}" = "1" ]; then
  LOCAL_DENY_POLICY=""
  LOCAL_ALLOW_POLICY=""
fi

usage() {
  cat <<'EOF_USAGE'
Usage:
  scripts/ai-protect.sh list
  scripts/ai-protect.sh check-read <path...>
  scripts/ai-protect.sh check-write <path...>
  scripts/ai-protect.sh check-command <command...>
  scripts/ai-protect.sh allow-read <path>
  scripts/ai-protect.sh allow-write <path>
  scripts/ai-protect.sh allow-readwrite <path>
  scripts/ai-protect.sh revoke <path>

Notes:
  Shared policy: ai-orch.protect
  Local deny policy: .ai-orch/protect.local
  Local user-confirmed allow policy: .ai-orch/protect.allow.local
EOF_USAGE
}

trim() {
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

normalize_path() {
  local path="$1"

  path="${path%/}"
  path="${path#\"}"
  path="${path%\"}"
  path="${path#\'}"
  path="${path%\'}"

  case "$path" in
    "$PROJECT_ROOT")
      path="."
      ;;
    "$PROJECT_ROOT"/*)
      path="${path#"$PROJECT_ROOT"/}"
      ;;
  esac

  while [ "${path#./}" != "$path" ]; do
    path="${path#./}"
  done

  printf '%s\n' "$path"
}

parse_policy_line() {
  local line="$1"
  local action pattern

  line="${line%%#*}"
  line="$(printf '%s' "$line" | trim)"
  [ -n "$line" ] || return 1

  action="${line%%[[:space:]]*}"

  case "$action" in
    allow|deny)
      pattern="${line#"$action"}"
      pattern="$(printf '%s' "$pattern" | trim)"
      ;;
    *)
      action="deny"
      pattern="$line"
      ;;
  esac

  [ -n "$pattern" ] || return 1
  printf '%s\t%s\n' "$action" "$pattern"
}

match_policy_file() {
  local file="$1"
  local wanted_action="$2"
  local path="$3"
  local source="$4"
  local parsed action pattern

  [ -f "$file" ] || return 1

  while IFS= read -r line || [ -n "$line" ]; do
    if ! parsed="$(parse_policy_line "$line")"; then
      continue
    fi

    action="${parsed%%$'\t'*}"
    pattern="${parsed#*$'\t'}"

    [ "$action" = "$wanted_action" ] || continue

    if [[ "$path" == $pattern ]]; then
      printf '%s:%s %s\n' "$source" "$action" "$pattern"
      return 0
    fi
  done < "$file"

  return 1
}

local_allow_match() {
  local wanted_mode="$1"
  local path="$2"
  local mode allowed_path

  [ -f "$LOCAL_ALLOW_POLICY" ] || return 1

  while IFS=$'\t' read -r mode allowed_path || [ -n "${mode:-}" ]; do
    mode="${mode%%#*}"
    mode="$(printf '%s' "$mode" | trim)"
    allowed_path="$(printf '%s' "${allowed_path:-}" | trim)"

    [ -n "$mode" ] || continue
    [ -n "$allowed_path" ] || continue
    [ "$allowed_path" = "$path" ] || continue

    case "$wanted_mode:$mode" in
      read:read|read:readwrite|write:write|write:readwrite)
        printf '%s\n' ".ai-orch/protect.allow.local:$mode $allowed_path"
        return 0
        ;;
    esac
  done < "$LOCAL_ALLOW_POLICY"

  return 1
}

protected_match() {
  local mode="$1"
  local path="$2"
  local match

  path="$(normalize_path "$path")"

  if match="$(match_policy_file "$LOCAL_DENY_POLICY" deny "$path" ".ai-orch/protect.local")"; then
    printf '%s\n' "$match"
    return 0
  fi

  if local_allow_match "$mode" "$path" >/dev/null; then
    return 1
  fi

  if match="$(match_policy_file "$SHARED_POLICY" allow "$path" "ai-orch.protect")"; then
    return 1
  fi

  if match="$(match_policy_file "$SHARED_POLICY" deny "$path" "ai-orch.protect")"; then
    printf '%s\n' "$match"
    return 0
  fi

  return 1
}

check_path() {
  local mode="$1"
  local path="$2"
  local normalized match allow_command

  normalized="$(normalize_path "$path")"

  if match="$(protected_match "$mode" "$normalized")"; then
    case "$mode" in
      read)
        allow_command="scripts/ai-orch.sh protect allow-read $normalized"
        ;;
      write)
        allow_command="scripts/ai-orch.sh protect allow-write $normalized"
        ;;
      *)
        allow_command="scripts/ai-orch.sh protect allow-readwrite $normalized"
        ;;
    esac

    echo "[AI_PROTECT_BLOCKED] $mode denied: $normalized"
    echo "Matched: $match"
    echo "After human confirmation, allow locally with:"
    echo "  $allow_command"
    return 1
  fi

  return 0
}

check_paths() {
  local mode="$1"
  shift

  if [ "$#" -eq 0 ]; then
    echo "[AI_PROTECT_FAILED] $mode check requires at least one path."
    usage
    return 1
  fi

  for path in "$@"; do
    check_path "$mode" "$path"
  done

  echo "[AI_PROTECT_PASSED] $mode path check passed."
}

strip_token() {
  local token="$1"

  token="$(printf '%s' "$token" | sed 's/^[[:space:];|&()<>]*//; s/[[:space:];|&()<>]*$//')"
  token="${token#\"}"
  token="${token%\"}"
  token="${token#\'}"
  token="${token%\'}"
  printf '%s\n' "$token"
}

is_path_like_token() {
  local token="$1"

  case "$token" in
    ""|-*)
      return 1
      ;;
    ./*|../*|/*|~/*|.*|*/*|*.*|id_rsa|id_dsa|id_ecdsa|id_ed25519)
      return 0
      ;;
  esac

  return 1
}

command_mode() {
  local command="${1:-}"

  case "$command" in
    rm|rmdir|mv|cp|install|touch|chmod|chown|chgrp|truncate|tee|ed|ex|vi|vim|nvim|nano|emacs)
      echo "write"
      ;;
    *)
      echo "read"
      ;;
  esac
}

check_command_token() {
  local mode="$1"
  local token="$2"
  local candidate rhs

  candidate="$(strip_token "$token")"
  [ -n "$candidate" ] || return 0

  if is_path_like_token "$candidate"; then
    check_path "$mode" "$candidate"
    return
  fi

  if [[ "$candidate" == *=* ]]; then
    rhs="${candidate#*=}"
    rhs="$(strip_token "$rhs")"
    if is_path_like_token "$rhs"; then
      check_path "$mode" "$rhs"
    fi
  fi
}

check_command() {
  local mode
  local arg token

  if [ "$#" -eq 0 ]; then
    echo "[AI_PROTECT_FAILED] check-command requires a command."
    usage
    return 1
  fi

  mode="$(command_mode "$1")"

  for arg in "$@"; do
    check_command_token "$mode" "$arg"
    for token in $arg; do
      check_command_token "$mode" "$token"
    done
  done

  echo "[AI_PROTECT_PASSED] command path check passed."
}

register_allow() {
  local mode="$1"
  local path="$2"
  local normalized existing_mode existing_path

  normalized="$(normalize_path "$path")"
  mkdir -p "$(dirname "$LOCAL_ALLOW_POLICY")"
  touch "$LOCAL_ALLOW_POLICY"

  while IFS=$'\t' read -r existing_mode existing_path || [ -n "${existing_mode:-}" ]; do
    existing_mode="$(printf '%s' "${existing_mode:-}" | trim)"
    existing_path="$(printf '%s' "${existing_path:-}" | trim)"
    if [ "$existing_mode" = "$mode" ] && [ "$existing_path" = "$normalized" ]; then
      echo "[AI_PROTECT_ALLOW_EXISTS] $mode $normalized"
      return 0
    fi
  done < "$LOCAL_ALLOW_POLICY"

  printf '%s\t%s\n' "$mode" "$normalized" >> "$LOCAL_ALLOW_POLICY"
  echo "[AI_PROTECT_ALLOW_ADDED] $mode $normalized"
}

revoke_allow() {
  local path="$1"
  local normalized tmp

  normalized="$(normalize_path "$path")"
  [ -f "$LOCAL_ALLOW_POLICY" ] || {
    echo "[AI_PROTECT_REVOKE_SKIPPED] no local allow policy."
    return 0
  }

  tmp="${LOCAL_ALLOW_POLICY}.tmp.$$"
  : > "$tmp"

  while IFS=$'\t' read -r mode allowed_path || [ -n "${mode:-}" ]; do
    allowed_path="$(printf '%s' "${allowed_path:-}" | trim)"
    if [ "$allowed_path" != "$normalized" ]; then
      printf '%s\t%s\n' "$mode" "$allowed_path" >> "$tmp"
    fi
  done < "$LOCAL_ALLOW_POLICY"

  mv "$tmp" "$LOCAL_ALLOW_POLICY"
  echo "[AI_PROTECT_REVOKED] $normalized"
}

print_list() {
  echo "Shared policy: $SHARED_POLICY"
  if [ -f "$SHARED_POLICY" ]; then
    sed -n '1,220p' "$SHARED_POLICY"
  else
    echo "[AI_PROTECT_WARN] shared policy does not exist."
  fi

  echo
  echo "Local deny policy: $LOCAL_DENY_POLICY"
  if [ -f "$LOCAL_DENY_POLICY" ]; then
    sed -n '1,220p' "$LOCAL_DENY_POLICY"
  else
    echo "[AI_PROTECT_INFO] no local deny policy."
  fi

  echo
  echo "Local user-confirmed allow policy: $LOCAL_ALLOW_POLICY"
  if [ -f "$LOCAL_ALLOW_POLICY" ]; then
    sed -n '1,220p' "$LOCAL_ALLOW_POLICY"
  else
    echo "[AI_PROTECT_INFO] no local allow policy."
  fi
}

ACTION="${1:-list}"
if [ "$#" -gt 0 ]; then
  shift
fi

case "$ACTION" in
  list)
    print_list
    ;;
  check-read)
    check_paths read "$@"
    ;;
  check-write)
    check_paths write "$@"
    ;;
  check-command)
    check_command "$@"
    ;;
  allow-read)
    [ "${1:-}" ] || {
      echo "[AI_PROTECT_FAILED] allow-read requires <path>."
      usage
      exit 1
    }
    register_allow read "$1"
    ;;
  allow-write)
    [ "${1:-}" ] || {
      echo "[AI_PROTECT_FAILED] allow-write requires <path>."
      usage
      exit 1
    }
    register_allow write "$1"
    ;;
  allow-readwrite)
    [ "${1:-}" ] || {
      echo "[AI_PROTECT_FAILED] allow-readwrite requires <path>."
      usage
      exit 1
    }
    register_allow readwrite "$1"
    ;;
  revoke)
    [ "${1:-}" ] || {
      echo "[AI_PROTECT_FAILED] revoke requires <path>."
      usage
      exit 1
    }
    revoke_allow "$1"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "[AI_PROTECT_FAILED] Unknown action: $ACTION"
    usage
    exit 1
    ;;
esac
