# Known Skills Registry

Curated list of community-verified skills JARVIS knows about. Used when GitHub search is unavailable or returned nothing relevant. The `Stack-tags` column drives ranking in `core/skill-discovery/stack-matcher.sh`.

## Table format

`Stack-tags` is a comma-separated list of technologies (no spaces). The more tags overlap with the project stack (from `.jarvis/state.md`), the higher the score. If `-` is set — match by archetype only.

## Backend / API

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| `anthropics/skills#api-validator` | REST API contract validation | web-api, bot-with-api | rest,openapi,api,contract |
| (built-in) `api-contract` | Client↔server type sync check | web-api | typescript,trpc,zod,rest |
| (built-in) `db-migrate` | Safe Prisma migrations | web-api | prisma,postgres,mysql,sqlite,migrations |

## Frontend / UI / Design

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| `emilkowalski/skill` | emil-design-eng — UI polish philosophy | web-app, landing | react,nextjs,tailwind,ui,polish |
| `pbakaus/impeccable` | 20+ design skills (polish, typeset, colorize, animate, audit) | web-app, landing, mobile-app | tailwind,react,vue,svelte,css,ui,design |
| `leonxlnx/taste-skill` | high-end-visual-design, stitch-design-taste | web-app, landing | react,vue,nextjs,tailwind,design |
| (built-in) `css-audit` | Tokens and dead selectors | web-app | css,tailwind,scss,postcss |
| (built-in) `responsive-check` | Mobile/tablet adaptivity | web-app, mobile-app | tailwind,css,responsive |
| (built-in) `i18n-sync` | t()/ts() synchronization | web-app, mobile-app | i18next,next-intl,vue-i18n,react-intl |

## Game Dev

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| `anthropics/skills#phaser-gamedev` | Phaser 3 scripts and scenes | browser-game, game-multiplayer | phaser,canvas,webgl |
| (built-in) `playtest` | E2E game scenario walkthrough | game | playwright,puppeteer,e2e |
| (built-in) `balance` | Game balance | game | - |

## AI / LLM

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| `anthropics/skills#claude-api` | Claude API usage patterns | llm-agent | anthropic,claude,llm,sdk |

## Testing / QA

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| `anthropics/skills#playwright-skill` | Browser automation | web-app, parser | playwright,e2e,browser,scraping |

## Universal (all archetypes)

| Package | Description | Archetypes | Stack-tags |
|---------|-------------|------------|------------|
| (built-in) `devlog` | Dated entries in wiki/Devlog | * | - |
| (built-in) `new-system` | Scaffold wiki/Systems/<Name>.md | * | - |
| (built-in) `obsidian-canvas` | Generate .canvas diagrams | * | - |

## Adding to the registry

New verified skills are added here manually after being proven on several projects. Automatic GitHub discovery proposes but does not add to the registry — the user does via `jarvis remember "skill X proved useful for Y archetype"`.

## Stack-tags: canonical names

Use these (for parser consistency in `stack-matcher.sh`):

- **Frontend frameworks**: react, vue, svelte, angular, solid
- **Meta-frameworks**: nextjs, remix, nuxt, sveltekit, astro
- **Styling**: tailwind, css, scss, postcss, styled-components, emotion
- **Backend frameworks**: express, nestjs, fastify, fastapi, django, flask, rails
- **Databases / ORMs**: prisma, drizzle, postgres, mysql, sqlite, redis, mongodb
- **Bot libs**: aiogram, python-telegram-bot, grammy, discord.js
- **Game**: phaser, three, canvas, webgl
- **Testing**: playwright, puppeteer, jest, vitest, cypress, e2e
- **Mobile**: expo, react-native
- **Languages**: typescript, python, rust, go
- **AI**: anthropic, claude, llm, sdk, langchain
- **Misc**: scraping, openapi, rest, graphql, grpc, ws, webhook, polling

If the stack isn't covered — add the tag and update the registry.
