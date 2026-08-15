# DevFlow — Portfolio Case Study

> DevOps Automation Platform — automating project scaffolding, environments,
> deployments, and monitoring for developers.

## Problem

Developers repeatedly spend time on the same bootstrapping chores: creating
project structures, initializing Git, wiring environments, containers, CI/CD,
cloud infra, and monitoring. This is slow, error-prone, and inconsistent.

## Solution

DevFlow automates those workflows in layers, built incrementally from a Bash
CLI all the way to a containerized, cloud-deployable, monitored platform.

## Architecture

```
Bash CLI ──► FastAPI REST API ──► SQLAlchemy ──► PostgreSQL
React SPA ──► /api (*JWT, CORS, metrics*)
Docker Compose (postgres, backend, frontend, monitoring)
Terraform → AWS (VPC, RDS, ECS Fargate, ALB)
Kubernetes (deployments, services, ingress, HPA, probes)
Prometheus + Grafana dashboards & alerts
GitHub Actions: lint → test → build → scan → push → deploy → healthcheck
```

## Tech Stack

Bash 5 · Python 3.14 · FastAPI · SQLAlchemy · Pydantic · JWT · bcrypt ·
PostgreSQL · React 18 · Vite · Docker · GitHub Actions · Terraform · AWS ·
Kubernetes · Prometheus · Grafana

## Key Features

- **Bash CLI** (`scripts/devflow`): `init`, `bootstrap`, `doctor`, `config`,
  `status`, `deploy` — with validation, exit codes, colored UX, git isolation.
- **REST API**: auth + CRUD for users, projects, environments, deployments,
  automation jobs; OpenAPI docs; health + Prometheus endpoints.
- **Automation**: creating a deployment runs a persisted 7-stage pipeline with
  logs and failure simulation; jobs for deploy/test/scan.
- **Dashboard**: React UI to manage projects, envs, deployments, jobs, health.
- **Infrastructure**: Terraform for VPC/RDS/ECS/ALB; K8s manifests with
  probes/HPA; containerized via Docker Compose with health checks.
- **Observability**: Prometheus metrics, Grafana dashboard, alert rules.
- **CI/CD**: full pipeline with lint, tests, build, container scans, push.

## Engineering Decisions (and why)

1. **Build bottom-up (Bash → API → UI → infra)** — each layer is testable and
   teaches a core DevOps concept before moving on.
2. **Simulated-but-persisted pipelines in the backend** — makes the automation
   platform testable locally without a live cloud, while keeping real DB state,
   statuses, and logs.
3. **SQLAlchemy with swappable DSN** — SQLite for dev/tests, Postgres in prod,
   same models/API.
4. **No credentials in code** — env vars, gitignored secrets, IAM roles, scoped
   security groups, container scanning in CI.
5. **Health-checked everything** — Dockerfile HEALTHCHECK, compose `condition:
   service_healthy`, K8s readiness/liveness, ALB target health checks, CI final
   healthcheck — so "deployed" is never claimed until verified.

## Challenges → Solutions

- **passlib/bcrypt incompatibility (Python 3.14)** → replaced passlib with the
  `bcrypt` library directly (72-byte truncation handled).
- **Cross-test DB pollution** → truncate tables between tests via an autouse
  fixture (isolation).
- **Background pipeline vs. HTTP tests** → dedicated polling test with timing,
  thread-safe DB sessions.
- **CLI accidentally touching parent repo** → always operate inside a
  subshell-bound `git init`, verified by a test.
- **Windows/WSL quirks** → all commands/infra run in WSL Ubuntu; tool paths
  exercised there.

## Verification (evidence)

- 24 backend tests passing; ruff clean; frontend production build succeeds.
- CLI exit-code + git-isolation test suite passes.
- Live local smoke test: health → register → login → project → environment →
  deployment pipeline → job → me → metrics (all pass).

## Repo & Demo

- GitHub repository: (add your URL after push)
- Live demo: (add URL after deployment)

## Screenshots

(Folder `docs/screenshots/` — add after local run)

## Lessons Learned

- Infrastructure-first vs platform-first: automation that starts as a CLI and
  evolves into a web platform stays testable every step.
- Real "platform" value is explicit state: persist every job/deploy with logs.
- Verification must be mechanical: automated checks replace "trust me, it works".