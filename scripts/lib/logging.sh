#!/usr/bin/env bash
# Logging helpers: success / info / warn / error with timestamps.
# Uses colors.sh which is sourced before this file.

log_info()    { printf "[%s] ${C_CYAN}INFO${C_RESET}   %s\n" "$(date +%H:%M:%S)" "$*"; }
log_success() { printf "[%s] ${C_GREEN}OK${C_RESET}     %s\n" "$(date +%H:%M:%S)" "$*"; }
log_warn()    { printf "[%s] ${C_YELLOW}WARN${C_RESET}   %s\n" "$(date +%H:%M:%S)" "$*"; }
log_error()   { printf "[%s] ${C_RED}ERROR${C_RESET}  %s\n" "$(date +%H:%M:%S)" "$*" >&2; }

# die: print error and exit with given code (default 1)
die() {
  local code="${2:-1}"
  log_error "$1"
  exit "$code"
}