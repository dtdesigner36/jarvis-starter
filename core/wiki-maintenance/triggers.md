# Wiki Maintenance Triggers

Table of events detected by `hook-detector.sh` and the reactions it proposes.

## Triggers to create wiki entries

| Event | File pattern | JARVIS action |
|-------|--------------|---------------|
| New NestJS module | `(server/)?src/modules/<name>/` | Propose `wiki/Systems/<Name>.md` |
| New React feature | `(client/)?src/features/<name>/` | Propose `wiki/Systems/<Name>.md` |
| New bot handler | `handlers/<name>/` | Propose `wiki/Commands/<Name>.md` |
| New scraper | `scrapers/<name>/` | Propose `wiki/Sources/<Name>.md` |

## Triggers to update existing wiki

| Event | Action |
|-------|--------|
| `schema.prisma` changed | Remind to update `wiki/Canvas/PrismaSchema.canvas` |
| 3+ files in the same module in one session | Remind that `wiki/Systems/<X>.md` may be stale |
| Architectural pattern (middleware, guard, decorator) | Propose a `wiki/Architecture/` entry |

## "Wiki is stale" triggers

| Event | Action |
|-------|--------|
| wiki not touched 14+ days + active code | On any Edit, remind `jarvis docs` |
| Large refactor (10+ files per session) | After session, suggest `jarvis docs` |

## Anti-spam rules

- Each "wiki is stale" reminder — **at most once every 7 days**
- Flag `.jarvis/last-wiki-warning` for tracking
- For a single module, the "create wiki" suggestion fires only once (after create or decline)
- If the user explicitly says "don't create wiki for X" — remember in `.jarvis/memory.md`

## What does NOT trigger a reminder

- Edits to already-existing files (not a new module)
- Formatting changes (whitespace, semicolons)
- Edits to `.gitignore`, `package.json`, `tsconfig.json` (metadata)
- Edits inside `node_modules/`, `.next/`, `dist/`, `build/`