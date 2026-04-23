## Trust hotfix: real-user bugs the audit grid missed

After v0.2.3 the reviewer (codex/gpt-5 via MCP) signed off on the 0.2.x hotfix cycle as "closed, move to v0.3." Then a real developer installed v0.2.3 in a fresh Node/Express + D3 project via `npx skills add`, ran `jarvis start`, and hit two failure modes none of the four audit passes or the 21-criterion E2E had touched:

1. **The bootstrap installer printed "✅ JARVIS hooks merged" and "hooks in settings.json: 3" — while the final file on disk had `.hooks = null`** because the IDE layer wiped the block between the merge and any subsequent action. The installer was reading the file at merge-time and declaring success based on transient state.
2. **`npx skills add` deposits the entire skill at `.agents/skills/jarvis-starter/` in the target project's root. No shipped `.gitignore` template → `git init && git add -A` sweeps ~hundreds of template files into the user's first commit.**

v0.2.4 fixes both plus gives `jarvis self-audit` the ability to tell you if your hooks are currently alive.

### Fixed

- **Bootstrap now verifies the merge result on disk, loudly.** After the `jq` merge completes, bootstrap re-reads `.claude/settings.json` and asserts both `.hooks.PostToolUse` and `.hooks.UserPromptSubmit` are non-empty arrays. If either is empty, the script exits non-zero with an explanation of the most likely cause (IDE wipe on permission-grant) and concrete recovery steps. If both are healthy, it prints `✅ JARVIS hooks verified on disk: PostToolUse=N UserPromptSubmit=M` followed by a note that the IDE may still drop the block mid-session.

- **Bootstrap `jq` merge defensively handles unusual `settings.json` shapes.** `.hooks` can be absent, null, or contain null/non-array event values (shapes produced by IDE rewrites). The merge now coalesces missing keys, filters non-array event values before `group_by`, and uses `add // []` so an empty `$user.hooks` no longer makes the merge crash.

- **Shipped `.gitignore.template` + idempotent merge in bootstrap and adopt.** First-run installs now append (or create) `.gitignore` entries for `.agents/`, `skills-lock.json`, `.pre-jarvis*.bak`, `jarvis-uninstall-backup-*/`. Re-runs detect the marker line and skip — no duplicates.

### Added

- **`jarvis self-audit` reports hook health at the top.** The IDE-wipe quirk was already documented in `archive/bootstrap/brownfield-adopt.md §8`, but until now the product had no runtime signal that the wipe had already happened — reviewer saw an empty `.jarvis/focus.md` and had to reverse-engineer why. `core/self-audit/report.sh` now reads `settings.json` first. If hooks are missing: `❌ Hook health: DEGRADED` + concrete recovery command (restore from `.pre-jarvis.bak`, re-bootstrap from an external shell). Healthy state: `✅ Hook health: PostToolUse=N UserPromptSubmit=M`.

### What's still ahead (v0.3)

Self-heal automation (hook snapshot + pre-prompt restoration) is promoted from "optional polish" to a top-priority v0.3 item. Full archetype overlays for `parser`, Node/Express, and other stubbed tier-1 archetypes remain on the v0.3 list. `.env.example` auto-emission stays deferred until the heuristic can be made conservative enough.

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).
