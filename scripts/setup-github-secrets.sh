#!/usr/bin/env bash
# One-time helper: store production secrets in GitHub Actions so you never
# need to paste them in the GitHub UI. Run from the repo root on your laptop.
#
# Usage:
#   ./scripts/setup-github-secrets.sh [path/to/.env]
#
# Creates/updates:
#   PRODUCTION_DOTENV  — production .env (WEBUI_SECRET_KEY excluded)
#   WEBUI_SECRET_KEY     — from .env if present (stable session secret)
#   GCP_PROJECT_ID       — from gcloud config
#
# You still add GCP_SA_KEY manually (service account JSON) — see output below.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${1:-$SCRIPT_DIR/../.env}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — run ./scripts/deploy.sh all first (auto-creates .env)." >&2
  exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "Install GitHub CLI: https://cli.github.com" >&2; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo "gcloud CLI required for GCP_PROJECT_ID." >&2; exit 1; }

# shellcheck source=gh-repo.sh
source "$SCRIPT_DIR/gh-repo.sh"
GITHUB_REPO="$(gh_repo_from_origin "$PROJECT_ROOT")" || exit 1
echo "GitHub repo: $GITHUB_REPO (from git origin, not gh default)"

PROJECT="$(gcloud config get-value project 2>/dev/null)"
[[ -n "$PROJECT" && "$PROJECT" != "(unset)" ]] || {
  echo "Run: gcloud config set project YOUR_PROJECT_ID" >&2
  exit 1
}

echo "Setting PRODUCTION_DOTENV from $ENV_FILE (WEBUI_SECRET_KEY excluded) ..."
"$SCRIPT_DIR/sync-secrets.sh" "$ENV_FILE"

webui_secret="$(awk -F= '$1=="WEBUI_SECRET_KEY"{sub(/^[^=]+=/,""); gsub(/^"|"$|^\047|\047$/,""); print; exit}' "$ENV_FILE")"
if [[ -n "$webui_secret" ]]; then
  echo "Setting WEBUI_SECRET_KEY (one-time stable secret) ..."
  gh secret set WEBUI_SECRET_KEY --body "$webui_secret" -R "$GITHUB_REPO"
fi

echo "Setting GCP_PROJECT_ID=$PROJECT ..."
gh secret set GCP_PROJECT_ID --body "$PROJECT" -R "$GITHUB_REPO"

cat <<EOF

Done. One secret left to add manually:

  GCP_SA_KEY  — JSON key for a GCP service account that can SSH to the VM.

If your .env includes WEBUI_SECRET_KEY, it was also stored as a dedicated
GitHub secret for disaster recovery on a fresh VM.

Create GCP_SA_KEY (once) — or reuse the key from ../hypertrader / ../polytrader:

  gcloud iam service-accounts create rechat-deploy \\
    --display-name="Rechat GitHub deploy"

  gcloud projects add-iam-policy-binding $PROJECT \\
    --member="serviceAccount:rechat-deploy@${PROJECT}.iam.gserviceaccount.com" \\
    --role="roles/compute.instanceAdmin.v1"

  gcloud iam service-accounts keys create /tmp/rechat-deploy-sa.json \\
    --iam-account=rechat-deploy@${PROJECT}.iam.gserviceaccount.com

  gh secret set GCP_SA_KEY < /tmp/rechat-deploy-sa.json -R $GITHUB_REPO
  rm /tmp/rechat-deploy-sa.json

Then run ./scripts/install-git-hooks.sh and push to main — hooks sync .env, Actions redeploys.

EOF
