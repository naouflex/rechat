# Features

One interface for every AI model. Private, extensible, and built for teams.

Rechat replaces a patchwork of separate AI tools: chat, document search, image generation, and custom prompts in one self-hosted place.

---

## Chat & conversations

Talk to any connected model, switch mid-conversation, and attach context as you go.

| Capability | Description |
| --- | --- |
| Multi-model chats | Compare two models side by side |
| File & image uploads | PDFs, images, code for analysis |
| Web search | Models search the web and cite sources (when enabled) |
| Code execution | Python in-browser or via terminal servers |
| Message queue | Keep typing while the model responds |
| Memory | Optional cross-chat memory for user facts |
| Folders, tags, pins | Organize conversation history |
| Voice & audio | Speech-to-text and text-to-speech |
| Image generation | DALL·E, Gemini, ComfyUI, and compatible APIs |
| Automations | Scheduled recurring prompts |

---

## Knowledge & RAG

Upload documents, build knowledge bases, and let models retrieve relevant chunks.

| Capability | Description |
| --- | --- |
| Vector databases | ChromaDB, PGVector, Qdrant, Milvus, Elasticsearch, and others |
| Hybrid search | BM25 + vector with reranking |
| Extraction | Tika, Docling, Azure, Mistral OCR, custom loaders |
| Agentic retrieval | Models search documents autonomously when tools allow |
| Full context mode | Inject whole documents without chunking |

Create collections under **Workspace → Knowledge**, upload files, then attach a collection to a chat or model preset.

---

## Models & agents

Wrap any base model with instructions, tools, and knowledge.

| Capability | Description |
| --- | --- |
| Model presets | System prompt + tools + knowledge in one package |
| Dynamic variables | `{{ USER_NAME }}`, `{{ CURRENT_DATE }}`, etc. |
| Bound tools | Force specific tools per preset |
| Access control | Limit presets to users or groups |

Manage under **Workspace → Models**.

---

## Notes

A workspace outside any single chat thread.

- Rich Markdown editor
- AI rewrite on selection
- Attach notes to chats for full-fidelity context

Open **Notes** from the sidebar.

---

## Channels

Shared spaces where people and models participate together.

- `@model` mentions to invoke a model in the thread
- Threads, reactions, pins
- Public, private, or group channels

---

## Open Terminal

Connect a real environment for code and files (when configured).

- Run commands and return output to chat
- File browser in the sidebar
- Optional Docker isolation

Configure terminal servers in user or admin settings.

---

## Extensibility

| Type | Purpose |
| --- | --- |
| Tools & functions | Python scripts in chat |
| Pipelines | Filter or transform messages |
| MCP | Model Context Protocol servers |
| OpenAPI | Auto-discover tools from OpenAPI specs |
| Skills | Markdown instruction packs |
| Prompts | Slash-command templates |

Browse **Workspace → Tools**, **Functions**, **Prompts**, **Skills**.

---

## Authentication & access

Multi-user from day one.

| Capability | Description |
| --- | --- |
| RBAC | Admin, user, and pending roles |
| OAuth / OIDC / LDAP | Google, Microsoft, GitHub, generic OIDC, LDAP |
| API keys | Programmatic access |

Configure under **Admin Panel → Settings**.

---

## Administration

| Area | Description |
| --- | --- |
| Analytics | Usage, tokens, costs (when enabled) |
| Evaluations | Model comparisons and feedback |
| Banners | System-wide announcements |
| Webhooks | Events for sign-up, chat completion, etc. |

---

## Deploy anywhere

Rechat supports the same deployment surface as upstream:

- Docker & Compose (including GPU images)
- Kubernetes / Helm
- External Postgres, Redis, object storage
- OpenTelemetry

This fork adds a **pre-built frontend** path and **GCE + Caddy** scripts in `scripts/deploy.sh` for production on a single VM.
