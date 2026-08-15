# Naming & Renaming

## Placeholder brand

The project uses **`devflow`** as a temporary codename. It appears in:

- CLI name / help text (`scripts/devflow`)
- Backend app name & JWT issuer (`backend/app/config.py`, `backend/app/security.py`)
- Frontend brand text (`frontend/src/App.jsx`, `frontend/src/pages/Login.jsx`)
- Docker image names (`docker-compose.yml` is neutral; `ci.yml` uses
  `${{ github.repository }}`)
- Kubernetes namespace / resource names (`k8s/`)
- Terraform resource prefixes (`infra/terraform/modules/*/main.tf`)
- Documentation titles

Nothing depends on the literal string at runtime except config values, so
renaming is safe and mechanical.

## How to rename

### 1. String replace everywhere

```bash
cd <repo>
find . -type f \( -name '*.py' -o -name '*.sh' -o -name '*.yml' -o -name '*.yaml' \
  -o -name '*.jsx' -o -name '*.js' -o -name '*.ts' -o -name '*.json' -o -name '*.md' \) \
  -exec sed -i 's/devflow/NEWNAME/gi' {} +
```

### 2. Update the ones you don't want matched by the blanket replace

- `backend/app/config.py` → `app_name` default
- `.env.example` → `APP_NAME`, `DATABASE_URL` (`devflow.db`)
- `docker-compose.yml` → DB name/user/password `devflow`
- `.github/workflows/ci.yml` → only cosmetic (images use repo name)
- `infra/terraform/terraform.tfvars.example` → image URLs
- `k8s/*.yaml` → resource names, ConfigMap data, image refs

### 3. Commit with a conventional message

```bash
git add -A
git commit -m "chore: rename devflow to NEWNAME"
git push origin main
```

> Keep branding in user-facing strings; keep the rename mechanical and
> verifiable by `grep -ri oldname .` afterwards.