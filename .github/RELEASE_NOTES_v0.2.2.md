## Follow-up hotfix: closing the v0.2.1 re-audit findings

After v0.2.1 shipped, the same independent reviewer (codex/gpt-5 via MCP) re-audited the delta. Score moved from 5/10 → 7/10, promise-vs-delivery from 18/48/35% → 38/43/20%. Five small findings remained. v0.2.2 closes all five. No new features.

### Fixed

- **`adopt.sh --yes` no longer silently aborts.** If you ran `adopt.sh --yes` without `--enable` or `--skip`, the install-confirmation prompt still fired, `read` got EOF in non-interactive mode, and the script exited "Aborted." before writing anything. Non-interactive mode now skips the prompt. Pre-existing v0.2.0 bug; blocked CI and scripted rollouts.
- **`safe-uninstall.sh` jq filter hardened against weird `settings.json` shapes.** A `settings.json` where `.hooks` is null/missing, an event value is not an array, or a matcher-group `hooks` is not an array would crash uninstall under `set -euo pipefail`. The filter now type-checks each level and leaves unusual shapes untouched; a jq error falls through to a warning instead of an abort.
- **`restore_or_skip()` greenfield-install heuristic tightened.** The check was `grep -qE 'core/(wiki-maintenance|security-watch|focus-tracker|task-routing)'`, which matched any user hook that merely mentioned one of those paths in a comment. Now it requires the exact bootstrap dispatch idiom: `bash "<path>/core/<feature>/<script>.sh" <<< "$INPUT"`. User hooks that reference JARVIS paths in comments or in any non-dispatch form are no longer removed.
- **`bootstrap.sh` state.md stops lying about `wiki-location`.** v0.2.1 wrote `wiki-location: .jarvis` when the target directory had `docs/` without `wiki/`, but bootstrap unconditionally creates `wiki/{Systems,Architecture,Devlog,Canvas}` anyway. State now always records `wiki-location: wiki` for bootstrap installs — state and disk agree. The brownfield namespace matrix stays in `adopt.sh`.

### Changed

- **README truth-up.** v0.2.1's honesty pass touched CHANGELOG and SKILL.md but missed the README. Corrected here: "0 tokens at rest" → "0 tokens until a hook fires" (core hooks run once per tool-use or user-turn, then exit silently); "Never touches your CLAUDE.md, hooks, or docs" → honest phrasing about the single marker line adopt adds to `CLAUDE.md` and the sentinel-guarded wrap it does around pre-existing legacy hook names; "local registry + GitHub discovery" → curated-registry ranking, with GitHub-query discovery marked as model-guided (install stays a user action).
- **Release-notes / changelog wording** for v0.2.1 adjusted to describe bootstrap's state.md as schema-aligned (same keys as adopt) rather than full namespace-matrix parity. Bootstrap is the greenfield installer.

### Not in this release (still v0.3 scope)

Same as v0.2.1: real dispatcher for model-prompted commands, GitHub-query skill discovery for `jarvis find`, web-app/web-api `hooks-addon.sh`, `school-mode` runtime plugin loader, centralized `core/lib/` helpers.

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).
