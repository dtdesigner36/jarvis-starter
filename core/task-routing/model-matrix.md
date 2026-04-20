# Model Matrix — which model for which task

| Class | Model | Plan mode | Rationale |
|-------|-------|-----------|-----------|
| Trivial | Haiku 4.5 | no | Faster, cheaper, accuracy is sufficient |
| Simple | Sonnet 4.6 | no | Quality/cost balance |
| Medium | Sonnet 4.6 | **recommended** | Without plan — risk of rework |
| Complex | Opus 4.7 (plan) → Sonnet (impl) → Opus (review) | **mandatory** | Opus solves hard tasks 50-70% better |
| Architectural | Opus 4.7 everywhere | **mandatory + confirmation checkpoints** | Cost of error high, Opus worth the tokens |

## Pricing (September 2025)

| Model | Input (per 1M tokens) | Output | Relative cost vs Haiku |
|-------|-----------------------|--------|------------------------|
| Haiku 4.5 | $0.25 | $1.25 | 1x |
| Sonnet 4.6 | $3 | $15 | 12x |
| Opus 4.7 | $15 | $75 | 60x |

**Opus is 60x more expensive than Haiku** — but for hard tasks, quality justifies it. For Medium-Simple, Sonnet vs Opus saves 5x.

## Switching rules

- **Starting a hard task on Opus:** plan → switch to Sonnet for the mechanical work → switch back to Opus for review
- **Stuck on Sonnet?** Switch to Opus just for that question, then back
- **For CSS/polish:** almost always Sonnet (or Haiku if trivial)
- **For Prisma/TypeScript types/architecture:** Opus is genuinely better

## Cache

Prompt caching works better in long stable sessions on one model. Frequent model switches break the cache. Therefore:
- Better 2 long sessions (one Opus, one Sonnet) than 10 short ones with switches
- In a long session, switch only between phases (plan → implementation)