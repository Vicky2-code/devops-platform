#!/usr/bin/env bash
# devflow doctor — check that the environment has what devflow needs.

main() {
  local fail=0

  bold "devflow doctor — environment check"
  echo

  check_cmd() {
    local name="$1" bin="${2:-$1}"
    if command -v "$bin" >/dev/null 2>&1; then
      green "  ✓ $name ($(command -v "$bin"))"
    else
      red "  ✗ $name — not found"
      fail=1
    fi
  }

  check_cmd "git"
  check_cmd "bash"
  check_cmd "curl"
  check_cmd "docker"
  check_cmd "python3" python3

  echo
  if [[ $fail -eq 0 ]]; then
    green "All required tools present. You are ready to deploy."
    return 0
  else
    yellow "Some tools are missing. Install them to unlock all commands."
    return 1
  fi
}