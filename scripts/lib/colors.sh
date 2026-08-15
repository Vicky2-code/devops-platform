#!/usr/bin/env bash
# ANSI color + status message helpers
# Kept deliberately small; too many colors hurt readability.

# ---- color codes (only when stdout is a TTY) ----
if [[ -t 1 ]]; then
  C_RESET="\033[0m"
  C_BOLD="\033[1m"
  C_RED="\033[31m"
  C_GREEN="\033[32m"
  C_YELLOW="\033[33m"
  C_BLUE="\033[34m"
  C_CYAN="\033[36m"
else
  C_RESET=""
  C_BOLD=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_CYAN=""
fi

green()  { printf "${C_GREEN}%s${C_RESET}\n" "$*"; }
yellow() { printf "${C_YELLOW}%s${C_RESET}\n" "$*"; }
red()    { printf "${C_RED}%s${C_RESET}\n" "$*"; }
blue()   { printf "${C_BLUE}%s${C_RESET}\n" "$*"; }
cyan()   { printf "${C_CYAN}%s${C_RESET}\n" "$*"; }
bold()   { printf "${C_BOLD}%s${C_RESET}\n" "$*"; }