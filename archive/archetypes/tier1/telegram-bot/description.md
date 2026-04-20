# Archetype: telegram-bot

## Default stack
- **Python option:** python-telegram-bot 21+ or aiogram 3+ / SQLite or PostgreSQL / Docker
- **Node option:** grammy + TypeScript / better-sqlite3 or Prisma+PostgreSQL

## Recommended skills
- `/api-contract` (if the bot uses its own REST API)
- `/db-migrate` (if Prisma/Alembic)
- `/new-system` (for new command handlers)
- `/devlog`

**Agent skills:** none of the design ones (not needed for a bot)

## Wiki structure
```
wiki/
├── HOME.md
├── Systems/
├── Architecture/
├── Commands/          # ← bot-specific
├── Handlers/          # ← bot-specific
├── Integrations/      # ← Telegram API, webhook URLs, etc.
└── Devlog/
```

## Triggers specific to this archetype

- New file in `handlers/` → propose wiki/Commands/<Name>.md
- Changes to `main.py` / `bot.ts` — bot entry file → warn about restart
- `.env` edits touching BOT_TOKEN → reminder not to commit

## Typical pitfalls
1. Bot token in git — critical error (use .env, .gitignore)
2. Polling + Webhook at the same time — doesn't work, pick one
3. Long-running handlers block polling — use async
4. Commands with parameters not handled (/start arg)
5. User state not preserved between messages — needs persistence

## What to suggest at bootstrap
- Set up logging from day one
- Middleware for rate limits
- User state storage choice (memory → DB as you scale)
- Dockerfile for easy deploy

## Evolve paths
- + web-app → add admin panel/dashboard
- + web-api → extract business logic into a separate API
- + real-time-app → usually not applicable
- + e-commerce → if the bot sells something

## Security essentials

- **Bot token** — ONLY in `.env`, never in code. Check regex `[0-9]{8,10}:[A-Za-z0-9_-]{35,}` (secret-scanner does this)
- **Webhook signature** — if webhook-based, always verify `X-Telegram-Bot-Api-Secret-Token`
- **Rate limits** — on handlers, especially `/start` and commands that hit the DB
- **User input sanitization** — if you echo user input back to other users, sanitize HTML/Markdown
- **Admin commands** — check `user_id` before admin commands, not username (changes)
- **Payments** — only via Telegram Payments API, not self-hosted

## Community skill (new, to add)

**Needed:** a bot-testing skill — simulate bot interactions (commands, callback queries, inline) for dev tests.

**Not yet in registry** — JARVIS runs `jarvis find "telegram bot testing"` at bootstrap to find a current option on GitHub (e.g., `telegram-bot-tester`, `pytest-telegram`, etc.). If nothing fits — propose creating one via skill-creator.
