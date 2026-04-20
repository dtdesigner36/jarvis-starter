# Topic Generator — stub generation algorithm based on stack

## Input

- `.jarvis/state.md` — project stack (framework, lang, DB, deps)
- `package.json` / `pyproject.toml` — dependency list

## Output

A set of `school-wiki/<topic>.md` files + `school-wiki/INDEX.md`.

## Algorithm

1. **Extract tech** from the stack:
   - Framework: Next.js 15, NestJS, Express, FastAPI, python-telegram-bot, grammy, ...
   - Lang features: TypeScript, Python typing, ...
   - Libraries: Prisma, SQLAlchemy, Socket.io, Zustand, React Query, ...
   - Tools: Docker, Tailwind, ESLint, ...

2. **Match against stub-templates/**:
   - For each tech — look for `stub-templates/<tech>.md`
   - If it exists — copy (with `{{PROJECT_PATH}}` placeholder replacement)
   - If not — generate a minimal stub from the template

3. **Generate missing stubs** (for tech without templates):
   ```markdown
   # <Tech>

   **What:** <short description from web-search or built-in knowledge>
   **Where in the project:** <path where it's used>

   → To walk through: jarvis school topic <tech-slug>
   ```

4. **Build INDEX.md**:
   ```markdown
   # School Wiki — Index

   Project topics to learn. Walk through: `jarvis school topic <slug>`.

   ## Framework / Lang
   - [<tech>] — 1 line about it

   ## Libraries
   - [<tech>] — 1 line

   ## Tools
   - [<tech>] — 1 line
   ```

5. **Create progress.md** (empty):
   ```markdown
   # School Progress

   ## Covered
   (empty)

   ## In queue
   (auto-generated from INDEX.md)
   ```

## Which tech warrants a stub

Generate stubs only for things actually worth learning:
- Framework and its lifecycle (Next.js App Router, NestJS modules, ...)
- ORM and migrations (Prisma, SQLAlchemy)
- Auth patterns (JWT, sessions, OAuth)
- State management (Zustand, React Query, context)
- Communication patterns (REST, GraphQL, WebSocket)
- Testing approach if configured
- Deploy / CI if configured

**Do NOT generate stubs for:**
- Utility libs like lodash, ramda — docs are clear enough
- Styles (Tailwind — a separate big topic, only if the user explicitly doesn't know it)
- Specific libs like uuid, zod — use-as-needed

## Number of topics

Typical project: 10-20 topics. Too many — user gets lost. Too few — something important is missing.

Balance: key stack concepts + critical libraries.