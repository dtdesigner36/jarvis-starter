## Emergency hotfix: v0.2.4 blocked every fresh install

v0.2.4 shipped yesterday with a trust-hotfix addressing a real user's bug report. The same user re-tested it hours later and found v0.2.4 **completely blocked installation on fresh projects** — bootstrap crashed on step 2b with `cat: .../archive/templates/universal/.gitignore.template: No such file or directory`.

**Root cause:** the skill distribution layer (`npx skills add`) strips dotfiles during packaging. The `.gitignore.template` I added in v0.2.4 was present in the git tree but absent from the installed skill. The v0.2.4 trust-verify actually made this worse — it turned a would-be quiet failure on step 2b into a loud `exit 1` that blocks the rest of bootstrap.

### Fixed

- **Template file renamed `.gitignore.template` → `gitignore.template`** (no leading dot) so it survives `npx skills add` packaging. Bootstrap and adopt now reference the non-dotfile name. Confirmed via fresh-install E2E: template is present in the installed skill and bootstrap completes end-to-end.
- **Bootstrap and adopt now gracefully skip the gitignore merge if the template is missing from the package.** Previously `cat "${UNIVERSAL}/.gitignore.template" >> .gitignore` under `set -e` aborted the entire install. Now the scripts check for the template first; if absent, they emit a clear warning and continue. This is defence-in-depth — the rename fixes the root cause, but future packaging-layer bugs won't block bootstrap the same way.

### Added

- **`jarvis self-audit` now warns explicitly when `jq` is missing.** Previously the hook-health section was guarded by `if command -v jq && [ -f settings.json ]` and silently disappeared if either was false. Now the branches are explicit: `⚠ Hook health: unavailable (jq not installed)` with install-command hints, or `⚠ Hook health: unavailable (.claude/settings.json not found)` with a recovery hint. Closes the last honesty gap codex flagged as optional.

### Meta-takeaways

Two lessons from the v0.2.4 → v0.2.5 cycle that matter going forward:

1. **Git tree ≠ installed skill.** Dotfiles get stripped during `npx skills add`. Any template or data file we rely on at runtime must be a non-dotfile, and we need a CI step that does a fresh install and runs bootstrap — otherwise we ship broken installers. This is now the top v0.3 prerequisite.
2. **Louder failures can mask installer bugs too.** The v0.2.4 trust-verify replaces silent data-loss with loud exit 1. That's correct for the failure mode I designed it for (IDE wipes hooks after merge), but it also means ANY earlier failure now blocks the entire bootstrap. Defence-in-depth (graceful skip when the template is missing) brings the installer back to "keep going where safe, fail loudly where unsafe."

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).
