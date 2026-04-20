# jarvis audit — comprehensive project audit

Full check: code quality + wiki + skills + tokens + architecture.

## Usage

```
> jarvis audit
> jarvis audit quick    # key points only
> jarvis audit full     # everything, with metrics
```

## What's checked

### 1. Wiki health
(delegates to `on-demand/docs.md`)
- Currency of System files
- Presence of TL;DR
- Coverage of active modules

### 2. Token load
Estimate of context load at session start:
- CLAUDE.md size (~tokens)
- Installed skill count (each can add context when triggered)
- `.jarvis/` files size
- Hook output estimate

Compared against baseline in `.jarvis/token-baseline.md`:
```
Baseline at bootstrap: 3.2K tokens/turn
Current: 5.8K tokens/turn (+80%)
  • CLAUDE.md grew from 400 to 1200 lines ← main growth
  • 6 new skills installed
```

### 3. Skills usage
Check: which skills are installed, which are used, which are forgotten.
```
Installed: 14 skills
Used in the last 30 days: 9
Never: 5 (suggest: remove or archive)
```

### 4. Code quality signals

Simple checks (no AST, via grep):
- Hardcoded strings/numbers in multiple places
- Duplicate patterns (recurring 10-line blocks)
- TODO/FIXME without a date
- Console.log / print() in production code

### 5. Architecture health
- Is there a `.env.example`?
- Are there tests?
- Is CI set up?
- Is there a README for new contributors?

### 6. Dependency health
- Outdated dependencies (via `npm outdated` / `pip list --outdated`)
- Security warnings (via `npm audit` if applicable)
- Good moments to upgrade (major version changes)

## Output

```
💠 JARVIS: Audit Report

═══ Wiki Health: 7/10 ═══
  ⚠️ 3 System files possibly stale
  ✅ TL;DR in 8/9 files

═══ Token Load: 5.8K/turn (+80% vs baseline) ═══
  Growth mainly due to CLAUDE.md (1200 lines)
  Suggestion: move some into wiki

═══ Skills: 14 installed, 9 active ═══
  Forgotten (30 days): screenshot-diff, theme-token, ...
  Suggestion: remove unused

═══ Code Quality: OK ═══
  8 TODOs without a date — could clean up

═══ Architecture: 6/10 ═══
  ❌ No `.env.example`
  ❌ No tests
  ✅ CI configured

═══ Dependencies: 12 outdated, 2 minor security ═══

What to fix? Say priorities or "jarvis suggest" for structured proposals.
```

## Token cost

Full audit — 3-5K tokens. Runs rarely (once a month). Quick audit — 500-1K tokens.