# JARVIS-Starter

Persistent assistant for Claude Code projects. Bootstrap + permanent helper in one skill.

## What it is

J.A.R.V.I.S. (from Iron Man) for your project:
- **On start**: sets up architecture for the project type (bot, web, API, landing, game, parser, mobile)
- **Ongoing**: maintains wiki, recommends the right model for each task, surfaces past decisions, tracks evolution
- **Quietly**: 0 tokens at rest (all via hooks), active only when really needed

## Who it's for

Primarily — **vibe-coders**. People who describe ideas but don't dive deep into programming. JARVIS acts as a "smart friend" who guides them.

Technically literate users — also fits. All JARVIS decisions are optional.

## Installation

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

### New project

```
> jarvis start: <description of what you want to build>
```

Example:
```
> jarvis start: Telegram bot for reminders with a Next.js admin panel
```

JARVIS will walk you through:
1. Requirements clarification
2. Stack selection
3. Relevant skill picks (local registry + GitHub discovery)
4. Infrastructure rollout (CLAUDE.md, hooks, wiki/, skills)
5. Initial optimization advice

### Existing project (already in development)

```
> jarvis adopt
```

Soft integration via **gap analysis**. JARVIS reads your project, detects what's already in place (docs, hooks, secret-scanners, model rules), and installs **only the features you're missing**. Does not touch existing CLAUDE.md, hooks, or docs. Everything JARVIS adds lives in `.jarvis/` or in new `jarvis-*.sh` hook files.

If you run `jarvis start` in an existing project, JARVIS detects the dev-stage and auto-switches to Adopt (with a confirmation prompt). Force full bootstrap with `jarvis start --force` if needed.

## After bootstrap / adopt — commands

| Command | What it does |
|---------|--------------|
| `jarvis` or `jarvis status` | Brief project summary |
| `jarvis adopt` | Soft-integrate into an existing project (gap analysis, no overwrite) |
| `jarvis route "<task>"` | Model/plan recommendation for the task |
| `jarvis find "<need>"` | Find a GitHub skill for a specific need |
| `jarvis evolve <layer>` | Add an archetype layer (e.g., bot → bot+web) |
| `jarvis decide "<q>"` | Help with an architectural decision |
| `jarvis suggest` | Quality improvement suggestions |
| `jarvis docs` | Check wiki freshness |
| `jarvis audit` | Comprehensive project audit |
| `jarvis security` | Security audit |
| `jarvis remember "<fact>"` | Record a decision in project memory |
| `jarvis history` | Timeline of project events |

## Plugins (off by default)

### school-mode

For those who want to **learn**, not just build.

```
> jarvis school on
```

Creates `school-wiki/` with a topic index for your project's stack. Each topic is a short stub with "what it is, where it lives in this project". When you want to go deep — call `jarvis school topic <area>` and JARVIS runs a lesson dialogue on that topic.

```
> jarvis school topic prisma-migrations

JARVIS: Let's walk through migrations. In your project:
  - 3 migrations (latest one 5 days ago)
  - Schema has X models

  What do you already know about migrations in general? Have you ever dropped a column from an existing table?
  ...
```

Turn off with `jarvis school off`.

## Architecture

```
tools/jarvis-starter/
├── SKILL.md                  # Entry point
├── README.md                 # This file
├── NOTICE.md                 # Attributions
│
├── core/                     # Always-on hooks
│   ├── wiki-maintenance/     # Watches code → proposes wiki updates
│   ├── task-routing/         # Classifies prompts → recommends model
│   ├── memory-recall/        # Surfaces already-resolved topics
│   ├── focus-tracker/        # Passively tracks current focus
│   └── security-watch/       # Detects hardcoded secrets and .env leaks
│
├── on-demand/                # On-request commands
│   ├── skill-discovery/      # jarvis find — skill search
│   ├── security/             # jarvis security — security commands
│   ├── evolve.md             # jarvis evolve
│   ├── decide.md             # jarvis decide
│   ├── suggest.md            # jarvis suggest
│   ├── docs.md               # jarvis docs
│   └── audit.md              # jarvis audit
│
├── plugins/                  # Optional extensions
│   └── school-mode/
│
└── archive/                  # Rarely needed after bootstrap
    ├── bootstrap/            # Phase 0-5 bootstrap logic
    ├── archetypes/           # Tier 1 (10 full) + Tier 2 (19 descriptions)
    ├── templates/            # Universal + archetype overlays
    └── subcommands-rare/     # remember, forget, history, focus, optimize
```

## Philosophy

1. **Quality > optimization** — but both matter
2. **Quiet butler** — silent until called
3. **Plain language** — for vibe-coders
4. **Wiki as first-class** — always current, via hooks
5. **Extensible** — plugins for different work modes

## 🙏 Credits & Acknowledgments

JARVIS-Starter stands on the shoulders of other people and projects. Huge thanks to:

- **[@alinaqi](https://github.com/alinaqi/claude-bootstrap)** — for orchestration patterns, Stop Hooks approach, and persistent memory concepts in claude-bootstrap
- **[@pbakaus](https://github.com/pbakaus/impeccable)** — for the Context Gathering Protocol, `.impeccable.md` persistence pattern, design philosophy, and design-skill templates. This skill is the foundation for JARVIS's "context first" approach
- **[Emil Kowalski](https://github.com/emilkowalski/skill)** — for the UI polish philosophy and the "invisible details" design engineering mindset
- **[@leonxlnx](https://github.com/leonxlnx/taste-skill)** — for agency-level design direction and the visual taste framework
- **[Anthropic](https://github.com/anthropics/skills)** — for skill-creator patterns (progressive disclosure, description optimization, subagent testing loops)
- **[@wcpaxx](https://github.com/wcpaxx/spec-kit-brownfield-extensions)** — for the brownfield detection approach and the "analyze before asking" idea
- **[@travisvn](https://github.com/travisvn/awesome-claude-skills)** — for the curated community registry as a reference for our skill-discovery

Each of them solved a piece of the puzzle of embedding Claude into workflow. JARVIS combines these ideas and adds its own angle: **a persistent assistant across the project's lifetime**, not a one-shot bootstrap.

**Special thanks to the open-source Claude Code skills community** — people who share their solutions make the tool better for everyone. If you've built a useful skill — let me know, I'll add it to the known-registry.

---

## License

MIT. See [NOTICE.md](NOTICE.md) for formal attributions and license compatibility.