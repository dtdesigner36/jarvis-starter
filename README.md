# JARVIS-Starter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code Skill](https://img.shields.io/badge/Claude_Code-Skill-7C3AED)](https://claude.com/claude-code)
[![GitHub release](https://img.shields.io/github/v/release/dtdesigner36/jarvis-starter?include_prereleases&label=release)](https://github.com/dtdesigner36/jarvis-starter/releases)
[![GitHub stars](https://img.shields.io/github/stars/dtdesigner36/jarvis-starter?style=social)](https://github.com/dtdesigner36/jarvis-starter/stargazers)

**A persistent project assistant for Claude Code.** Bootstraps new projects, softly adopts existing ones, and stays as a quiet helper — maintaining the wiki, recommending the right model per task, surfacing past decisions, and tracking how the project evolves.

Built for **vibe-coders** first: people who describe ideas in plain language and want the right defaults picked for them. Works for technically literate users too — every decision is optional, and you can switch off anything that gets in the way.

---

## 60-second tour

```bash
# 1. Install the skill in your project
npx skills add dtdesigner36/jarvis-starter --yes
```

```text
# 2a. New project? Start fresh:
> jarvis start: Telegram bot for reminders with a Next.js admin panel

# 2b. Existing project? Adopt without breaking anything:
> jarvis adopt
```

```text
# 3. That's it. JARVIS lives in .jarvis/ and runs via hooks.
#    Need something? Ask it:
> jarvis status
> jarvis route "refactor the auth module"
> jarvis find "pdf parser"
> jarvis audit
```

---

## Why this exists

Starting a Claude Code project means re-inventing the same scaffolding every time: `CLAUDE.md` rules, hooks, wiki, which skills to install, which model to pick for which task. And once the project grows, keeping docs and decisions in sync with the code is a losing battle.

JARVIS solves both:

- **On start** — sets up architecture for the project type (Telegram bot, web app, API, landing, game, parser, mobile, library, CLI, LLM-agent, and more) using archetype-specific overlays.
- **On adopt** — for existing projects, runs a gap analysis and installs **only the features you're missing**. Never touches your CLAUDE.md, hooks, or docs. Everything new lives in `.jarvis/` or in separate `jarvis-*.sh` hook files.
- **Ongoing** — passive hooks maintain the wiki, recommend the right model (Opus / Sonnet / Haiku) and plan-mode for each task, resurface already-solved problems, and track project evolution. **0 tokens at rest**.

---

## Two modes of installation

### New project — `jarvis start`

```
> jarvis start: <description of what you want to build>
```

JARVIS walks you through:
1. Requirements clarification
2. Stack selection
3. Relevant skill picks (local registry + GitHub discovery)
4. Infrastructure rollout (CLAUDE.md, hooks, wiki/, skills)
5. Initial optimization advice

### Existing project — `jarvis adopt`

```
> jarvis adopt
```

**Soft integration via gap analysis.** JARVIS:
- Reads your project (stack, CLAUDE.md, hooks, docs, secret-scanners, issue tracking)
- Detects what you already have (living docs, husky pre-commit, linear integration, etc.)
- Shows a gap matrix — proposes **only the features you're missing**
- Installs those features in `.jarvis/` namespace + new `jarvis-*.sh` hook files
- Leaves your existing CLAUDE.md, hooks, and docs untouched

If you run `jarvis start` in an existing project, JARVIS detects the dev-stage (git history, mature lockfile, existing CLAUDE.md, living docs, CI) and auto-switches to Adopt. Force full bootstrap with `jarvis start --force` if you really mean it.

---

## Commands (after install)

JARVIS commands come in two flavours. The **executable** ones run shell scripts directly. The **model-prompted** ones are markdown instruction files that Claude reads on demand — they guide Claude through a workflow, they are not standalone programs.

**Executable shell commands:**

| Command | What it does |
|---------|--------------|
| `jarvis self-audit` | Inventories which JARVIS hooks actually fired, usage counts, stale wiki, real shell output |
| `jarvis adopt` | Soft-integrate into an existing project (gap analysis, no overwrite) |

**Model-prompted workflows (markdown Claude reads when invoked):**

| Command | What it does |
|---------|--------------|
| `jarvis` or `jarvis status` | Brief project summary (Claude reads `.jarvis/state.md` + `focus.md`) |
| `jarvis route "<task>"` | Model / plan-mode recommendation for a task |
| `jarvis find "<need>"` | Claude searches the curated registry + suggests a GitHub query (no install) |
| `jarvis evolve <layer>` | Claude applies an archetype overlay |
| `jarvis decide "<q>"` | Help with an architectural decision |
| `jarvis suggest` | Quality improvement suggestions |
| `jarvis docs` | Check wiki freshness |
| `jarvis audit` | Comprehensive project audit |
| `jarvis security` | Security audit |
| `jarvis remember "<fact>"` | Record a decision in project memory |
| `jarvis history` | Timeline of project events |

---

## Plugins (off by default)

### school-mode — for those who want to learn, not just build

```
> jarvis school on
```

Creates a `school-wiki/` with a topic index for your stack. Each topic is a short stub — *what it is, where it lives in this project*. When you want to go deep:

```
> jarvis school topic prisma-migrations

JARVIS: Let's walk through migrations. In your project:
  - 3 migrations (latest one 5 days ago)
  - Schema has X models

  What do you already know about migrations in general? Have you ever
  dropped a column from an existing table?
  ...
```

Turn off with `jarvis school off`. JARVIS never proactively suggests school-mode — it's your call.

---

## Architecture

```
jarvis-starter/
├── SKILL.md                  # Entry point
├── README.md                 # This file
├── NOTICE.md                 # Attributions
│
├── core/                     # Always-on hooks (0 tokens at rest)
│   ├── wiki-maintenance/     # Watches code → proposes wiki updates
│   ├── task-routing/         # Classifies prompts → recommends model
│   ├── memory-recall/        # Surfaces already-resolved topics
│   ├── focus-tracker/        # Passively tracks current focus
│   └── security-watch/       # Detects hardcoded secrets and .env leaks
│
├── on-demand/                # Markdown instructions Claude reads on demand
│   ├── skill-discovery/      # jarvis find — registry match + GitHub query hints
│   ├── security/             # jarvis security — audit workflow
│   ├── evolve.md             # jarvis evolve
│   ├── decide.md             # jarvis decide
│   ├── suggest.md            # jarvis suggest
│   ├── docs.md               # jarvis docs
│   ├── audit.md              # jarvis audit
│   └── self-audit/           # jarvis self-audit — real shell script (scripts + report.sh)
│
├── plugins/                  # Optional extensions (off by default)
│   └── school-mode/
│
└── archive/                  # Rarely needed after bootstrap
    ├── bootstrap/            # Phase 0-6 bootstrap + brownfield-adopt
    ├── archetypes/           # Tier 1 (10 full) + Tier 2 (19 descriptions)
    ├── templates/            # Universal + archetype overlays
    └── subcommands-rare/     # remember, forget, history, focus, optimize
```

---

## Philosophy

1. **Quality > optimization** — but both matter
2. **Quiet butler** — silent until called
3. **Plain language** — for vibe-coders
4. **Wiki as first-class** — always current, via hooks
5. **Respect what's already there** — brownfield-safe by default (Adopt mode)
6. **Extensible** — plugins for different work modes

---

## Roadmap & changelog

- Planned features and current priorities → [GitHub Issues](https://github.com/dtdesigner36/jarvis-starter/issues) and [Releases](https://github.com/dtdesigner36/jarvis-starter/releases)
- Full changelog → [CHANGELOG.md](CHANGELOG.md)

## Contributing

Issues, feature suggestions, and PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to file a good bug report or propose a feature. Discussion happens in [GitHub Discussions](https://github.com/dtdesigner36/jarvis-starter/discussions).

If you've built a related Claude Code skill, open an issue — happy to add it to the known-skills registry referenced by `jarvis find`.

---

## 🙏 Credits & Acknowledgments

JARVIS-Starter stands on the shoulders of others:

- **[@alinaqi](https://github.com/alinaqi/claude-bootstrap)** — orchestration patterns, Stop Hooks approach, and persistent memory concepts in claude-bootstrap
- **[@pbakaus](https://github.com/pbakaus/impeccable)** — Context Gathering Protocol, `.impeccable.md` persistence pattern, design philosophy, and design-skill templates. The foundation for JARVIS's "context first" approach
- **[Emil Kowalski](https://github.com/emilkowalski/skill)** — UI polish philosophy and the "invisible details" design engineering mindset
- **[@leonxlnx](https://github.com/leonxlnx/taste-skill)** — agency-level design direction and the visual taste framework
- **[Anthropic](https://github.com/anthropics/skills)** — skill-creator patterns (progressive disclosure, description optimization, subagent testing loops)
- **[@wcpaxx](https://github.com/wcpaxx/spec-kit-brownfield-extensions)** — brownfield detection approach and the "analyze before asking" idea
- **[@travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills)** — curated community registry as a reference for our skill-discovery

Each solved a piece of the puzzle of embedding Claude into a workflow. JARVIS combines these ideas and adds its own angle: **a persistent assistant across the project's lifetime**, not a one-shot bootstrap.

---

## License

MIT — see [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md) for formal attributions.
