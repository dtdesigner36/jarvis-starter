---
name: jarvis-starter
description: J.A.R.V.I.S. for your Claude Code project. On start — bootstrap with archetype classification, skill selection, wiki setup. After start — quiet persistent assistant via hooks that maintains wiki, recommends model/plan-mode for tasks, surfaces existing solutions, tracks project evolution. Built for vibe-coders. Bonus optional school-mode plugin for those who want to learn.
user-invocable: true
argument-hint: "start <description> | status | find <need> | evolve | decide | suggest | docs | audit | remember | school"
---

# JARVIS Starter — persistent project assistant

Installed once in a new project. Sets up infrastructure for the detected project type (Telegram bot, web app, API, landing page, game, parser, mobile app, etc.). Then stays as a quiet assistant.

## Modes

### 1. Bootstrap (first invocation in empty/new project)

User writes:
```
> jarvis start: <project description>
```

Or just:
```
> jarvis: <description>
```

JARVIS runs the sequence:
1. **Phase 0** — Brownfield scan (if the folder has `package.json`/`pyproject.toml`/`go.mod`/etc., parse stack before asking questions)
2. **Phase 1** — Classification (see `archive/bootstrap/classification.md`)
3. **Phase 2** — Proposal (stack + skills from registry + GitHub discovery via `on-demand/skill-discovery/`)
4. **Phase 3** — Bootstrap (copies universal templates + archetype-specific overlays)
5. **Phase 4** — Verification + Token audit
6. **Phase 5** — Token optimization advice
7. **Phase 6** — Activate persistent mode (core hooks)

### 2. Persistent mode (after bootstrap)

JARVIS lives in `.jarvis/` and works through core hooks:

**🎯 Core (0 tokens at rest, active via hooks):**
- **Wiki auto-maintenance** — PostToolUse detects events (new module, large edit, new Prisma model) and injects short reminders into the tool result. See `core/wiki-maintenance/`.
- **Task Routing** — UserPromptSubmit analyzes the prompt, classifies complexity (Trivial/Simple/Medium/Complex/Architectural), recommends model and plan mode. See `core/task-routing/`.
- **Memory & Wiki recall** — UserPromptSubmit matches prompt topic against `.jarvis/memory.md` and `wiki/Systems/*.md`, injects a hint "already solved: ...". See `core/memory-recall/`.
- **Focus tracker** — PostToolUse passively updates `.jarvis/focus.md` (shell-only, 0 tokens). See `core/focus-tracker/`.
- **Security watch** — PostToolUse scans for hardcoded secrets and `.env` leaks. See `core/security-watch/`.

**🔍 On-demand commands** (always available, loaded when called):
- `jarvis status` — brief summary
- `jarvis find "<need>"` — find a skill for a specific need (GitHub + registry)
- `jarvis evolve <layer>` — add an archetype layer
- `jarvis decide "<q>"` — help with an architectural decision
- `jarvis suggest` — quality improvement suggestions
- `jarvis docs` — wiki freshness check
- `jarvis audit` — comprehensive audit
- `jarvis security` — security audit
- `jarvis route "<task>"` — manually classify task complexity

**📦 Rare commands:** `remember`, `forget`, `history`, `focus`, `optimize` — in `archive/subcommands-rare/`.

**🔌 Plugins (off by default):**
- `school-mode` — for those who want not just to build but to learn. Creates a separate `school-wiki/` with a topic index for the project's stack. Deep exploration happens only on request via `jarvis school topic <area>`. Activation: `jarvis school on`. NOT proactively offered — user decides.

## For vibe-coders (primary audience)

JARVIS is a "smart programmer friend" for people who:
- Describe ideas in free form
- Don't know which model to pick (Opus vs Sonnet vs Haiku)
- Don't know when to enable plan mode
- Don't know which libraries are worth installing

JARVIS makes these decisions **for them** or **with them**, in plain language.

## For technically literate users

Same hooks, but you can disable the ones that get in the way. All JARVIS decisions are suggestions, not enforcement. If something annoys you — `jarvis off` (or per-hook via `.jarvis/plugins.md`).

## Installation

```bash
# In a new project
npx skills add dtdesigner36/jarvis-starter --yes

# First message in Claude Code
> jarvis start: <project description>
```

## Important rules

1. **Do NOT suggest enabling school-mode** — user decides
2. **Do NOT output status automatically at session start** — only on `jarvis status`
3. **Core hooks work always** after bootstrap (can be disabled via `.jarvis/plugins.md`)
4. **Wiki is mandatory infrastructure** (not optional), Obsidian is optional
5. **Priority: quality > token optimization**

## File architecture

See `README.md` for full structure. Key points:
- `core/` — always-on hooks
- `on-demand/` — on-request commands
- `plugins/` — optional extensions (school-mode)
- `archive/` — bootstrap and rare commands