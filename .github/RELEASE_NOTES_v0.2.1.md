## Hotfix: safety, parity, honesty

v0.2.1 is a small, targeted release triggered by an independent code review (codex/gpt-5 via MCP). The review landed in three waves — a code-level audit (5/10), a deeper architectural pass, and a claim-by-claim audit that compared the v0.2.0 documentation against the actual code. This release closes the safety and parity gaps and realigns the documentation with reality. Architectural decisions about the on-demand command surface (markdown instructions vs real shell dispatchers) are deferred to v0.3.

### Why this exists

If you ran `bash scripts/safe-uninstall.sh` in a project with pre-existing user hooks, the previous implementation would delete the legacy hook file unconditionally and remove the **entire** `.hooks` section from `.claude/settings.json` — including your own hook registrations. The CHANGELOG said "user config preserved." That claim was wrong; this release makes it true.

Similarly: the Linux `stat` fallback existed in `live-update.sh` but was missing in three other hooks, so Linux users got silently-broken throttling. Project paths containing spaces (common on macOS — `"~/My Projects/..."`) broke hook execution because command strings were unquoted. And bootstrap's state.md was missing the `wiki-ownership` keys that adopt's state.md had written since v0.2.0, so the "active wiki ownership" feature was adopt-only despite both install paths advertising it.

### Fixed

- **`safe-uninstall.sh` is now non-destructive.** Legacy hook files (`post-edit.sh`, `post-bash.sh`, `pre-prompt.sh`) are restored from `.pre-jarvis.bak` if bootstrap made one, or have the JARVIS-appended block stripped by sentinel, or — if the whole file references JARVIS-internal paths — are treated as greenfield installs and removed. User-owned files with no JARVIS markers are left untouched. The `jq` filter in settings.json now removes only entries whose `command` points at a JARVIS hook file; user hook registrations survive. A CLAUDE.md created wholly by bootstrap (marker at byte 0) is removed rather than left in place.
- **Linux `stat` portability.** `hook-detector.sh`, `prompt-analyzer.sh`, and `gitignore-check.sh` gained an inline `_mtime()` helper: `stat -f "%m"` on BSD (macOS), `stat -c "%Y"` on GNU (Linux), `0` otherwise. Throttling and mtime-based counters now work on both OSes.
- **`adopt.sh` jq preflight.** Without `jq`, adopt used to partially-install before aborting. Now it aborts before writing any file, with an actionable install hint.
- **Shell-quoted hook command paths.** Both installers now use `shlex.quote()` when rendering the project path into `settings.json` hook commands. Projects whose path contains spaces (`"~/My Projects/foo"`) or shell metacharacters no longer break Claude Code's hook execution.

### Added

- **Bootstrap wiki-ownership state parity.** `.jarvis/state.md` written at greenfield bootstrap now carries `mode`, `project-root`, `skill-path`, `wiki-ownership: active`, `wiki-location`, and `owned-files`. The namespace matrix (`docs/` without `wiki/` → `wiki-location: .jarvis`) is the same rule adopt uses.
- **Bilingual task-routing classification.** `core/task-routing/prompt-analyzer.sh` now merges Russian and English keywords across all three classifiers — the same pattern `adr-detector.sh` had been using. Input classification is invariant to prompt language.
- **`llm-agent` archetype `CLAUDE.md.addon`.** Completes the tier1 overlay: rules for prompt versioning, model-version pinning (avoid `-latest` aliases), `cache_control` on system prompts, prompt-injection risks, PII filtering, filesystem-tool scoping.

### Changed

- **README / SKILL.md command surface split.** On-demand commands are now presented as two groups — **Real shell commands** (`self-audit`, `adopt`) and **Model-prompted workflows** (`status`, `route`, `find`, `evolve`, `decide`, `suggest`, `docs`, `audit`, `security`, `remember`, `history`). The second group is guidance for Claude, not a standalone CLI. This matches how the code actually works.
- **CHANGELOG clarifications.** v0.1.0's "0 tokens at rest" is now "0 tokens until a hook fires" — honest about per-turn hook execution. v0.2.0's Discovery Layer is explicitly ranking + display; `npx skills add` invocation is user-initiated.

### Not in this release (v0.3 scope)

- Real shell dispatcher behind model-prompted commands (`jarvis docs` → exec an audit script, etc.).
- GitHub-query skill discovery for `jarvis find`.
- `web-app` / `web-api` archetype `hooks-addon.sh` files.
- `school-mode` runtime plugin loader.
- Centralized `core/lib/` shared helpers.

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

Then:
```
> jarvis start: <project description>
# or for an existing project:
> jarvis adopt
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).
