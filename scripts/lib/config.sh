#!/usr/bin/env bash
# devflow CLI configuration stored in ~/.config/devflow/config.env
# Simple, human-editable key=value file.

CONFIG_DIR="${DEVELOW_CONFIG_DIR:-$HOME/.config/devflow}"
CONFIG_FILE="$CONFIG_DIR/config.env"

ensure_config() {
  ensure_dir "$CONFIG_DIR"
  if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<'EOF'
# devflow CLI configuration
AUTHOR=""
DEFAULT_BRANCH=main
REMOTE_PREFIX=origin
CREATE_GIT=true
CREATE_README=true
EOF
    log_info "Created default config at $CONFIG_FILE"
  fi
}

config_get() {
  ensure_config
  local key="$1"
  grep -E "^$key=" "$CONFIG_FILE" 2>/dev/null | head -n1 | cut -d= -f2-
}

config_set() {
  ensure_config
  local key="$1" value="$2"
  if grep -qE "^$key=" "$CONFIG_FILE"; then
    # POSIX-safe in-place edit via temp file
    sed -E "s|^$key=.*|$key=$value|" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" \
      && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >> "$CONFIG_FILE"
  fi
  log_success "Set $key"
}