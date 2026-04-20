# Changelog

All notable changes to JARVIS-Starter are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] — 2026-04-21

First public release.

### Added

- **Bootstrap mode (`jarvis start`)** — archetype classification, stack proposal, skill discovery, template rollout, verification, token optimization, persistent-mode activation across Phases 0–6.
- **Adopt mode (`jarvis adopt`)** — soft integration for brownfield projects. Runs a gap analysis per core feature and installs only what's missing, in the `.jarvis/` namespace + new `jarvis-*.sh` hook files. Never touches existing `CLAUDE.md`, hooks, or docs. Auto-triggered when ≥2 dev-stage signals are detected (git history, mature lockfile, real `src/`, existing `CLAUDE.md`, living docs, CI). See [archive/bootstrap/brownfield-adopt.md](archive/bootstrap/brownfield-adopt.md).
- **Core hooks (always-on, 0 tokens at rest):**
  - `wiki-maintenance` — PostToolUse detects events (new module, large edit, new Prisma model) and injects short reminders.
  - `task-routing` — UserPromptSubmit classifies complexity (Trivial/Simple/Medium/Complex/Architectural), recommends model + plan-mode.
  - `memory-recall` — matches prompt topic against `.jarvis/memory.md` and `wiki/Systems/*.md`, surfaces "already solved: …" hints.
  - `focus-tracker` — passively updates `.jarvis/focus.md` (shell-only, 0 tokens).
  - `security-watch` — scans for hardcoded secrets and `.env` leaks.
- **On-demand commands:** `status`, `route`, `find`, `evolve`, `decide`, `suggest`, `docs`, `audit`, `security`, `remember`, `history`.
- **Archetypes:** 10 Tier-1 archetypes with full overlays (telegram-bot, web-app, web-api, landing, game, parser, mobile-app, desktop, library, llm-agent) + 19 Tier-2 archetype descriptions.
- **Archetype composition** — two+ archetypes combined in a single project (e.g., telegram-bot + web-app), with deduplication in CLAUDE.md and hooks.
- **Brownfield scan (Phase 0)** — stack detection via `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, configs, folder signals.
- **Dev-stage detection (Phase 0.5)** — six signals determining Start-vs-Adopt routing.
- **`school-mode` plugin** (off by default) — opt-in learning mode with topic-based lesson dialogues.
- **Skill-discovery** — local registry + GitHub search for `jarvis find`.
- **Bootstrap helper** (`scripts/bootstrap.sh`) — conflict-detection and merge strategy for power users bypassing the dialogue flow.

### Acknowledgments

Built on patterns from `@alinaqi/claude-bootstrap`, `@pbakaus/impeccable`, `@emilkowalski/skill`, `@leonxlnx/taste-skill`, `anthropics/skills`, `@wcpaxx/spec-kit-brownfield-extensions`, `@travisvn/awesome-claude-skills`. See [NOTICE.md](NOTICE.md) for full attribution.

[Unreleased]: https://github.com/dtdesigner36/jarvis-starter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.1.0
