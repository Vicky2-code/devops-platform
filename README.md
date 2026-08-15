# DevFlow — DevOps Automation Platform

> **Temporary working name:** `devflow` (placeholder brand — easy to rename, see `docs/design/naming.md`).

DevFlow is a full-stack DevOps automation platform that automates the repetitive work developers face when setting up projects, environments, containers, CI/CD pipelines, and deployments.

It is built incrementally — from a Bash bootstrap tool to a SaaS-style platform — so every layer is real, tested, and deployed. Nothing here is stubbed.

---

## Problem

Developers repeatedly spend time manually setting up:

- Project structures & standard files
- Git repositories
- Environments (dev / staging / prod)
- Containers and Docker configuration
- CI/CD pipelines
- Cloud infrastructure
- Deployments
- Monitoring & alerting

## Solution

DevFlow automates those workflows in layers:

1. **CLI** (Bash) — scaffolds projects, initializes Git, runs doctor checks, config commands, simulated deploys
2. **Backend REST API** (FastAPI) — Projects, Environments, Deployments, Automation Jobs, Users + JWT auth
3. **Frontend dashboard** (React) — view and control deployments/jobs
4. **Docker + Compose** — containerize everything with health checks, networks, volumes
5. **CI/CD** (GitHub Actions) — lint, test, build, scan, push, deploy, health check
6. **Infrastructure as Code** (Terraform) — AWS VPC, RDS, ECS
7. **Kubernetes** — deployments, services, ingress, HPA, probes
8. **Observability** — Prometheus + Grafana metrics, dashboards, alert rules

---

## Tech Stack

| Layer        | Technology                                      |
| ------------ | ----------------------------------------------- |
| CLI          | Bash 5 (POSIX-style scripting)                  |
| Backend      | Python 3.14, FastAPI, SQLAlchemy, Pydantic      |
| Auth         | JWT (Bearer tokens), bcrypt                     |
| Database     | PostgreSQL (SQLite for local dev/tests)         |
| Frontend     | React 18, Vite, plain CSS                       |
| Containers   | Docker, docker-compose                          |
| CI/CD        | GitHub Actions                                  |
| IaC / Cloud  | Terraform, AWS (VPC / RDS / ECS / ALB / S3)     |
| Kubernetes   | Deployments, Services, Ingress, HPA, ConfigMaps |
| Observability| Prometheus, Grafana, health checks, alerts      |

---

## Repository Layout

```
.
├── bootstrap/         # Day 1-10: interactive project scaffolder (bash)
├── scripts/           # devflow CLI library + entrypoint
├── backend/           # FastAPI REST API + tests
├── frontend/          # React dashboard
├── infra/terraform/   # AWS infrastructure as code
├── k8s/               # Kubernetes manifests
├── observability/     # Prometheus + Grafana config
├── .github/workflows/ # CI/CD pipelines
├── docs/              # design, roadmap, changelog, daily notes
└── portfolio/         # case study, resume bullets, interview prep
```

---

## Prerequisites

- WSL2 + Ubuntu (or any Linux)
- Bash 5+, Git 2.30+
- Python 3.11+ (3.14 tested)
- Node.js 18+ (for frontend)
- Docker + Docker Compose (optional, for containerized run)
- Terraform, kubectl (for infra phases)

## Quick Start (local dev)

```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
# API docs: http://localhost:8000/docs
```

Frontend:

```bash
cd frontend
npm install
npm run dev
```

Full stack with Docker:

```bash
docker compose up --build
# frontend:  http://localhost:3000
# backend:   http://localhost:8000/docs
# prometheus:http://localhost:9090
# grafana:   http://localhost:3001
```

Run the CLI:

```bash
./scripts/devflow doctor
./scripts/devflow init my-project
./scripts/devflow config show
```

---

## API Overview

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| POST   | `/api/auth/register` | Create user |
| POST   | `/api/auth/login`    | Login → JWT |
| GET    | `/api/health`        | Service health |
| GET    | `/api/metrics`       | Prometheus metrics |
| CRUD   | `/api/projects`      | Projects |
| CRUD   | `/api/projects/{id}/environments` | Environments |
| CRUD   | `/api/projects/{id}/deployments`  | Deployments |
| POST   | `/api/projects/{id}/deployments/{d}/trigger` | Trigger a deploy job |
| CRUD   | `/api/jobs`          | Automation jobs |
| GET    | `/api/users/me`      | Current user |

Full docs auto-generated at `/docs` (Swagger UI).

---

## CI/CD Pipeline

See `.github/workflows/ci.yml`. Stages:

```
Push → lint → test → build frontend → docker build → security scan (trivy)
     → push image (GHCR) → deploy → health check
```

## Deployment

- AWS via Terraform (`infra/terraform/`) — VPC, subnets, RDS, ECS Fargate, ALB
- Kubernetes manifests in `k8s/` for an EKS alternative
- See `docs/design/architecture.md` and `portfolio/case-study.md`

---

## Documentation

- Architecture: `docs/design/architecture.md`
- Roadmap: `docs/planning/roadmap.md`
- Changelog: `docs/release/changelog.md`
- Daily notes: `docs/daily/`

---

## License

MIT — see `LICENSE`.