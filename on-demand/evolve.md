# jarvis evolve — add an archetype layer

When the project grows past its starting archetype.

## Trigger

User:
```
> jarvis evolve web-app
```

Or JARVIS itself suggests via a detection hook (see `core/wiki-maintenance/hook-detector.sh`) when signals appear.

## Workflow

### 1. Read current state
- `.jarvis/state.md` — current archetypes
- `package.json` / `pyproject.toml` / etc. — actual stack
- Verify the new layer is compatible (no conflicts)

### 2. Analyze changes
Show the user what will be added:
```
💠 JARVIS: adding web-app layer to the project (current: telegram-bot)

This will add:
  • Agent skills: impeccable, shape, polish (pbakaus/impeccable)
  • Commands: /css-audit, /responsive-check, /i18n-sync, /theme-token
  • Hooks: on *.tsx → i18n-sync; on CSS → css-audit+responsive-check
  • Wiki: Components/, Design/, Pages/, Theming/
  • Updates CLAUDE.md with web-app trigger rules

Total changes: ~25 files created/modified.
Continue? (y/n)
```

### 3. After confirmation
- Read `archive/archetypes/tier1/<name>/` or generate from `archive/archetypes/tier2/<name>.md`
- Copy CLAUDE.md.addon (merge into current CLAUDE.md)
- Copy commands from the archetype
- Add hooks-addon into settings
- Create wiki-extra folders
- Install agent skills via `npx skills add`
- Update `.jarvis/state.md`
- Add an entry to `.jarvis/timeline.md`

### 4. Verification
- Check hooks work
- Give the user a summary of changes
- Optionally propose `jarvis audit` for a check

## Rollback

If the user changes their mind after evolve:
```
> jarvis evolve --undo <layer>
```
Rolls back via git (if the project is a git repo) or via backup `.jarvis/backups/pre-evolve-<timestamp>/`.

## Composite evolutions

```
> jarvis evolve web-app + real-time-app
```
Applies both layers at once — combines overlays, resolves conflicts (JARVIS asks if needed).

## Auto-suggestions

Through the wiki-maintenance hook, JARVIS detects:
- `*.tsx` in a bot project → suggest `jarvis evolve web-app`
- `@socket.io` in a web-app without real-time → suggest `jarvis evolve real-time-app`
- `@stripe` without an e-commerce layer → suggest `jarvis evolve e-commerce`

The suggestion fires **once** via the hook. The user decides.