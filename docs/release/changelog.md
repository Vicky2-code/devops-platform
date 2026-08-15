# DevFlow — Changelog

All notable changes to DevFlow. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/). Dates are UTC.

## [1.0.0] - 2026-08-15

**Bootstrap Tool v1** (Day 1-10) — first usable release.

### Added
- Interactive project scaffolder with input validation (`devflow bootstrap`)
- Non-interactive scaffolding (`devflow init <name>`)
- Standard structure generation: `assets/ docs/ scripts/ src/ tests/`
- Auto-generated README, `.gitignore`, MIT `LICENSE`
- Git repository init (`main` branch) isolated from parent repos
- Terminal UX with success/warn/error colors
- CLI configuration (`devflow config show|set`) stored in `~/.config/devflow`

### Fixed
- Input validation edge cases (empty, spaces, uppercase, existing dirs)

---

## [Unreleased] — post-1.0.0

### Added
- **CLI (Phase 2):** `scripts/devflow` dispatcher with `init`, `bootstrap`,
  `doctor`, `config`, `status`, `deploy`, `version`, `help`
- **Backend (Phase 3-4):** FastAPI with JWT auth, Projects, Environments,
  Deployments, Jobs, Users; SQLAlchemy models; bcrypt; 24 pytest tests;
  Prometheus metrics
- **Frontend (Phase 5):** React/Vite dashboard (login, dashboard, projects,
  deployment controls, jobs, health)
- **Docker (Phase 6):** backend + frontend Dockerfiles; compose stacks for app
  and monitoring; health checks
- **CI/CD (Phase 7):** GitHub Actions lint → test → build → scan → push →
  deploy → healthcheck
- **IaC (Phase 8-9):** Terraform modules (networking, RDS, ECS+ALB)
- **Kubernetes (Phase 10):** deployment/services/ingress/HPA + probes
- **Observability (Phase 11):** Prometheus + Grafana dashboard + alert rules
- **Security (Phase 12):** env-based secrets, CORS, security headers,
  container scanning, validation
- **Docs (Phase 14):** architecture, roadmap, changelog, daily notes, setup
- **Portfolio (Phase 17-19):** case study, resume bullets, interview prep