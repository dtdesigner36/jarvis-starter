# jarvis remember — record a fact

## Usage
```
> jarvis remember "<fact>"
> jarvis remember "API uses bearer token, not sessions"
```

## Workflow

1. Read `.jarvis/memory.md` (or create if missing)
2. Add an entry:
   ```markdown
   ### <YYYY-MM-DD> — <category auto-detected or from keywords>
   <fact>
   ```
3. Evaluate — should this become a full wiki/Architecture/<topic>.md entry?
   - If it's a big architectural decision → propose a wiki entry
   - If it's a small preference → stays only in memory.md

## Categories (auto-detect by keywords)

- **auth**: auth, login, token, session, jwt, bcrypt
- **api**: api, endpoint, rest, graphql
- **data**: database, schema, prisma, migration
- **ui**: design, style, component, theme
- **architecture**: pattern, approach, middleware
- **preference**: prefer, don't like, better, avoid

## memory.md format

```markdown
# JARVIS Memory

## Architecture decisions

### 2026-04-20 — auth
API uses bearer token, not sessions

### 2026-04-15 — data
sessions stored in Prisma Session table, not Redis

## Preferences

### 2026-04-18 — ui
Dark background by default, light mode is an option
```
