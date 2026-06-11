# AGENTS.md

## Cursor Cloud specific instructions

Open WebUI is one product with two dev-mode services that run separately:

- **Backend** — FastAPI/uvicorn (`open_webui.main:app`) on port **8080**. Python deps live in a repo-root virtualenv at `/workspace/.venv` (created from `backend/requirements.txt`).
- **Frontend** — SvelteKit/Vite dev server on port **5173**. In dev the browser hard-codes the backend at `http://<hostname>:8080` (see `src/lib/constants.ts`), so both services must be up and `dev.sh` already sets the matching `CORS_ALLOW_ORIGIN`.

(In production the backend serves the pre-built frontend on a single port; that is not how dev runs.)

### Running the services
- Backend: `cd backend && PATH=/workspace/.venv/bin:$PATH bash dev.sh` (this is the canonical dev command; runs uvicorn with `--reload` on 8080).
- Frontend: `npm run dev` (Vite on 5173). It first runs `npm run pyodide:fetch`, which downloads Pyodide packages from the network — expect that on a cold start.
- First run: open the frontend and use the sign-up screen to create the first admin account (it becomes the admin).

### LLM / chat (needed for the core "send a message" flow)
- **Do not rely on the bundled local Ollama in this VM**: `ollama serve` starts, but its `llama-server` runner **segfaults on model load** here (crashes regardless of `OLLAMA_FLASH_ATTENTION`). Chat via local Ollama does not work.
- **Use OpenAI instead**, via the `OPENAI_API_KEY` secret (already injected into the VM environment). The backend auto-loads `/workspace/.env` (gitignored) at startup, so enable OpenAI by creating it before the first backend boot:
  ```sh
  cd /workspace
  {
    echo "WEBUI_SECRET_KEY=devsecret"
    echo "OPENAI_API_KEY=$OPENAI_API_KEY"
    echo "OPENAI_API_BASE_URL=$OPENAI_API_BASE_URL"
    echo "ENABLE_OLLAMA_API=False"
  } > .env
  ```
  `ENABLE_OLLAMA_API=False` hides the broken local Ollama so only working OpenAI models appear.

### Persistent-config gotcha (important)
Open WebUI has `ENABLE_PERSISTENT_CONFIG=True` by default: on the **first** backend boot it reads config (including the OpenAI key) from env/`.env` and writes it to `backend/data/webui.db`; on later boots it reads from the DB and **ignores env changes**. `backend/data/webui.db` is gitignored, so a fresh VM starts clean. If OpenAI models don't show up after changing env:
- delete `backend/data/webui.db` and restart the backend (it re-reads `.env`), **or**
- set the key at runtime via Admin Settings → Connections, or `POST /openai/config/update`.

### File-watcher limit
Vite/Vitest (and uvicorn `--reload`) watch `/workspace` including the large `.venv`, which can hit `ENOSPC: System limit for number of file watchers reached`. Raise it with `sudo sysctl -w fs.inotify.max_user_watches=524288`. Run Vitest one-shot as `npx vitest run` to avoid watch mode entirely.

### Lint / test / build
Commands are in `package.json` (`scripts`) and `pyproject.toml`.
- Build: `npm run build` (SvelteKit/Vite; writes to `build/`).
- Type check: `npm run check` (svelte-check) — **runs but reports many pre-existing errors** in this snapshot; not a clean gate.
- Frontend tests: `npm run test:frontend` (Vitest) — currently no test files (`--passWithNoTests`).
- Backend tests: `pytest` is installed but the repo has no `test_*.py` (only fixtures under `test/`).
- Backend lint/format: the pre-commit hook uses `ruff` (pinned `0.15.5`, not in `requirements.txt` — install separately if needed). `ruff format --check backend` is clean; `ruff check backend` reports many pre-existing findings.
