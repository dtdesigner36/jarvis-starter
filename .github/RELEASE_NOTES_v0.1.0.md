## Highlights

**Two ways to install JARVIS in a Claude Code project:**

- 🆕 **`jarvis start`** — classify the project type, pick a stack, roll out hooks + wiki + skills.
- 🤝 **`jarvis adopt`** — for brownfield projects. Runs a gap analysis and installs only the missing features in `.jarvis/` + new `jarvis-*.sh` hook files. Never touches your existing `CLAUDE.md`, hooks, or docs. Auto-triggered when ≥2 dev-stage signals are detected.

**Always-on hooks (0 tokens at rest):**

- 📝 `wiki-maintenance` — keeps docs in sync with code
- 🎯 `task-routing` — recommends the right model + plan-mode per task
- 🧠 `memory-recall` — surfaces "already solved" answers from project memory
- 📍 `focus-tracker` — passive current-focus tracking
- 🔒 `security-watch` — hardcoded-secret and `.env` leak detection

**10 Tier-1 archetypes** (telegram-bot, web-app, web-api, landing, game, parser, mobile-app, desktop, library, llm-agent) + **19 Tier-2 descriptions** with runtime-generated overlays.

**Plugin:** `school-mode` (opt-in) — learn your stack through topic-based lesson dialogues.

## Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

Then in Claude Code:

```
> jarvis start: <what you want to build>
# or
> jarvis adopt
```

## Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).

## Acknowledgments

Built on patterns from [@alinaqi](https://github.com/alinaqi/claude-bootstrap), [@pbakaus](https://github.com/pbakaus/impeccable), [@emilkowalski](https://github.com/emilkowalski/skill), [@leonxlnx](https://github.com/leonxlnx/taste-skill), [anthropics/skills](https://github.com/anthropics/skills), [@wcpaxx](https://github.com/wcpaxx/spec-kit-brownfield-extensions), [@travisvn](https://github.com/travisvn/awesome-claude-skills). Full attribution in [NOTICE.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/NOTICE.md).
