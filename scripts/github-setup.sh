#!/usr/bin/env bash
# ============================================================================
# github-setup.sh — connect this local repo to the user's GitHub account and
# create/push the remote. Run inside WSL Ubuntu.
#
# Usage:
#   ./scripts/github-setup.sh            # HTTPS remote (asks for token)
#   GITHUB_TOKEN=ghp_xxx ./scripts/github-setup.sh
#
# Requires a GitHub Personal Access Token with 'repo' scope:
#   GitHub → Settings → Developer settings → Personal access tokens → Generate
# ============================================================================

set -euo pipefail

REPO_NAME="devops-platform"
USERNAME="vicky2-code"
EMAIL="svigneshvicky229@gmail.com"

cd "$(dirname "$0")/.."   # project root
ROOT="$(pwd)"
export ROOT

echo "==> Ensuring git identity"
if git config user.name >/dev/null 2>&1 && [[ "$(git config user.name)" == "$USERNAME" ]]; then
  echo "    git identity already set for $USERNAME"
else
  echo "    setting git identity for $USERNAME"
fi
git config user.name "$USERNAME"
git config user.email "$EMAIL"

echo "==> Setting default branch to main"
git branch -M main

TOKEN="${GITHUB_TOKEN:-}"
if [[ -z "$TOKEN" ]]; then
  read -rsp "GitHub Personal Access Token (repo scope): " TOKEN
  echo
fi

echo "==> Creating remote repository '${REPO_NAME}' on GitHub"
CREATE_BODY="{\"name\":\"${REPO_NAME}\",\"description\":\"DevOps Automation Platform — CLI, API, dashboards, CI/CD, IaC, k8s, monitoring\",\"private\":false}"
if curl -fsS -o /dev/null -X POST \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -d "$CREATE_BODY" \
  "https://api.github.com/user/repos"; then
  echo "==> Repository created (or already exists)."
else
  echo "==> Repo creation skipped (may already exist)."
fi

echo "==> Setting remote origin (HTTPS with token)"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${USERNAME}:${TOKEN}@github.com/${USERNAME}/${REPO_NAME}.git"
git fetch origin 2>/dev/null || true

echo "==> Pushing main"
git push -u origin main --force

echo "==> Creating tag v1.0.0"
git tag -fa v1.0.0 -m "release: bootstrap tool v1.0.0" || true
git push origin v1.0.0 --force || true

# Remove token from remote URL so it isn't leaked in .git/config
git remote set-url origin "https://github.com/${USERNAME}/${REPO_NAME}.git"
echo
echo "✅ Done. Remote set (token scrubbed from URL)."
echo "   Repo: https://github.com/${USERNAME}/${REPO_NAME}"
echo
echo "💡 Recommended next steps:"
echo "   - Add CI secrets (DEPLOY_URL) in GitHub repo Settings → Secrets"
echo "   - Enable GitHub Pages for the README, or add a live demo link"