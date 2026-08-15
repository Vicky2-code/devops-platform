# Daily Notes

Progress and learning notes, one file per day. Each day followed the loop:
**problem → concept → build → test → document → commit**.

| Day | Focus | Artifact |
| --- | ----- | -------- |
| 01  | Environment + project foundation | README, LICENSE, .gitignore, docs/, git init → main |
| 02  | Project structure bootstrap | `bootstrap/`, mkdir/touch/chmod/shebang |
| 03  | Bash scripting basics | variables, echo, redirection, generated README |
| 04  | Interactive bootstrap | `read`, `if`, `-z`, validation, exit codes |
| 05  | Bash functions | `create_assets`, `create_docs`, `create_scripts`, `show_summary` |
| 06  | Terminal UX | exit status, success/warn/error, ANSI colors |
| 07  | CLI arguments | `$1`, `$#`, `$@`; `init <name>` + interactive fallback |
| 08  | Error handling + logging | defensive scripting, meaningful failures |
| 09  | Git automation | git init/status/add/commit/branch inside generated projects |
| 10  | Bootstrap v1.0.0 | release tag + changelog + documentation |
| 11  | DevOps CLI | `scripts/devflow` dispatcher + command modules |
| 12  | Backend intro | FastAPI, REST concepts, routes, JSON |
| 13  | Auth + users | JWT, bcrypt, register/login/me |
| 14  | Projects/environments APIs | CRUD, ownership checks |
| 15  | Deployments API + automation | background pipeline with persisted logs |
| 16  | Jobs + database design | Job model, SQLAlchemy, tests |
| 17  | Frontend | React/Vite dashboard |
| 18  | Docker + Compose | images, healthchecks, networks, volumes |
| 19  | CI/CD + IaC | GitHub Actions, Terraform modules |
| 20  | Kubernetes + observability + security | manifests, Prometheus/Grafana, hardening |

## Consolidated notes (one code block to copy)

```text
# WSL / shell
- WSL2 = Windows Subsystem for Linux (kernel-level virtualization)
- Ubuntu     : distro; env persists in /home/<user>
- Terminal   : text interface to run commands
- Bash       : the shell/language on the CLI
- pwd        : print working directory
- ls / tree  : list files
- cd ..      : go up one directory
- mkdir -p   : create dirs recursively
- touch      : create empty file / update mtime
- cat > file : write; cat >> append; cat file read
- chmod +x   : make executable
- #!/usr/bin/env bash  : shebang → bash interpreter

# Git vs GitHub
- Git      = distributed version control software (local)
- GitHub   = cloud hosting for git repos (remote)

# Bash programming
- vars      : NAME=value ; use $NAME
- $1,$#, $@ : positional CLI args
- exit 0    : success; non-zero = error
- if/then/else; [[ -z "$x" ]] empty check
- functions : name() { ... }

# Backend concepts
- HTTP      : request/response protocol
- REST      : resources via GET/POST/PATCH/DELETE
- JSON      : data interchange format
- JWT       : signed token for stateless auth
- bcrypt    : one-way password hashing

# Containers/cloud
- Dockerfile      : image build recipe
- HEALTHCHECK     : container liveness gate
- Compose         : multi-container app definition
- Terraform       : declare cloud infra as code
- K8s Deployment  : desired-state replicas
- Probe           : readiness vs liveness
- Prometheus      : pulls metrics; Grafana visualizes
```

See also `../design/architecture.md`, `../planning/roadmap.md`,
`../release/changelog.md`.