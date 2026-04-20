---
name: jarvis-starter
description: J.A.R.V.I.S. for your Claude Code project. On start — bootstrap with archetype classification, skill selection, wiki setup. For existing projects — soft adopt via gap analysis (installs only missing features, respects existing config). After start/adopt — quiet persistent assistant via hooks that maintains wiki, recommends model/plan-mode for tasks, surfaces existing solutions, tracks project evolution. Built for vibe-coders. Bonus optional school-mode plugin for those who want to learn.
user-invocable: true
argument-hint: "start <description> | adopt | status | find <need> | evolve | decide | suggest | docs | audit | remember | school"
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
2. **Phase 0.5** — Dev-stage check (see `archive/bootstrap/brownfield-adopt.md`). If ≥2 dev-stage signals hit (≥10 commits, mature lockfile, real `src/`, existing `CLAUDE.md`, living `docs/`, running CI) — **default to Adopt mode**, not Start. User can override with `jarvis start --force`.
3. **Phase 1** — Classification (see `archive/bootstrap/classification.md`)
4. **Phase 2** — Proposal (stack + skills from registry + GitHub discovery via `on-demand/skill-discovery/`)
5. **Phase 3** — Bootstrap (copies universal templates + archetype-specific overlays)
6. **Phase 4** — Verification + Token audit
7. **Phase 5** — Token optimization advice
8. **Phase 6** — Activate persistent mode (core hooks)

### 2. Adopt (existing project in active development)

User writes:
```
> jarvis adopt
```

Or `jarvis start: <desc>` auto-redirects here when Phase 0.5 detects dev-stage signals.

**Philosophy: observe first, install only gaps, respect everything the user already built.**

JARVIS runs (see `archive/bootstrap/brownfield-adopt.md`):
1. **Phase A — Observe** (read-only): stack, existing CLAUDE.md, hooks, docs, secret-scanners, issue tracking
2. **Phase B — Gap analysis**: for each core feature, check if the project already solves that problem. Skip if yes.
3. **Phase C — Proposal**: show interactive gap matrix. User approves / picks features / declines.
4. **Phase D — Soft install**: only checked features, in `.jarvis/` namespace + new `jarvis-*.sh` hook files (never touches existing hooks / CLAUDE.md / docs).
5. **Phase E — Record**: write state to `.jarvis/state.md` including which features were skipped and why.

Hard rules in Adopt mode:
- `.jarvis/` is the only new directory at project root
- `CLAUDE.md` gets **one line** max: `<!-- JARVIS context: see .jarvis/state.md -->`
- Hooks are **new files** (`jarvis-<feature>.sh`), never appended to existing hooks
- `settings.json` is **structurally merged**, never overwritten
- **No archetype overlay** — user can run `jarvis evolve <archetype>` later
- **No `wiki/` created** if `docs/` already exists

### 3. Persistent mode (after bootstrap or adopt)

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
# Install the skill
npx skills add dtdesigner36/jarvis-starter --yes

# New / empty project
> jarvis start: <project description>

# Existing project already in development
> jarvis adopt
```

If you type `jarvis start` in an existing project, JARVIS detects the dev-stage and auto-switches to Adopt (with a confirmation prompt).

## Important rules

1. **Do NOT suggest enabling school-mode** — user decides
2. **Do NOT output status automatically at session start** — only on `jarvis status`
3. **Core hooks work always** after bootstrap (can be disabled via `.jarvis/plugins.md`)
4. **Wiki is mandatory infrastructure** in Start mode; in Adopt mode — respect existing docs, do not create parallel wiki/
5. **Priority: quality > token optimization**
6. **Brownfield-safe default**: when dev-stage is detected, default path is Adopt (gap-analysis, zero overwrite), not Start. See `archive/bootstrap/brownfield-adopt.md`.

## File architecture

See `README.md` for full structure. Key points:
- `core/` — always-on hooks
- `on-demand/` — on-request commands
- `plugins/` — optional extensions (school-mode)
- `archive/` — bootstrap and rare commands