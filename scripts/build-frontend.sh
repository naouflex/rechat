#!/usr/bin/env bash
# Build the SvelteKit frontend into ./build (required before prod Docker build).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f build/index.html && "${FORCE_FRONTEND_BUILD:-}" != "1" ]]; then
  echo "build/index.html already exists (set FORCE_FRONTEND_BUILD=1 to rebuild)."
  exit 0
fi

command -v npm >/dev/null 2>&1 || { echo "npm required" >&2; exit 1; }

export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"
export APP_BUILD_HASH="${APP_BUILD_HASH:-$(git rev-parse --short HEAD 2>/dev/null || echo prod)}"

echo "Building frontend (NODE_OPTIONS=$NODE_OPTIONS, APP_BUILD_HASH=$APP_BUILD_HASH)..."
npm ci
npm run build
echo "Done — build/index.html ready for SKIP_FRONTEND_BUILD Docker builds."
