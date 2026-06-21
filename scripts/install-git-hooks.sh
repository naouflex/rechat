#!/usr/bin/env bash
# Enable repo git hooks (.githooks/pre-push syncs .env → GitHub on push to main).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod +x .githooks/pre-push scripts/sync-secrets.sh
git config core.hooksPath .githooks

echo "Git hooks enabled (core.hooksPath=.githooks)."
echo "Pushing to main will sync .env → PRODUCTION_DOTENV (WEBUI_SECRET_KEY excluded), then GitHub Actions redeploys."
