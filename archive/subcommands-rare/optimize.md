# jarvis optimize — token optimization

## Usage
```
> jarvis optimize
> jarvis optimize claude-md
> jarvis optimize skills
```

## Only on explicit request

JARVIS doesn't push optimization on its own. This command is explicitly called by the user.

## Workflow

### 1. Measure current state

- CLAUDE.md size (lines, ~tokens)
- Number of hooks (and how much each outputs when triggered)
- Number of skills installed (auto-loaded meta)
- `.jarvis/` total size
- Hook output estimate

### 2. Compare with baseline

`.jarvis/token-baseline.md` recorded values at bootstrap. Show diff:

```
Baseline (bootstrap): 3.2K tokens/turn
Current: 5.8K tokens/turn (+80%)

Main growth sources:
  • CLAUDE.md grew from 400 to 1200 lines (+800 tokens)
  • 6 new skills installed (~600 tokens meta)
  • .jarvis/memory.md grew (200 lines, +400 tokens)
```

### 3. Propose specific optimizations

```
💡 Suggestions:

1. CLAUDE.md — move Frontend rules to wiki:
   - Frontend section 300 lines → into wiki/Architecture/FrontendRules.md
   - Saves ~200 tokens/turn

2. Remove 3 unused skills (not invoked in 30 days):
   - /old-command-1, /old-command-2, /old-command-3
   - Saves ~200 tokens

3. Memory.md — archive old entries:
   - Move entries >3 months to .jarvis/memory-archive.md
   - Saves ~200 tokens

Apply which? Say numbers or "all".
```

### 4. Apply

On confirmation — move, remove, archive.
Update baseline after optimization.

## Periodically

Not automatic, but `jarvis audit` can remind: "last optimize was 2 months ago, context grew 80%".
