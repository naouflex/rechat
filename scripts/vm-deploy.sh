#!/usr/bin/env bash
# scripts/vm-deploy.sh — runs ON the GCE VM (after `deploy.sh git-init`).
# Pulls the latest code, rebuilds images, and restarts the stack.
# Used by GitHub Actions on every push to main.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
LOG_DIR="${LOG_DIR:-$HOME/.rechat}"
LOG_FILE="$LOG_DIR/deploy.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { printf '[vm-deploy] %s\n' "$*"; }
die() { log "ERROR: $*"; exit 1; }

[[ -f .env ]] || die ".env missing in $ROOT — copy production secrets before deploying."

if [[ ! -d .git ]]; then
  die "Not a git checkout. From your laptop run: ./scripts/deploy.sh git-init"
fi

log "Fetching $GIT_REMOTE/$GIT_BRANCH..."
git fetch "$GIT_REMOTE" "$GIT_BRANCH"

local_ref="$(git rev-parse HEAD)"
remote_ref="$(git rev-parse "$GIT_REMOTE/$GIT_BRANCH")"

if [[ "$local_ref" == "$remote_ref" ]]; then
  log "Already at $remote_ref — rebuilding anyway (push-triggered deploy)."
else
  log "Updating $local_ref → $remote_ref"
  git reset --hard "$GIT_REMOTE/$GIT_BRANCH"
fi

compose_args=(-f "$COMPOSE_FILE")
[[ -f compose.https.yaml ]] && compose_args+=(-f compose.https.yaml)

log "Building images (frontend + backend; may take several minutes)..."
docker compose "${compose_args[@]}" build --pull

log "Restarting stack..."
docker compose "${compose_args[@]}" up -d

log "Pruning dangling images..."
docker image prune -f >/dev/null 2>&1 || true

log "Done. $(git log -1 --oneline)"
docker compose "${compose_args[@]}" ps
