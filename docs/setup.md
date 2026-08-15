# DevFlow — Setup Guide

## Prerequisites

| Tool | Version | Purpose |
| ---- | ------- | ------- |
| WSL2 + Ubuntu | 22.04+ | Linux environment (26.04 tested) |
| Bash | 5.x | CLI runtime |
| Git | 2.30+ | version control |
| Python | 3.11+ (3.14 tested) | backend |
| Node.js | 18+ (20 recommended) | frontend |
| Docker | 24+ (for container run) | containerization |
| Terraform | 1.5+ (for AWS) | IaC |

## 1. Clone & configure

```bash
git clone <your-repo-url> devflow
cd devflow
cp .env.example .env            # adjust values
```

## 2. Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

- API docs: http://localhost:8000/docs
- Health: http://localhost:8000/api/health
- Metrics: http://localhost:8000/api/metrics

### Run backend tests

```bash
cd backend
python -m pytest -v
ruff check app tests
```

## 3. Frontend

```bash
cd frontend
npm install
npm run dev          # dev server on :5173, proxies /api to :8000
npm run build        # production build → dist/
npm run preview
```

## 4. CLI

```bash
./scripts/devflow doctor
./scripts/devflow init my-project
./scripts/devflow config set AUTHOR "Your Name"
./scripts/devflow deploy staging
```

## 5. Full stack with Docker

Requires Docker Desktop running (WSL2 backend enabled).

```bash
docker compose up --build -d
# frontend http://localhost:3000  backend http://localhost:8000/docs
```

Monitoring stack:

```bash
docker compose -f docker-compose.monitoring.yml up -d
# prometheus :9090   grafana :3001 (admin/admin)
```

## 6. CI/CD

Push to GitHub. Inspect `.github/workflows/ci.yml`. To trigger the live deploy
healthcheck, set repository secret `DEPLOY_URL`.

## 7. AWS (Terraform)

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # fill db_password, images
terraform init
terraform plan
terraform apply        # creates VPC + RDS + ECS + ALB
terraform destroy      # teardown when done
```

> Never commit `terraform.tfvars` or `.tfstate`.

## 8. Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl create secret generic devflow-secrets \
  --namespace devflow \
  --from-literal=SECRET_KEY=... \
  --from-literal=DATABASE_URL=...
kubectl apply -f k8s/
```

## Renaming the brand

The placeholder is `devflow`. To rename globally:

```bash
find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.jsx" -o -name "*.js" -o -name "*.json" -o -name "*.md" \) \
  -exec sed -i 's/devflow/NEWNAME/gi' {} +
```

Then update README, docker image names in `ci.yml`/tfvars, and the K8s image refs.