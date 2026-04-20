# Phase 5 — Post-Bootstrap Advice Templates

After a successful bootstrap (Phase 3-4), JARVIS gives starter recommendations.

## Output structure

```
✅ Bootstrap complete. Archetypes: {{ARCHETYPES}}

📊 Recommendations:

1. [Automatically enabled]
   • Lean CLAUDE.md (~XXX tokens/turn)
   • Wiki as external docs
   • N hook rules for your stack
   • JARVIS core (wiki maintenance + task routing + memory recall + focus tracker)

💡 Suggestions for the future:
{{SUGGESTIONS}}

🎓 Bonus (optional):
   • jarvis school on — if you want to learn the stack
   • NOT enabled automatically — your choice

Run /jarvis audit anytime for a current load assessment.
```

## Archetype-specific recommendations

### telegram-bot + web-app
- "Use subagents for independent work on bot and dashboard"
- "JWT between them, so you don't maintain two auth systems"
- "Shared DB via Prisma, so nothing gets out of sync"

### web-app (simple)
- "/impeccable teach — create .impeccable.md (design context)"
- "Tailwind + tokens.css for design system"
- "Playwright MCP for browser testing"

### web-api
- "API contract via shared TypeScript types (if a client exists)"
- "Swagger/OpenAPI if the API is public"
- "Prisma Studio for visual DB debugging"

### game
- "obsidian-canvas for visual navigation across systems"
- "balance command especially important when tuning numbers"
- "playtest before release — mandatory"

### parser
- "Rate limits — keep in .env, not in code"
- "Retry logic — mandatory"
- "Data schema — document in wiki/Sources/"

### llm-agent
- "Prompt caching to save cost (if using Claude API)"
- "Tracing via Langfuse/LangSmith"
- "Evals before production"

## Expected load metrics

Show the user what to expect:

```
Expected token footprint:
  Startup: ~3-4K tokens (CLAUDE.md + hooks + skills meta)
  Medium task: +5-10K (Sonnet work)
  Complex task: +20-40K (Opus work + long session)

Ideal workflow:
  • Open Claude Code
  • JARVIS core active (0 tokens at rest)
  • Describe the task
  • Get task-routing advice (if Medium+)
  • Work in the recommended model
  • Wiki is kept fresh automatically
```

## Warnings

If load is close to the limit:
```
⚠️ Startup load is high (5K+). Suggestions:
   • Trim CLAUDE.md (currently N lines)
   • Remove unused skills (jarvis suggest)
```
