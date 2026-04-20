# Contributing to JARVIS-Starter

Thanks for the interest. Three ways to help, roughly in order of usefulness:

## 1. Use it and file a good bug report

The single most valuable thing. Install the skill in a real project, run it, and when something feels off — open a [bug issue](https://github.com/dtdesigner36/jarvis-starter/issues/new?template=bug_report.yml) with:
- What you expected vs what happened
- Minimal reproduction steps
- Your stack and JARVIS mode (`start` / `adopt` / `evolve`)

Adopt-mode on real brownfield projects is the most interesting stress test — edge cases there are gold.

## 2. Propose or contribute a feature

Open a [feature issue](https://github.com/dtdesigner36/jarvis-starter/issues/new?template=feature_request.yml) first if it's non-trivial — it's cheaper to agree on the shape before coding.

For small fixes or clear wins, a PR without prior discussion is fine.

### Architecture ground rules

- **Core hooks stay lean.** 0 tokens at rest, short output when triggered (under ~200 tokens). A feature that can't be cheap at rest belongs in `on-demand/` or a plugin.
- **Brownfield-safe by default.** Anything that touches an existing project must respect existing `CLAUDE.md`, hooks, and docs. Namespace new things under `.jarvis/` or prefixed `jarvis-*.sh` files.
- **Progressive disclosure.** One-shot bootstrap content belongs in `archive/`. If a file is read every session, it's in the hot path and must be small.

## 3. Contribute an archetype or skill-registry entry

- **New archetype** (Tier 2 description-only is the easy on-ramp): open an [archetype issue](https://github.com/dtdesigner36/jarvis-starter/issues/new?template=archetype_request.yml).
- **You built a related Claude Code skill:** open a Discussion under "Show and tell". If it's broadly useful, it goes into the known-skills registry that `jarvis find` consults.

## PR checklist

- Scope: one concern per PR. Split unrelated changes.
- Docs: `SKILL.md` and `README.md` updated if you added/renamed a command or flag.
- Changelog: entry under `[Unreleased]` in `CHANGELOG.md`.
- Tests / manual verification: explain how you tested it in a real Claude Code session.

## Repo layout quick reference

```
skill root/
├── core/                    # Always-on hooks, must stay lean
├── on-demand/               # Commands by explicit call
├── plugins/                 # Optional, off by default
└── archive/
    ├── bootstrap/           # Start & Adopt flows, classification, composition
    ├── archetypes/tier1/    # Full overlays (10 archetypes)
    ├── archetypes/tier2/    # Description-only (19 archetypes)
    └── templates/universal/ # Shared templates
```

## License

By contributing, you agree that your contribution is licensed under the MIT License (see [LICENSE](LICENSE)).
