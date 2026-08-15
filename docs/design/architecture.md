# DevFlow — Architecture

## Overview

DevFlow is a layered DevOps automation platform. The guiding principle:
**automate repetitive DevOps workflows incrementally**, with every layer
verified before the next one is built.

```
┌──────────────────────────────────────────────────────────────────┐
│                         Browser / CLI                            │
│   scripts/devflow (Bash CLI)          React Dashboard (Vite)     │
└──────────────┬──────────────────────────────┬────────────────────┘
               │                              │
               │          ┌───────────────────▼───────────────────┐
               │          │              FastAPI (REST)            │
               │          │  /api/auth /projects /environments    │
               │          │  /deployments /jobs /users /health    │
               │          │  middleware: metrics + CORS + errors   │
               │          └───────────┬───────────────┬───────────┘
               │                      │               │
               │              JWT/bcrypt      Prometheus /metrics
               │                      │               │
               └──────────────┬───────▼───────────────▼──────┐
                              │   SQLAlchemy                   │
                              │  ▾ PostgreSQL (prod)           │
                              │  ▾ SQLite (dev/tests)          │
                              └───────────────────────────────┘

                 Containerized with Docker Compose (Phase 6)
                 Orchestrated with ECS/Terraform or K8s (Phases 8-10)
                 Observed with Prometheus + Grafana (Phase 11)
```

## Components

### 1. CLI (`scripts/devflow`)
- Dispatcher source-sources `lib/` modules and command modules.
- Reads persisted config from `~/.config/devflow/config.env`.
- `deploy` falls back to a local simulated pipeline when the API is offline,
  and triggers a real job when the backend is reachable.

### 2. Backend (`backend/`)
- **FastAPI** app with routers separated by resource.
- **Auth:** JWT HS256; passwords hashed with bcrypt (`app/security.py`).
- **DB:** SQLAlchemy 2.0 declarative models; session injected via dependencies.
  Default `DATABASE_URL=sqlite:///./devflow.db`; prod uses Postgres.
- **Deployments:** creating one starts a background thread that runs a 7-stage
  pipeline (`clone → build → test → scan → push → rollout → healthcheck`),
  persisting logs and final status. ~10% simulated scan failures exercise the
  failure path.
- **Metrics:** `prometheus_client` registry exposed at `/api/metrics`.

### 3. Frontend (`frontend/`)
- React SPA built with Vite. `src/api.js` wraps the REST backend with a Bearer
  token from localStorage.
- Pages: Login/Register, Dashboard, Projects, Project detail (environments +
  deployments + logs), Automation Jobs, Health.
- Production build served by nginx which proxies `/api/` to the backend.

### 4. Infrastructure
- **Docker:** three containers (postgres, backend, frontend) on one network;
  postgres health-gated so the backend waits for the DB.
- **Terraform (AWS):** `networking` (VPC/3-tier), `database` (RDS, private),
  `compute` (ECS Fargate + ALB). See `infra/terraform/`.
- **Kubernetes:** manifests for deployments/services/ingress/HPA with
  readiness + liveness probes.

### 5. Observability
- Backend exposes Prometheus metrics (request rate, latency histogram, error
  ratio inferred from status codes, deployment/job counters).
- Prometheus scrapes backend; Grafana renders the DevFlow dashboard; alert
  rules fire on down/error/latency/failed-deploys/CPU.

## Data Model

```
User 1───* Project 1───* Environment
              │
              └───* Deployment (optional environment link)
Job (standalone; optional project link)
```

All ownership checks in the API restrict access to the authenticated user's
own resources (project → owner).

## Security Model

- Passwords: bcrypt (72-byte truncation handled).
- Tokens: JWT signed with `SECRET_KEY` (env). Expires after
  `ACCESS_TOKEN_EXPIRE_MINUTES`.
- CORS allow-list from env.
- No credentials hardcoded; `.env` and `*.tfvars` are gitignored.
- nginx adds security headers; CI runs trivy scans + ruff/eslint.

## Deploy Pipeline (CI)

```
push → lint (ruff/eslint/shellcheck)
     → test (pytest + CLI smoke)
     → build (vite)
     → docker build (backend, frontend)
     → trivy scan → push to GHCR
     → deploy stub → health check ($DEPLOY_URL)
```