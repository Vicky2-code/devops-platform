#!/usr/bin/env bash
# Shared helpers: validators, path checks, git helpers.

# Validate a project name: lowercase letters, digits, dashes; no slashes/spaces.
is_valid_project_name() {
  [[ "$1" =~ ^[a-z0-9][a-z0-9-]*$ ]]
}

# Ensure a target directory is writable, create it if needed.
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir" || die "Cannot create directory: $dir"
  fi
}

# Ensure a file exists (touch it).
ensure_file() {
  local file="$1"
  local dir
  dir="$(dirname "$file")"
  ensure_dir "$dir"
  [[ -f "$file" ]] || touch "$file"
}

# Confirm a string is non-empty.
require_non_empty() {
  [[ -n "$2" ]] || die "Missing required value for '$1'"
}

# Detect the shell spawned a git identity so commits work.
git_identity_ok() {
  local name email
  name="$(git config --get user.name 2>/dev/null || true)"
  email="$(git config --get user.email 2>/dev/null || true)"
  [[ -n "$name" && -n "$email" ]]
}

# Human-friendly seconds formatting for status output.
human_seconds() {
  local s="$1"
  if (( s < 60 )); then printf "%ds" "$s";
  elif (( s < 3600 )); then printf "%dm%ds" $((s/60)) $((s%60));
  else printf "%dh%dm" $((s/3600)) $(((s%3600)/60));
  fi
}