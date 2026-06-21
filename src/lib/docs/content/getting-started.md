# Getting started

From zero to your first conversation in a few minutes.

Rechat runs on Docker (recommended for production), connects to **Ollama** and **OpenAI-compatible** APIs, and stores data on your server or attached PostgreSQL database.

---

## Quick start

| Method | When to use |
| --- | --- |
| **This hosted instance** | Sign in at [/auth](/auth) — already running at your domain |
| **Docker Compose** | Single-server production (see repo `DEPLOY.md`) |
| **Local dev** | `npm run dev` + backend from source |

### Docker (typical self-host)

```bash
docker compose -f docker-compose.prod.yml up -d
```

The stack includes **Ollama** (optional local models) and **Rechat** on port 8080. Put **Caddy** or another reverse proxy in front for HTTPS.

### Connect a provider

1. Sign in as admin.
2. **Admin Panel → Settings → Connections**
3. Add **Ollama** base URL (e.g. `http://ollama:11434` inside Compose, or `http://host.docker.internal:11434` from Docker Desktop).
4. Or add **OpenAI** / **OpenRouter** / other OpenAI-compatible endpoints with an API key.

Start a new chat and pick a model from the selector.

---

## First-time signup

On a fresh database with no users:

- The first account you create becomes **admin**.
- Signup may then be disabled automatically.
- Set `WEBUI_ADMIN_EMAIL` and `WEBUI_ADMIN_PASSWORD` in `.env` for headless bootstrap (optional).

---

## Essentials after install

These six areas cover most day-one setup (adapted from upstream “Essentials”):

| Topic | What it is |
| --- | --- |
| **Plugins & functions** | Python tools, filters, and pipelines in Admin → Functions |
| **Context management** | Long chats hit model limits; use filters or start fresh threads |
| **Task models** | Smaller/cheaper model for titles, tags, and autocomplete |
| **RAG** | Knowledge bases + document upload for grounded answers |
| **Tool calling** | Native tool mode + OpenAPI / MCP servers |
| **Terminal** | Optional code execution via connected terminal servers |

---

## Install as an app (PWA)

Rechat is a Progressive Web App. From Chrome, Edge, or mobile Safari:

- **Desktop:** Use the install icon in the address bar.
- **iOS:** Share → Add to Home Screen.
- **Android:** Menu → Install app.

You get a full-screen app without a separate download.

---

## Updating

On this VM deploy:

```bash
./scripts/deploy.sh update
```

Or push to `main` if GitHub Actions auto-deploy is configured.

General pattern: pull latest image or code, rebuild if needed, restart containers. Back up `rechat-data` volume and your database before major upgrades.

Upstream guide: [Updating Open WebUI](https://docs.openwebui.com/getting-started/updating/).

---

## Sharing with a team

One deployment can serve a whole team:

- **Users & roles** — Admin approves accounts or enable signup.
- **Groups** — Restrict models and knowledge by group.
- **Channels** — Persistent shared chat spaces.
- **HTTPS** — Always terminate TLS at Caddy/nginx; see `scripts/deploy.sh https`.

Upstream: [Sharing Open WebUI](https://docs.openwebui.com/getting-started/sharing/).

---

## Advanced topics

When you need more than one VM:

- External **PostgreSQL** (`DATABASE_URL`) — already supported on this fork
- **Redis** for multi-worker sessions
- **S3** for file storage
- **OpenTelemetry** for traces and metrics

See [Open WebUI advanced topics](https://docs.openwebui.com/getting-started/advanced-topics/) for environment variables and scaling patterns; they apply to Rechat with the same names.
