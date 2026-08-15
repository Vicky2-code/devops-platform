# DevFlow — Interview Preparation

## 1-minute explanation

DevFlow is a DevOps automation platform I built from scratch. It automates the
repetitive work of setting up projects, environments, deployments and
monitoring. I started with a Bash CLI that scaffolds projects and initializes
Git, then built a FastAPI backend with JWT auth that models projects,
environments, deployments and automation jobs, and a React dashboard to manage
them. Then I containerized it with Docker, automated CI/CD with GitHub Actions
including tests and security scans, wrote Terraform for AWS, Kubernetes
manifests, and added Prometheus/Grafana monitoring. Every piece is tested and
every feature was verified before adding the next.

## 3-minute interview explanation

1. **Problem** — developers waste time bootstrapping and wiring DevOps
   tooling; consistency and repeatability suffer.
2. **Why layered** — a CLI teaches scripting and automation; the API teaches
   REST and state; the UI makes it a platform; infra teach Docker, Terraform,
   K8s, monitoring. Each layer is independently testable.
3. **Data model** — User → Project → Environments/Deployments; Jobs. Ownership
   enforced in every query (only your own projects are visible).
4. **Deploy automation** — creating a deployment spawns a background 7-stage
   pipeline that writes real logs/status into the DB, including ~10% simulated
   scan failures so the failure path is actually handled and visible.
5. **CI/CD** — every push runs lint, 24 tests, frontend build, Docker builds,
   Trivy scans, pushes to GHCR, then deploy + healthcheck.
6. **Infra** — Terraform modules produce VPC, subnets, NAT, RDS in private
   subnets, ECS Fargate behind an ALB. K8s manifests are the alternative with
   probes and HPA.
7. **Observability** — Prometheus scrapes `/api/metrics` (latency histogram,
   request count, deployment/job counters); Grafana dashboard + alerts.
8. **Security** — bcrypt + JWT, CORS allow-list, env secrets, scoped SGs,
   no credentials in code, container scanning in CI.
9. **Verification** — present test counts, smoke test flow, and the CI logs as
   evidence; claim only what is deployed and checked.

## Likely technical questions

1. **How does JWT auth work here and why not sessions?** — stateless token
   signed with SECRET_KEY; expiry via `exp`; verified per-request; no server
   session store (easier horizontal scaling).
2. **Why FastAPI?** — async, typed Pydantic validation, auto OpenAPI docs,
   dependency injection, great test support.
3. **SQLite vs Postgres switch** — config-driven; SQLAlchemy keeps the same
   code; production uses Postgres; tests use in-memory/file SQLite.
4. **What's a docker HEALTHCHECK and why use depends_on condition?** — the
   container must be responsive before dependents start; avoids cascade
   failures.
5. **Dockerfile multi-stage purpose (frontend)** — build with Node, serve with
   nginx → smaller, more secure image.
6. **What happens in your Trivy step?** — scans base image + dependencies for
   HIGH/CRITICAL vulnerabilities; `ignore-unfixed` policy control.
7. **Terraform state** — keeps mapping of resources; enable S3 + DynamoDB lock
   for remote shared state; never commit `.tfstate`.
8. **Why ECS Fargate vs EC2?** — no cluster management, per-task isolation,
   pay-per-use; slower cold starts than EC2 but simpler ops.
9. **K8s probes difference** — readiness gates traffic until ready, liveness
   restarts unhealthy pods; enables rolling deploys without downtime.
10. **HPA metric** — CPU utilization on the Deployment via metrics-server.
11. **How would you secure the platform further?** — HTTPS (ACM+ALB), rate
    limiting, short-lived tokens/refresh, OAuth2/OIDC, secrets manager, least
    privilege IAM, network policies.
12. **What is your deployment failure-handling strategy?** — pipeline marks
    failed with logs; CI healthcheck catches breaks; K8s rolling update with
    probes rolls back automatically.
13. **Observability SLOs** — alert on error-rate >5%, p99 latency >1s, down
    for 1m; Grafana dashboard monitors CPU, rps, latency, error ratio.
14. **How do you avoid credentials leaking?** — .gitignore for .env/.tfvars,
    env injection, IAM roles in AWS, GitHub secrets, secret manifests example
    only.
15. **Why not ship everything as Kubernetes?** — honest answer: start with
    managed containers (Fargate) for simplicity; K8s when you need portability,
    multi-env, or self-management at scale.