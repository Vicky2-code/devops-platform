#!/usr/bin/env bash
# devflow bootstrap — interactive scaffolding (Day 4-9 legacy flow)
# Prompts for project + author, validates input, creates structure,
# initializes git only when confirmed.

main() {
  local project author confirm

  cyan "┌──────────────────────────────────────────┐"
  cyan "│  devflow bootstrap — interactive setup    │"
  cyan "└──────────────────────────────────────────┘"

  # Prompt: project name
  while :; do
    read -rp "Project Name (lowercase, dashes ok): " project
    if is_valid_project_name "$project"; then
      break
    fi
    log_warn "Invalid. Use lowercase letters, digits, and dashes only."
  done

  # Prompt: author name (may be empty)
  read -rp "Author Name [$(config_get AUTHOR)]: " author
  [[ -z "$author" ]] && author="$(config_get AUTHOR)"

  # Prompt: confirm
  read -rp "Create project '$project' by '${author:-n/a}'? [y/N]: " confirm
  if [[ "${confirm,,}" != "y" ]]; then
    log_warn "Aborted by user."
    return 1
  fi

  # Reuse the init module's builders
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/lib/commands/init.sh"

  if [[ -d "$project" ]]; then
    die "Directory '$project' already exists."
  fi

  create_tree "$project" || die "Failed to create tree"
  generate_readme    "$project" "$project" "$author" || die "Failed README"
  generate_gitignore "$project" || die "Failed .gitignore"
  generate_license   "$project" "$author" || die "Failed LICENSE"
  chmod +x "$project/scripts/say-hello.sh" 2>/dev/null || true

  # Git init — ask to be safe (never touch parent repo).
  read -rp "Initialize a Git repository inside the project? [y/N]: " confirm
  if [[ "${confirm,,}" == "y" ]]; then
    ( cd "$project" && git init -b main >/dev/null 2>&1 && git add . && \
      git -c user.name="${author:-devflow}" \
          -c user.email="$(config_get AUTHOR_EMAIL 2>/dev/null || echo dev@devflow.local)" \
          commit -q -m "feat: scaffold project $project" )
    log_success "Git initialized (branch: main)."
  else
    log_info "Skipped git init."
  fi

  green "Done. Next: cd $project && code ."
}