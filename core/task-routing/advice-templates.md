# Advice Templates — vibe-coder friendly

Templates for advice JARVIS outputs for different task classes. Simple language, no jargon.

**Note:** The skill auto-detects the user's language from the prompt (Cyrillic → Russian, otherwise → English) and responds in kind. Russian templates for vibe-coder output can be kept in parallel for bilingual UX (see `advice-templates.ru.md` if present).

## Medium — short advice

```
💠 JARVIS: this looks like a Medium task (multiple files, design choices).
  Recommend: Sonnet + plan mode (⌥+p for plan mode, /model sonnet if you're on Opus).
  Without plan mode — risk of rework. Continue without switching? (just keep typing)
```

## Complex — structured advice

```
💠 JARVIS: this is a Complex task (new feature / multiple systems).
  Optimal path:
  1. Now: Opus 4.7 + plan mode (⌥+p) → agree on approach
  2. After plan: /model sonnet → implementation (5-10x cheaper on long work)
  3. Final review: Opus for verification

  Want to jump into plan mode? Press ⌥+p.
```

## Architectural — strong advice

```
💠 JARVIS: Architectural task (pattern change / major refactor).
  Strongly recommend:
  1. Opus 4.7 + plan mode mandatory
  2. Several confirmation checkpoints in the plan
  3. Sonnet for mechanical edits after approval
  4. Opus for final review

  Without a plan — high risk of breakage. ⌥+p to enable plan mode.
```

## For technically literate users (more compact)

If the user marks their experience via `jarvis remember "I'm technically literate"` — advice is shorter:

```
💠 JARVIS: Medium. Sonnet+plan.
```

```
💠 JARVIS: Complex. Opus→plan→Sonnet→review.
```

## Mode-aware variants

JARVIS detects current permission mode (scan `.claude/settings.json` + hook payload).

### Medium + auto-mode
```
💠 JARVIS: Medium task, you're in auto mode.
  Advice: switch to plan mode (⌥+p) — protects from "half-baked" solutions.
  Model: Sonnet is enough. Opus not required.
  If you're sure it's a quick task — carry on as is.
```

### Complex + auto-mode
```
💠 JARVIS: Complex task in auto mode — risky.
  Advice: switch to plan mode (⌥+p) BEFORE starting.
  In auto: risk of rework, inconsistent decisions, surprise dep changes.

  Optimal:
  1. ⌥+p → plan mode
  2. /model opus-4-7 → plan
  3. After plan → /model sonnet-4-6 → implementation
  4. /model opus-4-7 → review

  Or keep going, I'll try to avoid rework.
```

### Architectural + auto-mode (strongest, but doesn't block)
```
💠 JARVIS: ⚠️ ARCHITECTURAL task in auto mode.
  Very risky — major refactors need a plan with checkpoints.

  Strongly advised:
  1. ⌥+p → plan mode (mandatory)
  2. /model opus-4-7 → Opus for plan and review
  3. Add 2-3 confirmation checkpoints
  4. Sonnet for mechanical edits

  Continuing in auto without this — high risk. Your call.
```

### Trivial + plan-mode — reverse suggestion
(once per day, not more)
```
💠 JARVIS: simple task in plan mode — if this is frequent, auto mode is faster. ⌥+\\ to switch.
```

## Principles

1. **Simple language** — no "tier-1", "archetype", "context window optimization"
2. **Concrete action** — "press ⌥+p", "/model sonnet"
3. **Short explanation** — "saves 5-10x on long work", not a lecture
4. **Exit available** — "just keep typing"
5. **Don't block** — JARVIS always lets you ignore
6. **Mode-aware** — different advice for auto / plan / ask-to-edit
7. **Anti-spam for mode hints** — one hint of a kind per session/day