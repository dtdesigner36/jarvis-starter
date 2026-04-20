# jarvis suggest — quality improvement suggestions

When the user wants to know "what can be improved in the project".

## Usage

```
> jarvis suggest
> jarvis suggest quality
> jarvis suggest skills
> jarvis suggest docs
```

## Workflow

### 1. Collect state
- `.jarvis/state.md` — archetypes, stack
- `.jarvis/focus.md` — recently touched areas
- `wiki/` — what's documented
- `package.json` / `pyproject.toml` — dependencies

### 2. Find gaps

**Documentation gaps:**
- Actively changing modules without `wiki/Systems/<X>.md`
- Wiki files without a TL;DR section
- `wiki/Architecture/` empty while code has many patterns

**Skill gaps:**
- No installed skill that would strongly help the archetype (e.g., web-app without impeccable)
- A popular new command appeared — JARVIS knows about it via `on-demand/skill-discovery/`

**Code quality gaps:**
- Hardcoded values without centralization (JARVIS can detect via grep)
- Repeating code patterns
- Missing types / validation at boundaries

**Architecture gaps:**
- No tests
- No CI
- No ENV management (`.env.example`)

### 3. Prioritize

By value for the current project state:
- High — quality blockers (no tests, no CI)
- Medium — needed but not critical (wiki gaps, centralization)
- Low — nice-to-have (theme tokens, animations)

### 4. Output

```
💠 JARVIS: improvement suggestions (sorted by priority):

🔴 High:
  • No `.env.example` — add? (risk: secrets in git)
  • Module `handlers/auth/` actively changes without wiki/Systems/Auth.md

🟡 Medium:
  • `wiki/Architecture/` is empty — at least record the auth pattern?
  • Found skill `alice/bot-testing` — would help with your handlers

🟢 Low:
  • Hardcoded colors in 4 places — extract to theme-tokens?

Which to apply? Say numbers or "all high".
```

### 5. Execution

If the user says "yes, high" — JARVIS does:
- For wiki-gaps: `new-system` or `/devlog`
- For skill-gaps: `jarvis find` + install
- For code gaps: propose specific edits
- For infrastructure: create templates (`.env.example`)

## Frequency

JARVIS **does NOT** run suggest automatically. Only on request. 0 tokens at rest.

But it may remind once every 14 days via wiki-maintenance hook: "💠 JARVIS: no `suggest` in a while — `jarvis suggest` for a review."