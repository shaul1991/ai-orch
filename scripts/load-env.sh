#!/usr/bin/env bash

load_env_file() {
  local env_file="$1"

  if [ ! -f "$env_file" ]; then
    return 0
  fi

  local line key value

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    if [ -z "$line" ] || [[ "$line" == \#* ]]; then
      continue
    fi

    if [[ "$line" == export\ * ]]; then
      line="${line#export }"
    fi

    if [[ "$line" != *=* ]]; then
      continue
    fi

    key="${line%%=*}"
    value="${line#*=}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      continue
    fi

    if [[ "$key" != AI_* ]]; then
      continue
    fi

    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
      value="${value:1:${#value}-2}"
    elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
      value="${value:1:${#value}-2}"
    fi

    if [ -z "${!key+x}" ]; then
      export "$key=$value"
    fi
  done < "$env_file"
}

load_json_settings_file() {
  local settings_file="$1"
  local line key value

  if [ ! -f "$settings_file" ]; then
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "[AI_ENV_FAILED] jq is required to read $settings_file" >&2
    return 1
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    key="${line%%=*}"
    value="${line#*=}"

    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      continue
    fi

    if [[ "$key" != AI_* ]]; then
      continue
    fi

    if [ -z "${!key+x}" ]; then
      export "$key=$value"
    fi
  done < <(jq -r 'to_entries[] | select(.value != null) | "\(.key)=\(.value|tostring)"' "$settings_file")
}

load_project_env() {
  local project_root="${1:-$PWD}"

  if [ -f "$project_root" ]; then
    load_env_file "$project_root"
    return
  fi

  load_json_settings_file "$project_root/.ai-orch/setting.local.json"
  load_json_settings_file "$project_root/.ai-orch/setting.json"
}
