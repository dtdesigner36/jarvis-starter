# Task Classifier Rules

Determines task complexity based on the user prompt. Used by `prompt-analyzer.sh`.

## 5 classes

### Trivial
**Signals:**
- Prompt < 50 characters
- Keywords: "typo", "rename", "fix name", "add period", "style tweak"
- Clearly one file

**Recommendation:** Haiku, no plan mode.
**JARVIS:** silent.

### Simple
**Signals:**
- Prompt 50-150 characters
- One component or one function
- Clear local task

**Recommendation:** Sonnet, no plan mode.
**JARVIS:** silent.

### Medium
**Signals:**
- Prompt 150+ characters
- 2-4 files touched
- Multiple decisions involved
- Keywords: "add feature", "build X system", "implement Y"

**Recommendation:** Sonnet + plan mode.
**JARVIS:** short plan-mode suggestion.

### Complex
**Signals:**
- Long prompt (200+ characters)
- Several systems / modules mentioned
- Keywords: "new system", "full implementation", "e2e", "end-to-end", "from scratch"

**Recommendation:** Opus for planning → Sonnet for implementation → Opus for review.
**JARVIS:** staged breakdown.

### Architectural
**Signals:**
- Keywords: "refactor", "stack change", "migration to", "rewrite architecture"
- "change the pattern", "new paradigm"

**Recommendation:** Opus + plan mode mandatory + confirmation checkpoints.
**JARVIS:** strong plan-mode push.

## Mode-aware advice

JARVIS tries to detect current permission mode via:
1. Payload session meta (if available)
2. `.claude/settings.json` → `permissions.defaultMode`
3. `.claude/settings.local.json` (overrides)

Possible modes:
- `auto` / `acceptAll` / `bypassPermissions` — Claude edits without confirmation
- `plan` — plan mode, always approval
- `ask` / `default` — ask-to-edit (default)
- `unknown` — couldn't determine

### Logic by CLASS × MODE combination:

| CLASS × MODE | What we do |
|--------------|-----------|
| Trivial + plan | Suggest auto-mode (**once per day**): "for this simple task auto is faster" |
| Simple + * | Silent |
| Medium + auto | Warn: "Medium in auto — risk of rework, switch to plan mode" |
| Medium + plan/ask | Usual Sonnet + plan suggestion |
| Complex + auto | **Strong push** out of auto: plan mode mandatory + model switching |
| Complex + plan/ask | Standard staged breakdown (Opus → Sonnet → Opus) |
| Architectural + auto | ⚠️ Critical warning: risky in auto mode |
| Architectural + plan/ask | Strict recommendation with checkpoints |

**Important:** JARVIS **does not block** work even in worst case. Gives advice, user decides.

## Skills mention in plan (when Claude drafts a plan in plan-mode)

Transparency for vibe-coders: which skills run at which steps. Scale by class:

| Class | Mention skills in plan |
|-------|------------------------|
| Trivial | ❌ no (usually no plan) |
| Simple | ❌ no (too much noise for simple task) |
| Medium | ✅ briefly, one line at end: "after edits I'll run /css-audit and /responsive-check" |
| Complex | ✅ per step (1 line per step where relevant): "1. Design: skill `shape` ..." |
| Architectural | ✅ full per-step breakdown + model for each stage |

### Rule for Claude when drafting a plan

When writing a plan for Medium+ task:
1. In the **Steps** section, indicate for each step which skill/command is used (if applicable)
2. Write compactly: `→ skill X` or `→ /command` — no expanded explanations
3. Don't overload — if a step doesn't need special skills, don't write "no skills"
4. At the end of the plan, add a **Verification** section: which skills for checks (`/audit`, `/css-audit`, etc.)

### Example Complex plan with skill mentions

```markdown
## Steps

1. **UX Design** — skill `shape` generates brief (pages, states, interactions)
2. **Implementation frontend** — Sonnet + Edit, creating components
3. **Polish** — skill `typeset` (typography) + `colorize` (colors)
4. **Backend endpoints** — /api-contract after controller/service

## Verification

- skill `audit` (a11y + perf + tokens)
- /responsive-check for mobile/tablet
- /i18n-sync if t()/ts() added
```

### Why this matters

- **Transparency** for vibe-coder — sees what's happening under the hood, learns
- **Ability to decline** — "don't use impeccable, I want simpler"
- **Predictability** — `audit` can take 3-5K tokens, user should know
- **Doesn't hurt** — 50-150 tokens in a Complex plan is nothing

## Anti-spam

- If the user repeatedly ignored advice for a class — add `ignore-routing-<CLASS>` to `.jarvis/memory.md`
- JARVIS then stays silent for that class

## Learning

`.jarvis/memory.md` stores user patterns:
- Which advice they listen to
- Which they ignore
- Which tasks they classify differently (override)

Via `jarvis remember "for UI fixes, don't suggest Haiku"` — explicit disabling of specific advice.