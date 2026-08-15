#!/usr/bin/env bash
# devflow config — view/set CLI configuration stored in ~/.config/devflow/config.env

config_usage() {
  cat <<'EOF'
USAGE:
  devflow config show          Print current configuration
  devflow config set <key> <value>   Set a configuration value

KEYS: AUTHOR, AUTHOR_EMAIL, DEFAULT_BRANCH, CREATE_GIT, CREATE_README
EOF
}

main() {
  local op="${1:-}"

  case "$op" in
    show)
      ensure_config
      echo "Config file: $CONFIG_FILE"
      echo
      cat "$CONFIG_FILE"
      ;;
    set)
      local key="${2:-}" value="${3:-}"
      [[ -n "$key" && -n "$value" ]] || { config_usage; die "Usage: devflow config set <key> <value>"; }
      case "$key" in
        AUTHOR|AUTHOR_EMAIL|DEFAULT_BRANCH|CREATE_GIT|CREATE_README) ;;
        *) die "Unknown key '$key'. See devflow config show." ;;
      esac
      config_set "$key" "$value"
      ;;
    *)
      config_usage
      return 1
      ;;
  esac
}