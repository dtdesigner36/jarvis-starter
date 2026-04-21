# Changelog

All notable changes to JARVIS-Starter are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **adopt.sh: auto-apply archetype overlay on confident detection.** When `≥3` stack-tags are detected (typical of a real project like Next.js + React + Tailwind + Prisma + TypeScript), the archetype overlay is now applied automatically instead of waiting for a manual `--enable archetype-overlay`. Escape hatches: `--no-archetype` (skip this run), `archetype-overlay: never` line in `.jarvis/preferences.md` (persistent skip), interactive Y/n/never prompt when running in a TTY. Low-confidence projects (`<3` tags) keep the old opt-in row. Addresses r5 feedback: *"every retest shows the overlay is useful — and every retest requires an extra manual step to enable it"*.

### Fixed

- **safe-uninstall.sh: backup dir visibility (UX).** Backup dir was named `.jarvis-uninstall-backup-<TS>` with a leading dot, so `ls` without `-a` hid it — reviewers thought `.jarvis/` wasn't being backed up. Renamed to `jarvis-uninstall-backup-<TS>` and added an explicit `find` listing of backed-up files at the end of the uninstall output. The `.jarvis/` backup itself was there all along; fix is purely about making it visible.
- **ADR detector: Russian "нужен ли X или Y" pattern.** The `стоит ли X или Y` pattern existed, but the natural RU phrasing `нужен/нужна/нужно/нужны ли X или Y` was missing. Added regex — 4/4 new variants now fire correctly.
- **security-watch: supabase/* paths + service_role detection.** Regex didn't match `supabase/server.ts`, `supabase/admin.ts`, `supabase/service-role.ts` — for Supabase projects these are the most security-critical files (where `SUPABASE_SERVICE_ROLE_KEY` lives). Added `supabase/(server|client|admin|service)` and `service[-_]role` to the trigger list.
- **adopt.sh: Next.js monorepo (`app/`) stack detection.** Previously `app` in the subdir list missed the trailing slash, producing `apppackage.json` lookups. Now `app/` — Next.js app-dir layouts detect correctly.
- **adopt.sh: globbing for `apps/*/` and `packages/*/`.** Unexpanded globs on projects without those folders stayed as literals and caused false file tests. Fixed with explicit glob-existence check.
- **adopt.sh: `set -euo pipefail` + `&& chain` in Python-stack block.** First grep that found nothing aborted the whole script. Replaced with explicit `if` statements — Python projects with partial dep coverage (e.g. only aiogram) now finish adopt.
- **adopt.sh: defensive hook preservation on re-run.** Second `adopt --enable <subset>` would in principle wipe earlier hook registrations. `install_hooks_registration` now scans `.claude/hooks/jarvis-*.sh` and implicitly re-registers existing hooks so the settings.json merge stays additive.
- **adopt.sh: Phase A "stack: not detected" hint.** Previously silent — now explicit message when neither package.json nor pyproject.toml detected.
- **adopt.sh: Phase C empty state.** "(none)" labels under Will install / Will skip when lists are empty.
- **safe-uninstall.sh: backup of `.jarvis/`.** Previously only `CLAUDE.md` and `settings.json` were backed up — `memory.md`, `state.md`, `usage-log.md` were lost. Now the entire `.jarvis/` dir is copied into the timestamped backup before removal.

### Added

- **Discovery Layer (layer B) — `core/skill-discovery/stack-matcher.sh`.** Python-based ranker that reads `.jarvis/state.md` (archetype + stack) and `known-registry.md`, ranks registry entries by archetype-match + stack-tag overlap. Emits top-N with rationale (`★★★★★ package match: archetype=web-app stack-overlap=[nextjs,react,tailwind]`).
- **Stack-tags in `known-registry.md`.** All ~30 entries got a Stack-tags column powering the ranker.
- **Stack auto-detection in `adopt.sh` Phase A.** Parses `package.json` (incl. monorepo subdirs: `app/`, `apps/*/`, `packages/*/`, `client/`, `server/`, `web/`, `api/`) and `pyproject.toml` / `requirements.txt`. Maps 40+ deps → stack-tags and 15+ → archetype. Result written to `.jarvis/state.md`.
- **Archetype overlay opt-in in `adopt.sh`** (`--enable archetype-overlay` or interactive Phase C row). Adds archetype-specific `CLAUDE.md.addon` with marker `<!-- jarvis-archetype-overlay: <archetype> -->`, archetype commands, and wires `hooks-addon.sh` into existing `jarvis-*.sh` hooks. Idempotent.
- **Phase F post-install digest in `adopt.sh`.** Big box with on-demand command catalog, archetype-evolve reminder, discovery options, Claude Code harness-wipe warning.
- **Proactive on-demand hints in existing hooks.**
  - `wiki-maintenance`: after 30 code edits without a wiki touch — suggests `jarvis docs` (anti-spam: once every 3 days).
  - `security-watch`: on edits to `auth|rls|middleware|policies|migrations` files — suggests `jarvis security` (once every 7 days).
- **`jarvis self-audit` command + `core/usage-log.sh`.** Hooks write one line per fire to `.jarvis/usage-log.md`; `self-audit` reads that log + on-demand catalog + state and emits a "which hooks fire, which stay silent, which on-demand commands haven't been tried, which archetype overlays are available" report. Clear separation from `jarvis audit` (project audit).
- **`scripts/safe-uninstall.sh`.** Single-command safer uninstall with timestamped backup (CLAUDE.md, settings.json, entire `.jarvis/`), Python guard that refuses to save an empty CLAUDE.md when the source wasn't empty, jq structured delete of `.hooks`. Supports markers from both bootstrap and adopt, plus archetype-overlay marker.
- **Bilingual ADR detector (`core/task-routing/adr-detector.sh`).** 24 regex patterns covering both English and Russian ADR phrasing with verb-flexion (`использ[а-я]*`, `выбр[а-я]*`, etc.). Hit rate on real Russian ADR moments went from 0% to ~100% in retest.
- **Real hook installer in `scripts/bootstrap.sh`.** Previously `bootstrap.sh` only warned when `.claude/settings.json` existed — now does an atomic `jq`-merge that preserves user config and adds JARVIS hooks. Idempotent (marker-based).
- **Brownfield Adopt auto-trigger** when dev-stage signals detected (≥2 of: git history, mature lockfile, real `src/`, existing `CLAUDE.md`, living `docs/`, running CI) — `jarvis start` in such a project auto-switches to Adopt with a confirmation prompt. Force full bootstrap with `jarvis start --force`.

### Changed

- **CLAUDE.md template handling.** Empty placeholder sections (`{{BACKEND_RULES}}`/`{{FRONTEND_RULES}}`/`{{MOBILE_RULES}}`) are stripped on fresh install. Idempotency marker `<!-- jarvis-starter-bootstrap -->` prevents duplicate appends on re-run.
- **`wiki/HOME.md` template.** `{{PROJECT_NAME}}` and `{{ARCHETYPES}}` now substituted from install-time data; `{{PROJECT_DESCRIPTION}}` and `{{STACK}}` become TODO comments.
- **Memory-recall minimum prompt length: 30 → 12.** Short prompts like "supabase issue" are no longer filtered out.
- **Hook templates** — quoted `{{SKILL_PATH}}` (fixes paths with spaces), single `INPUT=$(cat)` at the top (fixes double-stdin bug), archetype hook-addon substituted at install time.

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
