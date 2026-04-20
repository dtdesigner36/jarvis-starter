# jarvis history — project timeline

## Usage
```
> jarvis history
> jarvis history last-week
> jarvis history architecture
```

## Workflow

Read `.jarvis/timeline.md` (auto-filled + manual via events).

Output in chronological order (newest first).

## What's in timeline.md

Events:
- **Bootstrap** — date and what was installed
- **Evolve** — when an archetype layer was added
- **Major refactor** — big refactors
- **New system** — via `/new-system` or `jarvis new-system`
- **Key decisions** — via `jarvis remember` when category is "architecture"

Format:
```markdown
## 2026-04-20 — Bootstrap
Installed archetypes: telegram-bot, web-app
Stack: Python + Next.js

## 2026-05-15 — Evolve
Added web-api layer (split backend from bot)

## 2026-06-02 — Decision
Chose Prisma over Drizzle (see memory.md)
```

## Filters

- `jarvis history last-week` — events from the last week
- `jarvis history architecture` — architecture-related only
- `jarvis history evolve` — evolve events only
