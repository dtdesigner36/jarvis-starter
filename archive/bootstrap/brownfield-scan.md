# Bootstrap Phase 0 — Brownfield Detection

Automatic project-folder scan **before** asking the user. Reduces dialogue and prevents misclassification.

## When to run

If the project root has any of:
- `package.json`
- `pyproject.toml`
- `requirements.txt`
- `Pipfile`
- `Gemfile`
- `go.mod`
- `Cargo.toml`
- `build.gradle` / `build.gradle.kts`
- `pom.xml`
- `composer.json`
- `Podfile`
- `*.csproj`

## What to check

### package.json (Node projects)

```json
{
  "dependencies": {
    "next": ...,           → web-app (Next.js)
    "express": ...,        → web-api
    "@nestjs/core": ...,   → web-api (NestJS)
    "grammy": ...,         → telegram-bot
    "discord.js": ...,     → discord-bot
    "@slack/bolt": ...,    → slack-bot
    "astro": ...,          → landing/blog
    "docusaurus": ...,     → documentation-site
    "phaser": ...,         → browser-game
    "electron": ...,       → desktop
    "tauri-apps/...": ..., → desktop (Tauri)
    "expo": ...,           → mobile-app
    "react-native": ...,   → mobile-app
    "playwright": ...,     → parser (if scraper structure)
    "prisma": ...,         → signal for web-api
    "socket.io": ...,      → real-time-app
    "stripe": ...,         → e-commerce (strong signal)
    "anthropic": ...,      → llm-agent
  }
}
```

### pyproject.toml / requirements.txt (Python projects)

```
python-telegram-bot   → telegram-bot
aiogram                → telegram-bot
discord.py            → discord-bot
fastapi                → web-api / ml-api
flask                  → web-api
django                 → web-app (or web-api if only DRF)
scrapy                 → parser
beautifulsoup4         → parser
pandas                 → data-pipeline
anthropic              → llm-agent
langchain              → llm-agent
transformers           → ml-model
torch / tensorflow     → ml-model
```

### Folder structure

Specific folders are strong signals:
```
app/                  → Next.js App Router (web-app)
pages/                → Next.js Pages Router (web-app)
components/           → React/Vue (web-app)
src/modules/          → NestJS modules (web-api)
handlers/             → bot handlers (telegram/discord/slack)
scrapers/             → parser
scenes/               → Phaser (browser-game)
migrations/           → DB project
prisma/               → web-api with Prisma
```

### Configs

- `next.config.js` → Next.js
- `vite.config.ts` → Vite frontend
- `nest-cli.json` → NestJS
- `expo.json` / `app.json` (Expo) → mobile-app
- `tauri.conf.json` → desktop Tauri
- `manifest.json` + `content_scripts` → browser-extension

## Brownfield-scan output

```
💠 JARVIS: brownfield detected!
  Stack: Next.js 15 + Prisma + PostgreSQL + Tailwind
  Archetype signals: web-app (strong) + web-api (strong)

  Is this a full SaaS app? Or split front and back?
```

## Integration with classification

Brownfield results go into Phase 1 as additional_signals with weight +50 for each confirmed archetype. They dominate over the prompt if there's a conflict.

## Dev-stage signals (Phase 0.5 — Adopt trigger)

Beyond stack detection, also collect these signals to decide **Start vs Adopt**:

| Signal | Check |
|---|---|
| Active git history | `git log --oneline \| wc -l` ≥ 10 |
| Mature lockfile | `package-lock.json` / `pnpm-lock.yaml` / `poetry.lock` / `Cargo.lock` mtime > 7 days old |
| Real source code | `src/` / `app/` / `lib/` / `pkg/` has >10 non-boilerplate files OR >500 LOC total |
| Existing Claude setup | `CLAUDE.md` exists OR `.claude/` directory exists |
| Existing docs | `docs/` / `wiki/` exists, OR `README.md` > 100 lines, OR `CHANGELOG.md` exists |
| Running CI | `.github/workflows/` / `.gitlab-ci.yml` / `.circleci/` exists |

**Rule: ≥2 signals → default to Adopt mode**, not Start. See `brownfield-adopt.md` for the Adopt flow.

Edge: user can force Start with `jarvis start --force` even when signals are present.

## Edge cases

- **Monorepo**: check package.json in subfolders client/, server/, apps/*, packages/*
- **Empty project**: nothing found → skip Phase 0, go straight to Phase 1
- **Legacy project**: only old deps (node 10, Python 2) — warn user, propose modernization as part of bootstrap
