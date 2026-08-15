#!/usr/bin/env bash
# devflow init <name> — scaffold a new project (non-interactive)

init_usage() {
  cat <<'EOF'
USAGE: devflow init <project-name>

Scaffolds a standard project structure:
  assets/  docs/  scripts/  src/  tests/  README.md  .gitignore  LICENSE
then initializes a Git repository on the main branch.
EOF
}

# Create the project directory tree.
create_tree() {
  local root="$1"
  for d in assets docs scripts src tests; do
    ensure_dir "$root/$d"
  done
  log_success "Created directory tree under $root"
}

# Generate a README with the project metadata.
generate_readme() {
  local root="$1" name="$2" author="$3"
  cat > "$root/README.md" <<EOF
# $name

Scaffolded by devflow CLI.

- Author: ${author:-n/a}
- Branch: $(git config --get init.defaultbranch 2>/dev/null || echo main)

## Structure

- \`assets/\`  — static assets
- \`docs/\`    — documentation
- \`scripts/\` — automation scripts
- \`src/\`     — source code
- \`tests/\`   — tests
EOF
  log_success "Generated README.md"
}

# Generate a sensible .gitignore.
generate_gitignore() {
  local root="$1"
  cat > "$root/.gitignore" <<'EOF'
__pycache__/
node_modules/
.venv/
dist/
build/
*.log
.env
EOF
  log_success "Generated .gitignore"
}

# Generate an MIT LICENSE with the author name.
generate_license() {
  local root="$1" author="${2:-Your Name}"
  local year
  year="$(date +%Y)"
  cat > "$root/LICENSE" <<EOF
MIT License

Copyright (c) $year $author

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
EOF
  log_success "Generated LICENSE"
}

main() {
  local name="${1:-}"
  local author

  if [[ -z "$name" ]]; then
    init_usage
    die "Project name is required: devflow init <project-name>"
  fi

  if ! is_valid_project_name "$name"; then
    die "Invalid project name '$name'. Use lowercase letters, digits, dashes only."
  fi

  if [[ -d "$name" ]]; then
    die "Directory '$name' already exists. Choose another name."
  fi

  author="$(config_get AUTHOR)"

  log_info "Scaffolding project '$name' ..."

  # Build the tree first, then files, then git. Stops on first failure.
  create_tree "$name" || die "Failed to create tree"
  generate_readme   "$name" "$name" "$author" || die "Failed to generate README"
  generate_gitignore "$name" || die "Failed to generate .gitignore"
  generate_license  "$name" "$author" || die "Failed to generate LICENSE"

  # Create a seed script so scripts/ is not empty.
  cat > "$name/scripts/say-hello.sh" <<EOF
#!/usr/bin/env bash
echo "Hello from $name!"
EOF
  chmod +x "$name/scripts/say-hello.sh"

  log_success "Project '$name' scaffolded."

  # Initialize Git inside the new project, not the parent.
  (
    cd "$name" || exit 1
    git init -b main >/dev/null 2>&1
    git add .
    git -c user.name="${author:-devflow}" \
        -c user.email="$(config_get AUTHOR_EMAIL 2>/dev/null || echo dev@devflow.local)" \
        commit -q -m "feat: scaffold project $name"
    log_success "Git repository initialized (branch: main) with initial commit."
  )

  show_summary "$name"
}

show_summary() {
  local name="$1"
  bold "──────────────────────────────"
  green "  Project created: $name"
  green "  Next: cd $name && code ."
  bold "──────────────────────────────"
}