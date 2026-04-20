# School Mode Commands

Implementation of `jarvis school <subcommand>` subcommands.

## `jarvis school on`

See `../SKILL.md` for the activation workflow. Main steps:
1. Check `.jarvis/state.md` (archetypes + stack)
2. For each tech, copy `../stub-templates/<tech>.md` → `school-wiki/<tech>.md`
3. Generate missing stubs for tech without templates
4. Create `school-wiki/INDEX.md`
5. Create `school-wiki/progress.md`
6. Update `.jarvis/plugins.md` with `school-mode: on`

## `jarvis school off`

1. `.jarvis/plugins.md`: remove `school-mode: on` or set `school-mode: off`
2. `school-wiki/` stays on disk (user can return)
3. Confirm: "school-mode disabled, school-wiki/ preserved"

## `jarvis school list`

Simply `cat school-wiki/INDEX.md` + a little formatting.

## `jarvis school topic <area>`

See `../session-facilitator.md` — main workflow.

## `jarvis school progress`

`cat school-wiki/progress.md`.

## `jarvis school refresh`

1. Re-read `.jarvis/state.md`
2. Compare with existing `school-wiki/` — what's new, what's stale
3. Add new stubs / update INDEX.md
4. Show diff to user