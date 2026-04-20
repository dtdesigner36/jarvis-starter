# Bootstrap Phase 1 — Project Classification

Determines the archetype(s) of a new project based on the user prompt.

## Input

- User prompt (project description)
- Results from `brownfield-scan.md` (if the folder already has stack files)

## Algorithm

### 1. Prompt parsing — signal extraction

**Keywords → signals:**

| Keywords in prompt | Archetype signal |
|--------------------|------------------|
| telegram, bot, @botname, /start, grammy, python-telegram-bot | `telegram-bot` |
| discord, discord.js, guild, slash command | `discord-bot` |
| slack, @slack/bolt, slack bot | `slack-bot` |
| trading bot, crypto, trading, exchange | `trading-bot` |
| website, landing, marketing, one-pager, SEO | `landing` |
| blog, MDX, Astro, articles | `blog` |
| portfolio, resume, CV | `portfolio` |
| documentation, docs, Docusaurus, Vitepress, MkDocs | `documentation-site` |
| web app, SPA, React, Next.js, Vue, dashboard | `web-app` |
| SaaS, auth + billing, subscription, multi-tenant | `saas-app` |
| store, e-commerce, products, cart, checkout | `e-commerce` |
| dashboard, analytics, BI, data visualization | `data-dashboard` |
| real-time, WebSocket, WebRTC, chat, messenger | `real-time-app` |
| API, REST, GraphQL, backend, server, endpoint | `web-api` |
| webhook, receive events | `webhook-handler` |
| cron, scheduled, worker, background job | `cron-scheduler` |
| ML serving, FastAPI + model, inference endpoint | `ml-api` |
| parser, scraper, playwright, beautifulsoup, collect data | `parser` |
| ETL, pipeline, data processing | `data-pipeline` |
| ML model, training, train a model | `ml-model` |
| AI agent, LLM, Claude Agent SDK, LangChain, automation | `llm-agent` |
| browser game, HTML5, Phaser, Three.js, game | `browser-game` |
| multiplayer game, Colyseus, multiplayer | `game-multiplayer` |
| mobile, iOS, Android, React Native, Expo, Flutter | `mobile-app` |
| desktop, Electron, Tauri | `desktop` |
| extension, plugin, Obsidian plugin, VSCode extension, Chrome | `extension` |
| library, npm package, PyPI package, SDK | `library` |
| CLI, console, command-line | `cli-tool` |

### 2. Scoring

Each signal is weighted based on:
- **Match count** (if "bot" is mentioned 3 times + "telegram" 2 times → high score for telegram-bot)
- **Brownfield confirmation** (if package.json has `grammy` → +50 to telegram-bot score)
- **Negative signals** (if user explicitly says "no UI" — exclude web-app)

### 3. Type determination

- **Single archetype** (one clear score leader) → bootstrap with one archetype
- **Composite** (two-three archetypes with high scores) → composition (see `composition.md`)
- **Ambiguous** (no clear leader) → AskUserQuestion for clarification
- **Unknown** (all scores < threshold) → Phase 1b (`phase1b-template.md`)

### 4. Confirmation

Before bootstrap, show the user:
```
💠 JARVIS: detected: <archetype(s)>.
   Default stack: <stack>.
   Is this correct? (y/n/other)
```

If the user adjusts — recompute with their clarifications.

## Thresholds

- Single: score >= 50
- Composite: 2-3 archetypes with score >= 30 each
- Ambiguous: all < 30 → ask
- Unknown: even after questions no match → Phase 1b
