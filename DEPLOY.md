# Deploying Rechat to Google Cloud

Production setup mirrors [../rewatch](../rewatch) (GCE VM + Docker Compose + Caddy) and push-to-deploy via GitHub Actions (like [../hypertrader](../hypertrader)).

| | Rewatch | Rechat |
|---|---------|--------|
| VM | `redash-prod` | `rechat-prod` |
| Domain | `watch.naoufel.io` | `rechat.naoufel.io` |
| Secrets | manual `.env` | **`setup-github-secrets.sh`** + pre-push hook |

## 1. First-time deploy

No manual key generation — `deploy.sh` auto-creates `.env` and fills production values:

```bash
./scripts/deploy.sh all
./scripts/deploy.sh setup-deploy-key && ./scripts/deploy.sh git-init
./scripts/deploy.sh dns && ./scripts/deploy.sh https && ./scripts/deploy.sh verify
```

DNS: `A  rechat  →  <VM IP>` (see `./scripts/deploy.sh ip`).

## 2. GitHub Actions (push to deploy)

Like hypertrader — one script pushes secrets via `gh` CLI (no GitHub UI):

```bash
./scripts/setup-github-secrets.sh   # PRODUCTION_DOTENV, WEBUI_SECRET_KEY, GCP_PROJECT_ID
./scripts/install-git-hooks.sh      # syncs .env on each push to main
```

Only **GCP_SA_KEY** is added manually once (reuse from hypertrader/polytrader if you have it):

```bash
gh secret set GCP_SA_KEY < /path/to/sa.json
```

Every `git push origin main` → GitHub Actions runs `vm-deploy.sh` on the VM.  
Skip: `[skip deploy]` in commit message.

## 3. Manual operations

```bash
./scripts/deploy.sh pull
./scripts/deploy.sh logs rechat
./scripts/deploy.sh setup-autodeploy   # recap of CI setup
```

## 4. Architecture

```
Internet → Caddy (:443) → rechat:8080
                          ↘ ollama:11434
```

Data: Docker volumes `rechat-data` (uploads/cache) + `ollama`.  
PostgreSQL: Cloud SQL `watch-db` — set `DATABASE_URL` in `.env`, then:

```bash
./scripts/deploy.sh authorize-db   # whitelist VM IP on Cloud SQL
./scripts/deploy.sh update         # restart with new .env
```

Example:

```env
DATABASE_URL=postgresql+psycopg2://postgres:PASSWORD@104.155.73.241:5432/rechat?sslmode=require
```

Create the database once (if missing): `gcloud sql databases create rechat --instance=watch-db`

## 6. Frontend build (OOM fix)

The SvelteKit build needs ~4 GB RAM. The **8 GB VM OOMs** if `npm run build` runs inside Docker there.

Production builds the frontend **on your laptop or in GitHub Actions**, then Docker on the VM only packages the pre-built `build/` folder (`SKIP_FRONTEND_BUILD=true`).

```bash
./scripts/build-frontend.sh      # or: npm ci && npm run build
./scripts/deploy.sh update       # uploads build/ + rebuilds backend image on VM
```

First `./scripts/deploy.sh all` runs `build-frontend.sh` automatically before upload.
