# Changelog

All notable changes to JARVIS-Starter are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.4] — 2026-04-23

Trust hotfix driven by a real-user review. A developer ran `npx skills add` + `jarvis start` on a fresh Node/Express + D3 project and hit two failure modes that all four prior codex audit passes and 21-step E2E had missed. This release closes both plus minimum degraded-mode visibility.

### Fixed

- **Bootstrap merge is now loudly verified on disk.** Previously the final line read `jq '[.hooks | to_entries[] | .value[] | .hooks[]?] | length'` and printed "JARVIS hooks in settings.json: N" — but the count was computed from the file as-merged, and an IDE (Claude Code / VSCode extension) rewriting `settings.json` on a permission-grant could wipe the `.hooks` block between the read and any subsequent action. Users saw a green count while the final on-disk state was broken. The bootstrap now asserts **both** `.hooks.PostToolUse` and `.hooks.UserPromptSubmit` are non-empty arrays on disk, prints PT/UP counts, explicitly warns about the known IDE quirk, and exits non-zero with recovery instructions if validation fails.
- **Bootstrap `jq` merge hardened against unusual `settings.json` shapes.** The merge now defensively handles `.hooks` missing, null, or containing null/non-array event values (which some IDE rewrites leave behind). Empty `$user.hooks` no longer produces an `add`-of-empty-list failure (`add // []` fallback). Non-array event values are filtered out before grouping.
- **`.gitignore` template ships with JARVIS artifact rules + idempotent merge step.** `npx skills add dtdesigner36/jarvis-starter` drops the entire skill at `.agents/skills/jarvis-starter/` in the target project. Without a pre-placed `.gitignore`, `git init && git add -A` swept hundreds of skill template files into the user's first commit. Bootstrap and adopt now both merge `archive/templates/universal/.gitignore.template` (covering `.agents/`, `skills-lock.json`, `.pre-jarvis*.bak`, `jarvis-uninstall-backup-*/`) into the project's `.gitignore` on first run — idempotent on re-run.

### Added

- **`jarvis self-audit` reports hook health at the top of its output.** The IDE wipe is a known quirk documented in `archive/bootstrap/brownfield-adopt.md §8`, but until v0.2.4 the product had no runtime signal when the wipe had already happened. `core/self-audit/report.sh` now reads `.claude/settings.json` first; if `.hooks.PostToolUse` or `.hooks.UserPromptSubmit` are empty, it prints `❌ Hook health: DEGRADED` with a concrete recovery command (restore from `.pre-jarvis.bak` + re-bootstrap from an external shell). Healthy installs show `✅ Hook health: PostToolUse=N UserPromptSubmit=M`.

### Not in this release

Full self-heal automation (snapshot + pre-prompt restoration) is v0.3 scope, with hook-health/observability promoted to a top-priority v0.3 item. This release is the minimum that (a) stops the installer from lying about a successful merge and (b) gives users an obvious command to check if their hooks are still alive.

## [0.2.3] — 2026-04-23

Micro-polish from the v0.2.2 re-audit. Three small fixes so the 0.2.x line can be declared closed.

### Fixed

- **`safe-uninstall.sh`: jq matcher narrowed.** Previous pattern `test("jarvis-|...")` matched any command containing `jarvis-` as a substring — including a user's own `python tools/jarvis-helper.py` or `bash /other/jarvis-inspired-hook.sh`, which would then be dropped from `settings.json`. The matcher is now anchored to the JARVIS hook directory: `/\.claude/hooks/jarvis-[^/]+\.sh` (or legacy `post-edit|post-bash|pre-prompt.sh` under the same dir). User hooks outside `.claude/hooks/` or with `jarvis-` only as part of a filename no longer false-positive.
- **`adopt.sh` `seed_memory()`: `git rev-parse --verify HEAD` preflight** replaces the `|| true` fallback from v0.2.2. Zero-commit repos are handled cleanly (no bogus "Recent commits" section is emitted); real `git log` failures are no longer silently masked.

### Changed

- **README: adopt-mode claim truth-up.** "Leaves your existing CLAUDE.md, hooks, and docs untouched" → explicit description: one marker line is added to `CLAUDE.md`; hooks and docs are left in place; pre-existing legacy hook files are wrapped in a sentinel block that `safe-uninstall.sh` undoes. Closes the last "adopt is invasive-but-claims-otherwise" overclaim flagged in the re-audit.

## [0.2.2] — 2026-04-23

Follow-up hotfix from the v0.2.1 codex re-audit. Five small, targeted fixes that close the remaining findings without scope creep. No new features.

### Fixed

- **`adopt.sh --yes` silently aborted when no `--enable`/`--skip` was supplied.** The install-confirmation prompt at `adopt.sh:459` fired in non-interactive mode too; `read` got EOF, `REPLY` was empty, and the script exited with an "Aborted." message before writing anything. Now the confirmation is skipped when `NONINTERACTIVE=1` (set by `--yes`). Pre-existing bug from v0.2.0; blocked CI and scripted rollouts.
- **`safe-uninstall.sh` jq filter is defensive.** Previously assumed `.hooks` is always a well-formed object of arrays of groups. With `set -euo pipefail`, a `settings.json` where `.hooks` is null/missing, an event value is not an array, or a matcher-group `hooks` is not an array would cause uninstall to abort. Now each level is type-checked and left untouched on unusual shapes; jq errors fall back to "leave `settings.json` alone and warn".
- **`restore_or_skip()` greenfield-install heuristic tightened.** Was `grep -qE 'core/(wiki-maintenance|security-watch|focus-tracker|task-routing)'` — matched any user hook that merely commented a JARVIS path. Now requires the exact bootstrap dispatch idiom: `bash "<path>/core/<feature>/<script>.sh" <<< "$INPUT"`. A user hook that just mentions `core/wiki-maintenance` in a comment is no longer removed.
- **`bootstrap.sh` state.md no longer lies about `wiki-location`.** v0.2.1 wrote `wiki-location: .jarvis` when `docs/` existed without `wiki/`, but bootstrap unconditionally creates `wiki/` below anyway. State now always records `wiki-location: wiki` for bootstrap installs. The brownfield namespace matrix lives in `adopt.sh` and is unchanged.

### Changed

- **README truth-up.** Matches the CHANGELOG/SKILL.md honesty pass that shipped in v0.2.1 but missed the README: "0 tokens at rest" → "0 tokens until a hook fires"; "Never touches your CLAUDE.md, hooks, or docs" → honest phrasing about the CLAUDE.md marker line and legacy-hook sentinel wrap; "local registry + GitHub discovery" → curated-registry ranking, with GitHub-query discovery marked as model-guided (install stays a user action).
- **Release-notes / changelog wording** for `[0.2.1]` adjusted to describe bootstrap's state.md as schema-aligned with adopt (not a full namespace-matrix parity) — consistent with the fix above.

## [0.2.1] — 2026-04-23

Hotfix release triggered by an independent code review (codex/gpt-5 via MCP). The review covered three layers: code safety, architectural parity, and a claim-by-claim audit of README/SKILL.md/CHANGELOG against actual code. v0.2.1 closes the safety and parity gaps and realigns documentation with reality; on-demand-command architecture (markdown-vs-dispatcher) is deferred to v0.3.

### Fixed

- **`safe-uninstall.sh`: non-destructive.** Previously `rm`'d the legacy hook file names unconditionally and did `jq 'del(.hooks)'` (which erased **all** hook registrations including the user's own). Contradicted the CHANGELOG claim of preserving user config. Now:
  - `restore_or_skip()` handles legacy `{post-edit,post-bash,pre-prompt}.sh`: restore from `.pre-jarvis.bak` if bootstrap made one; else strip the JARVIS-appended block by sentinel `# === JARVIS-starter hooks (appended) ===`; else, if the file only references JARVIS core paths, treat as greenfield install and remove; else leave the file untouched (it's user-owned).
  - Selective `jq` filter removes only entries whose `command` points at `jarvis-*.sh` or legacy hook files; user hook entries survive. Empty `.hooks` is cleaned up.
  - CLAUDE.md with JARVIS marker at byte 0 is removed entirely (was: left full of JARVIS content because the empty-output guard refused the write).
  - Backups now include legacy hook files too.
- **Linux `stat` portability.** `hook-detector.sh`, `prompt-analyzer.sh`, and `gitignore-check.sh` fell back to `echo 0` on Linux because they used BSD `stat -f "%m"` only. Added an inline `_mtime()` helper (BSD → GNU → 0). Throttling and mtime-based counters now work correctly on Linux, not just macOS.
- **`adopt.sh`: `jq` preflight.** Without `jq`, adopt used to write `.jarvis/`, CLAUDE.md marker, and hook files before hitting a `jq` call and aborting via `set -e`, leaving a partial install. Now aborts with an actionable error **before any file write**.
- **Shell-quoted hook commands in `settings.json`.** Both `adopt.sh` (Python generator) and `bootstrap.sh` (previously a raw `sed` over the template) now `shlex.quote` the project path in each hook command. Projects with spaces or shell metacharacters in their path — e.g. `"~/My Projects/foo"` — no longer break hook execution.

### Added

- **`bootstrap.sh` state schema alignment.** `.jarvis/state.md` written at greenfield bootstrap now carries the same keys adopt writes (`mode`, `project-root`, `skill-path`, `wiki-ownership: active`, `wiki-location`, `owned-files`) so `.jarvis/`-reading tools work the same across both install paths. Bootstrap is the greenfield installer (`jarvis start`) — it always creates `wiki/` and always records `wiki-location: wiki`. The brownfield namespace matrix (docs/ without wiki/ → `.jarvis/systems/`) lives in `adopt.sh` and is unchanged.
- **Bilingual task-routing classification.** `core/task-routing/prompt-analyzer.sh` now recognizes both Russian and English architectural keywords in all three regexes (ARCH_KEYWORDS, Complex, Architectural). Matches the bilingual pattern already in `adr-detector.sh`. Input classification is invariant to prompt language in both repos.
- **`llm-agent` archetype CLAUDE.md.addon.** The archetype tier1 folder previously had only `description.md`; the release-notes claim of "overlays ship themselves" was misleading. Added the addon with rules for prompt versioning, hardcoded model strings, `cache_control` on system prompts, prompt-injection risk on user-content, PII filtering, filesystem-tool scoping.

### Changed

- **README / SKILL.md command surface split.** On-demand commands are now presented as two groups: **Real shell commands** (`self-audit` runs `core/self-audit/report.sh`; `adopt` runs `scripts/adopt.sh`) and **Model-prompted workflows** (markdown instruction files Claude reads on demand — `status`, `route`, `find`, `evolve`, `decide`, `suggest`, `docs`, `audit`, `security`, `remember`, `history`). The distinction matters: the second group is guidance for Claude, not a standalone CLI. Architecture block updated to match.
- **CHANGELOG `[0.1.0]` entry: "0 tokens at rest" qualification.** The honest phrasing is "0 tokens until a hook fires"; per-prompt classification is always shell-only and token-free, but the core hooks run once per user turn.
- **CHANGELOG `[0.2.0]` entry: Discovery Layer clarification.** Explicit note that `stack-matcher.sh` ranks and displays; `npx skills add` invocation is left to the user. No automatic install.

### Deferred (v0.3 scope)

- Real shell dispatcher under the model-prompted on-demand commands (`jarvis docs` → exec audit script, etc.) — needs an architectural decision about keeping markdown-as-instructions vs moving to a shell-dispatcher model.
- GitHub skill discovery script for `jarvis find` (currently registry-ranking + hint-to-GitHub-query only).
- `web-app` / `web-api` archetype `hooks-addon.sh` files (only `telegram-bot` has one today).
- `school-mode` runtime plugin loader.
- Centralized `core/lib/` helpers (shared `_mtime`, JSON parsing, usage logging, throttling).

## [0.2.0] — 2026-04-22

The "JARVIS starts paying for itself" release. 15 commits since v0.1.0. Across six iterated real-project retests (Next.js + Supabase web app and a Python aiogram Telegram bot), the useful-share climbed from 20–25% (first real-use) to ~88% (latest retest). Four architectural shifts define v0.2.0: (1) the installer actually installs, (2) JARVIS sees itself via `self-audit`, (3) a full Discovery Layer binds stack → relevant skills, (4) wiki stops being a reminder system and becomes an active owner.

### Added

- **Context-triggered surfacing of `jarvis suggest` / `jarvis audit` / `jarvis find`.** r5 feedback noted that self-audit became "smart" but runtime hooks didn't surface these on-demand commands. Added:
  - `wiki-maintenance`: after 100 edits without an audit, hints `jarvis suggest` or `jarvis audit` (anti-spam: once every 7 days).
  - `task-routing`: on search-like prompts (`"how to implement X"`, `"library for X"`, `"как реализовать"`, `"какая библиотека"` — both EN and RU), hints `jarvis find <need>` (anti-spam: once every 5 days).
  - All hints sit next to the existing `jarvis docs` (on wiki-stale) and `jarvis security` (on auth/supabase file edits) hints — bringing on-demand command awareness into the natural workflow.
- **Active wiki-ownership.** JARVIS no longer just reminds you to update the wiki — it takes ownership of `wiki/Systems/<X>.md`. On detection of a new module (`src/{modules,features}/<X>/` with ≤3 files + Write event), `core/wiki-maintenance/scaffold.sh` creates a stub with YAML frontmatter (`jarvis-managed: scaffold`, `source-module`, `created`, `last-edited`) and sections TL;DR (user fills) + Files (auto-maintained) + Decisions (appended on `jarvis decide`) + Last edit (auto-updated). On subsequent Edit events in the tracked module, `live-update.sh` updates `last-edited` YAML + `## Last edit` block + adds the file to `## Files`. Anti-spam: once per 10 minutes per-system. File-lock at `.jarvis/wiki-write.lock` guards against race conditions. `.jarvis/state.md` now tracks `wiki-ownership: active|off`, `wiki-location: wiki|.jarvis`, `owned-files: [...]`. Namespace matrix in adopt: `docs/` exists without `wiki/` → JARVIS writes to `.jarvis/systems/` (doesn't create a parallel wiki); otherwise → `wiki/Systems/`. Opt-out levels: (a) `wiki-ownership: off` in `.jarvis/preferences.md` for passive mode; (b) `jarvis-managed: off` in a specific file's frontmatter; (c) `.jarvis/wiki-ignore` glob patterns.

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

- **Discovery Layer (layer B) — `core/skill-discovery/stack-matcher.sh`.** Python-based ranker that reads `.jarvis/state.md` (archetype + stack) and `known-registry.md`, ranks registry entries by archetype-match + stack-tag overlap. Emits top-N with rationale (`★★★★★ package match: archetype=web-app stack-overlap=[nextjs,react,tailwind]`). Ranking + display only — `npx skills add` invocation is left to the user.
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
- **Core hooks (always-on, 0 tokens until a hook fires):**
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
- **Skill-discovery** — curated local registry for `jarvis find`; GitHub-query discovery is model-guided (Claude proposes a search), not an installed script.
- **Bootstrap helper** (`scripts/bootstrap.sh`) — conflict-detection and merge strategy for power users bypassing the dialogue flow.

### Acknowledgments

Built on patterns from `@alinaqi/claude-bootstrap`, `@pbakaus/impeccable`, `@emilkowalski/skill`, `@leonxlnx/taste-skill`, `anthropics/skills`, `@wcpaxx/spec-kit-brownfield-extensions`, `@travisvn/awesome-claude-skills`. See [NOTICE.md](NOTICE.md) for full attribution.

[Unreleased]: https://github.com/dtdesigner36/jarvis-starter/compare/v0.2.4...HEAD
[0.2.4]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.2.4
[0.2.3]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.2.3
[0.2.2]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.2.2
[0.2.1]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.2.1
[0.2.0]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.2.0
[0.1.0]: https://github.com/dtdesigner36/jarvis-starter/releases/tag/v0.1.0
