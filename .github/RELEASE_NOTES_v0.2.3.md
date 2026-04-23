## Micro-polish: closing the 0.2.x hotfix cycle

After v0.2.2, the same reviewer (codex/gpt-5 via MCP) did a third audit pass. Score moved 7/10 → 8/10, promise-vs-delivery 38/43/20 → 43/42/16. Two small findings remained. v0.2.3 closes them both plus one optional cleanup, so the 0.2.x hotfix cycle can be declared finished.

### Fixed

- **`safe-uninstall.sh`: jq matcher now anchored to the JARVIS hook directory.** Previous pattern matched any command containing `jarvis-` as a substring — a user's own `python tools/jarvis-helper.py` or `bash /other/jarvis-inspired-hook.sh` would be dropped from `settings.json` alongside real JARVIS entries. The matcher now requires the path `/.claude/hooks/jarvis-<something>.sh` (or the legacy bootstrap names under the same directory). User hooks outside `.claude/hooks/` or whose filename merely contains `jarvis-` no longer false-positive.
- **`adopt.sh` `seed_memory()`: `git rev-parse --verify HEAD` preflight** replaces the `|| true` fallback shipped in v0.2.2. Repos with zero commits are handled cleanly (the "Recent commits" section is omitted entirely instead of emitted empty); real `git log` failures are no longer silently masked.

### Changed

- **README: adopt-mode wording truthed-up.** "Leaves your existing CLAUDE.md, hooks, and docs untouched" → explicit description: one marker line is appended to `CLAUDE.md` (the line `<!-- jarvis-starter-adopt: see .jarvis/state.md -->`), your own rules are not rewritten; hooks and docs are left in place; pre-existing legacy hook files are wrapped in a sentinel block that `safe-uninstall.sh` can undo. Closes the last adopt-is-invasive-but-claims-otherwise overclaim.

### Nothing else changed

No behavioral changes beyond the two fixes above. This is the final 0.2.x hotfix. v0.3 planning can start from here.

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).
