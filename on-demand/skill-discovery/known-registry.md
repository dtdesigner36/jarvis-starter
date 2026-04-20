# Known Skills Registry

Curated list of community-verified skills JARVIS knows about. Used when GitHub search is unavailable or returned nothing relevant.

## Backend / API

| Package | Description | Archetypes |
|---------|-------------|------------|
| `anthropics/skills#api-validator` | REST API contract validation | web-api, bot with API |
| (built-in) `api-contract` | Client↔server type sync check | web-api |
| (built-in) `db-migrate` | Safe Prisma migrations | web-api with Prisma |

## Frontend / UI / Design

| Package | Description | Archetypes |
|---------|-------------|------------|
| `emilkowalski/skill` | emil-design-eng — UI polish philosophy | web-app, landing |
| `pbakaus/impeccable` | 20+ design skills (impeccable, polish, typeset, colorize, animate, audit) | web-app, landing, mobile-app |
| `leonxlnx/taste-skill` | high-end-visual-design, stitch-design-taste | web-app, landing |
| (built-in) `css-audit` | Tokens and dead selectors | web-app |
| (built-in) `responsive-check` | Mobile/tablet adaptivity | web-app, mobile-app |
| (built-in) `i18n-sync` | t()/ts() synchronization | web-app, mobile-app |

## Game Dev

| Package | Description | Archetypes |
|---------|-------------|------------|
| `anthropics/skills#phaser-gamedev` | Phaser 3 scripts and scenes | browser-game, game-multiplayer |
| (built-in) `playtest` | E2E game scenario walkthrough | game |
| (built-in) `balance` | Game balance | game |

## AI / LLM

| Package | Description | Archetypes |
|---------|-------------|------------|
| `anthropics/skills#claude-api` | Claude API usage patterns | llm-agent |

## Testing / QA

| Package | Description | Archetypes |
|---------|-------------|------------|
| `anthropics/skills#playwright-skill` | Browser automation | web-app, parser |

## Universal (all archetypes)

| Package | Description |
|---------|-------------|
| (built-in) `devlog` | Dated entries in wiki/Devlog |
| (built-in) `new-system` | Scaffold wiki/Systems/<Name>.md |
| (built-in) `obsidian-canvas` | Generate .canvas diagrams |

## Adding to the registry

New verified skills are added here manually after being proven on several projects. Automatic GitHub discovery proposes but does not add to the registry — the user does via `jarvis remember "skill X proved useful for Y archetype"`.