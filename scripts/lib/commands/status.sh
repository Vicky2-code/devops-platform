#!/usr/bin/env bash
# devflow status — show what's running locally (api, docker, git state).

main() {
  bold "devflow status"
  echo

  local state="stopped"
  if curl -fsS --max-time 2 "http://localhost:8000/api/health" >/dev/null 2>&1; then
    state="running"
  fi
  if [[ "$state" == "running" ]]; then
    printf "  backend api   : %s\n" "$(green running)"
  else
    printf "  backend api   : %s\n" "$(red stopped)"
  fi

  local dstate="not installed"
  if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then dstate="running"; else dstate="installed (stopped)"; fi
  fi
  if [[ "$dstate" == "running" ]]; then
    printf "  docker        : %s\n" "$(green "$dstate")"
  else
    printf "  docker        : %s\n" "$(yellow "$dstate")"
  fi

  echo
  printf "  git branch    : %s\n" "$(git branch --show-current 2>/dev/null || echo n/a)"
  printf "  last commit   : %s\n" "$(git log -1 --oneline 2>/dev/null || echo n/a)"
  echo
  log_success "Status check complete."
}