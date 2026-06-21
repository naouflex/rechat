# Rechat presentation assets

Screenshots and a demo GIF for slides, README, or marketing.

## Demo account (local Docker)

| Field | Value |
|-------|--------|
| Email | `demo@rechat.io` |
| Password | `DemoPass123!` |
| Name | Demo User |

Created in the local SQLite volume for capture only. Do not use in production.

## Files

| File | Description |
|------|-------------|
| `01-landing-hero.png` | Landing page hero + mock chat window |
| `02-landing-features.png` | Landing page scrolled to features |
| `03-docs.png` | Docs home (from https://rechat.naoufel.io/docs) |
| `04-auth-login.png` | Sign-in page |
| `05-chat-home.png` | Chat home after login (`tinyllama:latest`) |
| `06-chat-composing.png` | Message typed in composer |
| `07-chat-conversation.png` | User prompt + assistant reply |
| `08-workspace-models.png` | Workspace → Models |
| `demo-flow.webm` | Screen recording: login → chat → reply |
| `demo-flow.gif` | GIF version of the demo flow (~24s) |

## Regenerate

```bash
docker compose up -d
# Ensure tinyllama is available: docker exec ollama ollama pull tinyllama

node scripts/capture-presentation-assets.mjs   # full set (landing + auth + chat)
node scripts/capture-docs-shot.mjs               # docs only (production)
node scripts/capture-chat-demo.mjs               # chat screenshots + webm
node scripts/capture-extra-shots.mjs             # workspace (+ docs if logged in locally)

ffmpeg -y -i static/marketing/presentation/demo-flow.webm \
  -vf "fps=12,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" \
  -loop 0 static/marketing/presentation/demo-flow.gif
```
