# Bootstrap — Archetype Composition

How to combine several archetypes in one project.

## When composition is needed

- User mentioned 2+ areas: "bot + web admin", "API + front + mobile"
- Brownfield detect found signals of several archetypes
- Ambiguous case — two archetypes with close scores

## Common combinations

| Combination | Scenario |
|-------------|----------|
| `telegram-bot` + `web-app` | Bot + browser admin |
| `telegram-bot` + `web-api` | Bot uses its own REST API |
| `web-app` + `web-api` | SPA + backend (monorepo or separate) |
| `game-multiplayer` + `web-api` | Online game with server |
| `mobile-app` + `web-api` | Mobile app + backend |
| `parser` + `data-dashboard` | Scraping + visualization |
| `saas-app` + `e-commerce` | Full-stack SaaS with payments |
| `llm-agent` + `web-api` | AI agent with endpoints |
| `web-app` + `real-time-app` | Dashboard with WebSocket updates |

## Merge logic

### CLAUDE.md
Interleave Skills Trigger Rules from all archetypes:
- Keep common rules on top
- Backend / Frontend / Mobile / Game sections — one after another
- Deduplicate repeating rules

### Hooks
Combine hook scripts:
- Each archetype adds its patterns to post-edit.sh
- Common patterns (schema.prisma, controller.ts) — once

### Wiki structure
All archetype wiki folders:
- From web-app: `Components/`, `Design/`, `Pages/`, `Theming/`
- From web-api: `Endpoints/`, `Authentication/`, `Database/`
- Overlaps — one folder shared

### Agent Skills
Union of recommended skills:
- web-app: impeccable, polish, shape, typeset, colorize, animate, audit
- web-api: (none of the design ones)
- Result: impeccable family is installed (web-app needs it)

### Conflicts

- **Different stacks for the same role**: if brownfield says Next.js but the user mentioned Vue — ask. Can't choose automatically.
- **Stack vs architecture**: if game-multiplayer implies Socket.io but the user picked REST — allow but warn.

## Composite bootstrap process

1. Determine all archetypes (via classification + brownfield)
2. Show the user a proposal:
```
💠 JARVIS: detected: telegram-bot + web-app.

Will deploy:
  - Python bot (python-telegram-bot) + Next.js dashboard
  - Shared PostgreSQL + Prisma
  - Wiki: common base + layer-specific folders
  - Skills: base backend + impeccable/polish for UI

OK? Or split into two parts / change the stack?
```

3. After confirmation, apply overlays **in dependency order**:
   - Base ones first (library/cli)
   - Then the main one (telegram-bot)
   - Then additional ones (web-app)

4. Merge CLAUDE.md sections without duplication

5. Record all active archetypes in `.jarvis/state.md` for later use (evolve, audit, etc.)

## Evolve into composition

If the project started with one archetype and grew — use `jarvis evolve <second-archetype>` (see `../../../on-demand/evolve.md`).

Composition at bootstrap ≈ evolve right after bootstrap, but more efficient — all at once.
