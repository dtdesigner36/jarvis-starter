# Filter Rules — filtering skills for the project context

## Base filters (always applied)

1. **Archetype match** — skill marked as matching current archetypes (from `.jarvis/state.md`)
2. **Stars threshold** — at least 20 (or community-verified)
3. **Recency** — updated within last 6 months
4. **Not archived** on GitHub
5. **SKILL.md valid** (frontmatter with name and description)

## Contextual filters

### By project stack
If the project is Python — filter out Node-only skills and vice versa (except tool-agnostic ones like Playwright).

### By what's already installed
Exclude skills already installed locally (`.claude/skills/`, `.agents/skills/`).

### By conflict
If a proposed skill conflicts with an existing one (same task, different approach) — warn, don't silently add.

## Negative filters (auto-exclude)

- Skills without a LICENSE or with a restrictive license
- Skills that require paid API keys if the user didn't mention such a service
- Skills with `user-invocable: false` if the user asked for a specific command

## Confidence scoring

Each proposed skill gets a score 0-100:
- 90-100: perfect match (archetype + stack + high reputation + fresh)
- 70-89: good match (archetype + medium reputation OR archetype + high reputation but old)
- 50-69: possible match (partial fit)
- <50: not shown

## Output order

Top 3-5 skills with score >= 70.
If after filters < 3 — mention "only found N, possibly no good fit"; suggest `jarvis find registry` to check the known registry.