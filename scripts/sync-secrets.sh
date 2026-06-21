#!/usr/bin/env bash
# Upload local .env to GitHub PRODUCTION_DOTENV (no-op if .env is missing).
#
# WEBUI_SECRET_KEY is stripped — it must stay stable on the production VM and
# is stored as a separate GitHub secret when needed.
# Called automatically by the pre-push hook when pushing to main.
#
# Usage: ./scripts/sync-secrets.sh [path/to/.env]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${1:-$SCRIPT_DIR/../.env}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$ENV_FILE" ]]; then
  exit 0
fi

command -v gh >/dev/null 2>&1 || {
  echo "sync-secrets: gh not found — skipping PRODUCTION_DOTENV update." >&2
  exit 0
}

# gh defaults to upstream (open-webui/open-webui) in this fork — use origin instead.
# shellcheck source=gh-repo.sh
source "$SCRIPT_DIR/gh-repo.sh"
GITHUB_REPO="$(gh_repo_from_origin "$PROJECT_ROOT")" || exit 1

echo "sync-secrets: updating PRODUCTION_DOTENV on $GITHUB_REPO (WEBUI_SECRET_KEY excluded) ..."
awk -F= '
  /^[[:space:]]*#/ { print; next }
  /^[[:space:]]*$/ { print; next }
  $1 ~ /^[[:space:]]*WEBUI_SECRET_KEY[[:space:]]*$/ { next }
  { print }
' "$ENV_FILE" | gh secret set PRODUCTION_DOTENV -R "$GITHUB_REPO"
