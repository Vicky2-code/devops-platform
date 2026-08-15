# DevFlow — Resume Bullets (ATS-friendly)

> Only claims that match what is actually implemented and tested. Replace
> bracketed numbers with ones you can measure after final deployment.

## DevOps / Platform Engineering

- Built a multi-layer DevOps automation platform from scratch: Bash CLI,
  FastAPI REST API, React dashboard, Docker, CI/CD, Terraform, Kubernetes,
  and monitoring — deployed end-to-end with GitHub Actions.
- Automated repetitive developer workflows with a Bash CLI (`init`,
  `bootstrap`, `doctor`, `config`, `status`, `deploy`), including input
  validation, error handling, exit codes, and isolated Git initialization.
- Designed a REST API with JWT authentication and bcrypt password hashing
  covering users, projects, environments, deployments, and automation jobs;
  documented with OpenAPI/Swagger.
- Implemented a deployment automation engine that runs persisted
  7-stage pipelines (clone → build → test → scan → push → rollout →
  healthcheck) with logs, statuses, and simulated failure paths.
- Containerized frontend and backend with multi-stage Dockerfiles and
  Docker Compose (Postgres, app, monitoring) using health checks and
  service dependencies.
- Authored a GitHub Actions CI/CD pipeline: lint (ruff/eslint/shellcheck),
  automated tests, production build, Docker build, Trivy container scans,
  GHCR push, deploy, and health check.
- Provisioned cloud infrastructure with Terraform modules (VPC, subnets,
  NAT/IGW, RDS PostgreSQL, ECS Fargate, ALB) using modules, variables,
  outputs, and remote state-ready config.
- Wrote Kubernetes manifests (Deployments, Services, Ingress, ConfigMap,
  Secret, HPA) with readiness/liveness probes and resource limits.
- Added observability with Prometheus scrape config, Grafana dashboard, and
  alert rules for availability, error rate, latency, deployments, and CPU.
- Applied security best practices: env-based secrets, CORS allow-lists,
  security headers, dependency/lint checks, scoped AWS security groups,
  no credentials committed.

## Automation & Scripting

- Automated project scaffolding and Git setup, replacing manual setup with a
  single `devflow init` command ([ ] projects scaffolded).
- Wrote defensive Bash scripts using functions, logging with ANSI UX, and
  exit-code discipline for failure clarity.

## Testing & Quality

- Delivered [24] automated backend tests (auth, projects, environments,
  deployments, jobs, health) integrated into CI.
- Verified CLI behavior with scripted exit-code and Git-isolation tests.
- Validated frontend production build in CI.

## Stack Keywords

Bash · Git · GitHub Actions · FastAPI · Python · SQLAlchemy · PostgreSQL ·
React · Vite · Docker · Docker Compose · Terraform · AWS (VPC/RDS/ECS/ALB) ·
Kubernetes · Prometheus · Grafana · Trivy · Pytest · Ruff