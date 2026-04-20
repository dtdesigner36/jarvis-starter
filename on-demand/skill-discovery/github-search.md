# GitHub Skill Discovery

Search for Claude Code skills on GitHub for a specific project need.

## When used

1. **Bootstrap** (Phase 2): automatic search for skills matching the archetype
2. **Mid-project** (`jarvis find "<need>"`): user wants a skill for a specific task

## Algorithm

### Step 1 — Query formation

Based on `need` (from user) + current archetypes (from `.jarvis/state.md`):

```
Queries = [
  '"claude code" skill <need>',
  'site:github.com SKILL.md <need>',
  '"awesome-claude-skills" <need>',
  '<need> claude-code' (if earlier queries yielded little)
]
```

### Step 2 — WebSearch + result collection

Run WebSearch for the first query; if <5 results — try the next, etc.

Collect all candidates with metadata: URL, stars, last-updated.

### Step 3 — Reputation filter

**Minimum thresholds:**
- At least 20 stars (or explicit "community-verified" mention in README)
- Updated within the last 6 months
- SKILL.md exists with valid frontmatter (name, description)
- Not archived

### Step 4 — WebFetch SKILL.md for validation

For the top 10 candidates — WebFetch their SKILL.md.
Check:
- Does the description match `need`?
- `user-invocable: true` (if needed as a slash command)
- No suspicious dependencies in scripts/

### Step 5 — Ranking

Score = stars × freshness_factor × relevance

Where:
- `freshness_factor = max(0.3, 1 - months_since_update/12)`
- `relevance = keyword overlap SKILL.md vs need`

### Step 6 — Present to user

Top 3-5 with preview:
```
💠 JARVIS: found for "<need>":

1. alice/pdf-parser-skill — 142★, 2 weeks ago
   "Parses PDFs with OCR, extracts structured data"
   Install: npx skills add alice/pdf-parser-skill

2. bob/document-extractor — 87★, a month ago
   "Extract tables and text from PDF/DOCX"
   Install: npx skills add bob/document-extractor

Install? Type a number or "no".
```

## Cache

Save results in `.jarvis/cache/discovery-<hash-of-query>.json` with date.
- If cache < 7 days — use it
- Otherwise — re-research

## Known skill registries

Also check:
- [travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) — curated list
- [Anthropic skills repo](https://github.com/anthropics/skills) — official

## Fallback

If WebSearch is unavailable OR nothing relevant was found:
- Show "nothing found on GitHub, try the known registry: `jarvis find registry "<need>"`"
- Reference `known-registry.md`