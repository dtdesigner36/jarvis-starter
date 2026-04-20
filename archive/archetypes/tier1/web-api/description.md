# Archetype: web-api

## Default stack
- **NestJS + Prisma + PostgreSQL + TypeScript** (recommended)
- Alternatives: Express + TypeORM, FastAPI + SQLAlchemy (Python), Hono (lightweight)

## Recommended skills
- `/api-contract` — client↔server types sync
- `/db-migrate` — safe migrations
- `/prisma-field` — safely add a field
- `/new-system` — new modules
- `/devlog`

## Wiki structure
```
wiki/
├── Endpoints/
├── Authentication/
├── Database/
└── Versioning/
```

## Triggers
- `*.controller.ts`/`*.service.ts` → `/api-contract`
- `schema.prisma` → `/db-migrate`
- New module in `src/modules/<name>/` → `new-system`
- `*.middleware.ts` / `*.guard.ts` → propose wiki/Architecture/

## Pitfalls
- Validation only on client (no DTO on server) — vulnerability
- Prisma queries in controllers (should be in services)
- Secrets in code instead of .env
- No rate limits on public endpoints
- Synchronous blocking operations

## Evolve paths
- + web-app → full-stack
- + mobile-app → backend for a mobile client
- + llm-agent → AI functionality

## Security essentials

- **Input validation** — all DTOs via `class-validator` or `zod`. Request without validation = vulnerability
- **SQL Injection** — only through Prisma ORM, never `$queryRawUnsafe` with user input
- **Rate limiting** — on all public endpoints (via `@nestjs/throttler` or middleware)
- **JWT** — always set expiration (15min access token), refresh rotation
- **CORS** — whitelist specific origins, not `*`
- **Passwords** — bcrypt cost 12+ or argon2id
- **Helmet/CSP** — protection against common HTTP attacks
- **Don't log secrets** — filter password, token, authorization headers in logger

## Community skill (new, to add)

**Needed:** `openapi-sync` — auto-generates OpenAPI spec from controllers, validates drift between code and spec.

**Not yet in registry** — JARVIS searches for `"openapi nestjs skill"` or `"openapi validator claude code"` at bootstrap. Candidates: nestjs-openapi-validator, swagger-sync.
