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

Data: Docker volumes `rechat-data` + `ollama`.
