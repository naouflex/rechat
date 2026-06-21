# Troubleshooting

Common issues and where to look first.

---

## Cannot connect to Ollama

**Symptoms:** No models listed, connection errors in logs.

**Checks:**

1. Ollama is running: `docker compose ps` or `curl http://localhost:11434/api/tags`
2. From inside the Rechat container, use the **service name** (`http://ollama:11434`), not `localhost`
3. On Docker Desktop, use `http://host.docker.internal:11434` to reach Ollama on the host
4. Ensure Ollama listens on `0.0.0.0`, not only `127.0.0.1`, if connecting from another container

---

## Docker `localhost` confusion

Inside a container, `localhost` is the container itself. Use:

- `host.docker.internal` (Docker Desktop / some Linux setups)
- The Compose service name on the same network
- The host's LAN IP

---

## "Prompt is too long" / context exceeded

The **model provider** rejected the request because the full thread (system prompt + history + files + tools) exceeded the context window.

**Mitigations:**

- Start a new chat or branch
- Remove large attachments
- Use a model with a larger context window
- Install a **filter function** that trims old turns (community filters on [openwebui.com](https://openwebui.com))

Upstream detail: [Context window guide](https://docs.openwebui.com/troubleshooting/context-window/).

---

## 502 / site not loading after deploy

The backend may still be running database migrations (1–3 minutes on first PostgreSQL boot).

```bash
./scripts/deploy.sh verify   # waits for /health
./scripts/deploy.sh logs rechat
```

---

## Frontend build OOM on VM

Do **not** run `npm run build` on a small VM. Build locally or in CI:

```bash
./scripts/build-frontend.sh
./scripts/deploy.sh update
```

---

## HTTPS / certificate issues

1. DNS A record must point at the VM before `deploy.sh https`
2. Watch Caddy: `./scripts/deploy.sh https-logs`
3. `LETSENCRYPT_EMAIL` must be set in `.env`

---

## Database connection (PostgreSQL)

1. VM IP authorized on Cloud SQL: `./scripts/deploy.sh authorize-db`
2. `DATABASE_URL` uses `sslmode=require` for Cloud SQL
3. Check logs for Alembic migration errors

---

## More help

- [FAQ](/docs/faq)
- [Open WebUI troubleshooting](https://docs.openwebui.com/troubleshooting/) (upstream, same core app)
- [GitHub Issues](https://github.com/naouflex/rechat/issues) for this fork's deploy stack
