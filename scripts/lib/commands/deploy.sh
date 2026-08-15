#!/usr/bin/env bash
# devflow deploy <target> — simulate a deployment against the local backend.
# Calls POST /api/projects/{id}/deployments or /api/jobs if backend is up;
# otherwise falls back to a local simulated pipeline (no cloud needed).

DEPLOY_TARGETS=(dev staging prod)

deploy_usage() {
  cat <<'EOF'
USAGE: devflow deploy <dev|staging|prod>

Simulates a deployment pipeline for the target environment:
  clone → build → test → image push → rollout → health check
EOF
}

# Check whether the devflow API is reachable.
api_up() {
  curl -fsS --max-time 2 "http://localhost:8000/api/health" >/dev/null 2>&1
}

# Simulate stage by stage with timing.
simulate_stage() {
  local stage="$1"
  log_info "Running stage: $stage"
  sleep $((RANDOM % 2 + 1))
  if (( RANDOM % 10 == 9 )); then
    log_error "Stage '$stage' failed (simulated random failure)."
    return 1
  fi
  log_success "Stage '$stage' passed."
  return 0
}

main() {
  local target="${1:-}"
  local started elapsed

  [[ -n "$target" ]] || { deploy_usage; die "Target environment required."; }
  if ! printf '%s\n' "${DEPLOY_TARGETS[@]}" | grep -qx "$target"; then
    die "Invalid target '$target'. Use one of: ${DEPLOY_TARGETS[*]}"
  fi

  bold "devflow deploy → $target"
  started="$(date +%s)"

  # Try hitting the API first for a real job record.
  if api_up; then
    log_info "Backend detected at localhost:8000 — creating automation job."
    curl -fsS -X POST "http://localhost:8000/api/jobs" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DEVFLOW_TOKEN" \
      -d "{\"name\":\"deploy-$target\",\"target_env\":\"$target\"}" \
      >/dev/null 2>&1 && log_success "Job created." || log_warn "Could not create job (auth?)."
  else
    log_warn "Backend not running — using local simulation."
    simulate_stage "clone repository" || exit 1
    simulate_stage "build artifacts"  || exit 1
    simulate_stage "run tests"        || exit 1
    simulate_stage "push image"       || exit 1
    simulate_stage "rollout $target"  || exit 1
    simulate_stage "health check"     || exit 1
  fi

  elapsed=$(( $(date +%s) - started ))
  green "Deployment to $target finished in $(human_seconds "$elapsed")."
}