# jarvis self-audit — what from JARVIS is actually firing

Shows the user what from the installed skill actually triggers, what stays silent, which on-demand commands they haven't tried, and which archetype overlays are available but not applied.

## When invoked

- User types `jarvis self-audit` (or `jarvis selfaudit`)
- After 1-2 weeks of active work — to understand what brings value vs noise

## What it does

**Run:**
```bash
bash {{SKILL_PATH}}/core/self-audit/report.sh {{SKILL_PATH}}
```

Reads:
- `.jarvis/usage-log.md` — fire log of all core hooks
- `.jarvis/state.md` — mode, archetype, preferences
- `.jarvis/enabled-features.md` — what the user picked at adopt/bootstrap
- `on-demand/*.md` — command catalog

Outputs:
1. **Hooks (core)** — activity table with `✓` (fired) / `×` (silent) / `—` (not installed), fire counter, last-fired timestamp
2. **On-demand commands** — list of available commands, so the user discovers the ones they haven't tried
3. **Archetype overlays** — detected/applied, with `jarvis evolve <archetype>` tip if adopt-mode blocked the overlay
4. **Recommendations** — contextual advice based on usage-log patterns:
   - "adr-detector fired 14x — try `jarvis decide` on your next fork"
   - "wiki-maintenance checked 30x without firing — patterns may not match"
   - "memory-recall no-match=20, hit=0 — memory.md may be stale"

## Why it's needed (root cause from feedback #5)

JARVIS has ~22 modules: 6 core hooks, 7 on-demand commands, 10 archetype overlays, plugins, rare-subcommands. In a single session 3-4 hooks actually fire; the rest are **invisible to the user** — they don't know what they have.

Existing `jarvis audit` audits the user's PROJECT (wiki health, tokens, deps). It looks outward. `jarvis self-audit` audits JARVIS itself: what's used, what's dormant, what to try next.

## Output style

- Short, no fluff. ~20 lines.
- A vague "try X" tip beats nothing — users need to know the commands exist.
- If usage-log is empty (fresh install) — say "no hook fired yet", no fake analytics.

## Edge cases

- **No `.jarvis/`** — `❌ Not a JARVIS project. Run jarvis start or jarvis adopt.`
- **`usage-log.md` missing** — hooks installed but never fired yet. Recommend "verify install: jq '.hooks' .claude/settings.json"
- **SKILL_PATH unknown** — try `state.md`, if missing — ask the user to pass as argument
