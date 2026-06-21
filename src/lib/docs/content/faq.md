# FAQ

---

### How do I get support?

For **this Rechat deployment**, contact your instance administrator.

For **application behavior** shared with upstream, search [Open WebUI docs](https://docs.openwebui.com/faq/), [Discord](https://discord.gg/5rJgQTnV4s), or [GitHub Discussions](https://github.com/open-webui/open-webui/discussions). For **deploy scripts** in this repo, open an issue at [naouflex/rechat](https://github.com/naouflex/rechat/issues).

When asking for help, include: Rechat version, deploy method (Docker/VM), model provider, and steps to reproduce.

---

### Is my data sent anywhere?

By default, chat data stays on **your server**. If you connect OpenAI, Anthropic, or another cloud API, prompts and responses go to that provider to generate replies. Nothing is sent to Rechat the company (there isn't one); this is self-hosted software.

Inspect the open-source codebase to verify behavior.

---

### Why am I asked to sign up?

Signup creates a local admin on your instance. Credentials and chat history are stored in **your** database (SQLite volume or PostgreSQL), not on a third-party service.

---

### How do I customize the logo?

Replace files under `static/` (see this fork's branding commits) and set `WEBUI_NAME` in `.env`. Upstream also offers enterprise branding options.

---

### "The prompt is too long" / context length exceeded

The model rejected the request because the **entire conversation** (system prompt + history + files + tools) exceeded its context window.

Fixes: new chat, smaller attachments, larger-context model, or a filter function that trims old messages. See [Troubleshooting](/docs/troubleshooting).

---

### Can I use Rechat offline?

Yes. With **Ollama** (or another local provider) and no external API keys, chat works without internet except for optional features (web search, cloud models).

---

### Docker cannot reach services on `localhost`

Inside a container, use `host.docker.internal` or the Docker service name, not `localhost`. See [Troubleshooting](/docs/troubleshooting).

---

### How do I update?

**This VM:** `./scripts/deploy.sh update` or merge from `main` via GitHub Actions.

**General:** Pull new image/code, rebuild, restart. Backup data first.

---

### Where are shared chats and uploaded files?

- **Shared chats:** Settings → Data Controls → Shared Chats
- **Uploaded files:** Settings → Data Controls → Manage Files

---

### How do I connect OpenAI, Anthropic, or Ollama?

Admin Panel → Settings → **Connections**. Add base URL and API key per provider. Ollama typically needs no key.

---

### Does Rechat support teams?

Yes: multiple users, roles, groups, channels, and shared knowledge bases. Enable signup or create users from Admin → Users.

---

### What is the relationship to Open WebUI?

Rechat is a **fork** of [Open WebUI](https://github.com/open-webui/open-webui). Feature documentation largely applies to both. Upstream docs remain the canonical reference for deep dives: [docs.openwebui.com](https://docs.openwebui.com/).
