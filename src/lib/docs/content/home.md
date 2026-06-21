# Rechat

**Rechat is a self-hosted AI workspace for chat, knowledge, tools, and team collaboration.** Connect local models through Ollama or cloud APIs through OpenAI-compatible endpoints, and keep conversations on infrastructure you control.

> **About this project:** Rechat is a fork of [Open WebUI](https://github.com/open-webui/open-webui). Most capabilities described here come from that codebase. For the latest upstream reference, see the [Open WebUI documentation](https://docs.openwebui.com/).

---

## Quick start

Production on this instance:

1. Open [Rechat](/) and click **Get started** (or go to [/auth](/auth)).
2. Create the first account (it becomes admin on a fresh install).
3. In **Admin Settings**, add your model connections (Ollama, OpenAI, etc.).
4. Start a chat from the home screen.

Self-hosted deploy (Docker on your own server):

```bash
git clone https://github.com/naouflex/rechat.git
cd rechat
cp .env.example .env   # or let scripts/deploy.sh create it
./scripts/build-frontend.sh
docker compose -f docker-compose.prod.yml up -d
```

See [Getting started](/docs/getting-started) and [DEPLOY.md](https://github.com/naouflex/rechat/blob/main/DEPLOY.md) on GitHub for GCE/Caddy production setup.

---

## Getting started

| Topic | Description |
| --- | --- |
| [Getting started](/docs/getting-started) | Docker, providers, first login, essentials |
| [Features](/docs/features) | What Rechat can do out of the box |
| [Tutorials](/docs/tutorials) | SSO, integrations, backups |
| [Troubleshooting](/docs/troubleshooting) | Connection and context issues |
| [FAQ](/docs/faq) | Common questions |

---

## Essentials (day one)

After your first login, these areas matter most:

1. **Model connections** — Admin Settings → Connections. Point Ollama at `http://ollama:11434` in Docker, or add API keys for cloud providers.
2. **Workspace** — Prompts, models, tools, and knowledge collections live under **Workspace** in the sidebar.
3. **RAG** — Upload documents to a knowledge base, attach it to a chat or model preset, and ask questions grounded in your files.
4. **Tools** — Connect OpenAPI tool servers or Python functions so models can call external APIs and run code.
5. **Roles** — The first user is admin. Invite teammates from Admin → Users when you are ready.

---

## Explore

- **Chat** — Multi-model conversations, files, web search, voice, image generation
- **Knowledge** — Vector search (RAG), hybrid retrieval, document upload
- **Channels** — Shared spaces with @model mentions for teams
- **Notes** — Standalone documents with AI assist
- **Automations** — Scheduled prompts and workflows

Details: [Features](/docs/features).

---

## Deploy anywhere

Rechat runs wherever Docker runs:

| Method | Best for |
| --- | --- |
| Docker Compose | Single VM (this project's default) |
| Pre-built frontend + Docker | Low-memory VMs (see DEPLOY.md) |
| PostgreSQL (`DATABASE_URL`) | Shared Cloud SQL or managed Postgres |
| Caddy / reverse proxy | HTTPS on a public domain |

Advanced scaling, Redis, and observability follow the same patterns as upstream; see [Open WebUI advanced topics](https://docs.openwebui.com/getting-started/advanced-topics/) if you outgrow a single VM.

---

## Get help

- **This instance:** Admin contact or your internal runbook
- **Upstream community:** [Open WebUI Discord](https://discord.gg/5rJgQTnV4s), [GitHub Discussions](https://github.com/open-webui/open-webui/discussions)
- **Rechat deploy issues:** [naouflex/rechat](https://github.com/naouflex/rechat/issues)
