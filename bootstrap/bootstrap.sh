#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh — legacy interactive scaffolder
#
# Kept as the educational Day 1-10 artifact. The current supported entrypoint
# is `scripts/devflow` with subcommands. This script wraps `devflow bootstrap`.
# ============================================================================

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../scripts/devflow" bootstrap "$@"
exit $?