# Tutorials

Step-by-step guides for common tasks. These follow upstream Open WebUI tutorials; steps apply to Rechat unless noted.

If you are new, complete [Getting started](/docs/getting-started) first.

---

## Authentication & SSO

| Goal | Upstream tutorial |
| --- | --- |
| Okta OIDC | [Okta SSO](https://docs.openwebui.com/tutorials/integrations/okta-oidc-sso/) |
| Azure AD LDAP | [Azure AD LDAP](https://docs.openwebui.com/tutorials/integrations/azure-ad-ldap/) |
| Microsoft + Google OAuth | [Dual OAuth](https://docs.openwebui.com/tutorials/integrations/dual-oauth/) |
| Entra ID group names | [Entra group sync](https://docs.openwebui.com/tutorials/integrations/entra-id-group-name-sync/) |
| Tailscale HTTPS | [Tailscale](https://docs.openwebui.com/tutorials/integrations/tailscale/) |

Configure providers in **Admin Panel → Settings → Authentication**.

---

## Integrations

| Goal | Upstream tutorial |
| --- | --- |
| Azure OpenAI (Entra ID) | [Azure OpenAI](https://docs.openwebui.com/tutorials/integrations/azure-openai/) |
| Intel GPU + Ollama | [IPEX-LLM](https://docs.openwebui.com/tutorials/integrations/ipex-llm/) |
| Langfuse / Helicone | [Observability integrations](https://docs.openwebui.com/tutorials/integrations/) |
| Continue.dev in VS Code | [Continue.dev](https://docs.openwebui.com/tutorials/integrations/continue-dev/) |
| Jupyter code interpreter | [Jupyter](https://docs.openwebui.com/tutorials/integrations/jupyter/) |
| MCP (e.g. Notion) | [MCP tutorials](https://docs.openwebui.com/tutorials/integrations/) |

---

## Maintenance

| Goal | Upstream tutorial |
| --- | --- |
| Backup & restore | [Backups](https://docs.openwebui.com/tutorials/maintenance/backups/) |
| Database migrate / repair | [Database management](https://docs.openwebui.com/tutorials/maintenance/database/) |
| Air-gapped / offline | [Offline mode](https://docs.openwebui.com/tutorials/maintenance/offline-mode/) |
| S3 uploads | [S3 storage](https://docs.openwebui.com/tutorials/maintenance/s3-storage/) |

**Rechat-specific:** production backup includes Docker volume `rechat-data` plus your Postgres database (if `DATABASE_URL` is set).

---

## Rechat production deploy

| Task | Where |
| --- | --- |
| First VM deploy | [DEPLOY.md](https://github.com/naouflex/rechat/blob/main/DEPLOY.md) |
| Cloud SQL Postgres | DEPLOY.md § PostgreSQL |
| Push-to-deploy | `scripts/setup-github-secrets.sh` + GitHub Actions |

---

## Community

More walkthroughs and videos: [Open WebUI community guides](https://docs.openwebui.com/tutorials/community/).
