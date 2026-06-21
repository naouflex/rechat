#!/usr/bin/env bash
# Resolve owner/repo from git origin (not gh's default, which may be upstream).
set -euo pipefail

gh_repo_from_origin() {
  local root="${1:-.}"
  local url
  url="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
  [[ -n "$url" ]] || {
    echo "gh-repo: no git origin remote" >&2
    return 1
  }
  if [[ "$url" =~ github\.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  echo "gh-repo: could not parse GitHub repo from origin: $url" >&2
  return 1
}
