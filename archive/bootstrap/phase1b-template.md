# Phase 1b — Custom Archetype Generation

When the user prompt doesn't match Tier 1/Tier 2 archetypes. A custom archetype is generated on the fly.

## When it triggers

- Classification scores of all known archetypes < 30
- User rejected the proposed options in an ambiguous case
- Explicit request: "that's not it, my project is specific"

## Workflow

### Step 1 — Clarifying questions

Via AskUserQuestion (up to 4 questions):

1. **Platform / runtime?**
   - Examples: browser, Node.js, Python, Docker, AWS Lambda, Rust binary

2. **Primary language?**
   - TypeScript, Python, Go, Rust, Swift, Kotlin, Java, C#

3. **Is there a UI? What kind?**
   - CLI, web, mobile, desktop, no UI (daemon/worker)

4. **Main project goal in one sentence?**

### Step 2 — Find the closest Tier 2 archetype

The custom project may still resemble something from Tier 2 — use it as a base:
- Example: "PDF processor daemon" can be close to `parser` + `cron-scheduler`
- Example: "VSCode plugin for colorizing" — based on `extension`

If found — use it as the starting overlay + adapt.

### Step 3 — GitHub discovery

Specifically for this project, sweep GitHub with queries:
- `"claude code" skill <area from answers>`
- `<language> <task>` template

Include community-verified skills found in the proposal.

### Step 4 — Generate custom overlay

Generate on the fly:

```markdown
# Custom Archetype: <Name>

**Stack:** <stack from answers>

**Triggers in CLAUDE.md:**
- <file pattern> → <skill> (if applicable)
- <event> → <reminder>

**Wiki structure:**
- <recommended folders based on type>

**Recommended skills:**
- <from known-registry + GitHub discovery results>

**Typical challenges:**
- <3-5 pitfalls for this type, generated from knowledge>
```

### Step 5 — Save

Ask the user:
- Save this archetype for future use?

If yes:
- Save to `~/.jarvis-starter/custom-archetypes/<slug>.md` (global for this user)
- Or to `.claude/archetype.md` (this project only)

Saved globally — next project of the same type recognizes it faster.

## Example

```
User: "jarvis start: browser extension that auto-downloads YouTube videos in high quality with metadata from an API"

JARVIS: doesn't quite match known archetypes. Let me clarify:
  1. Target browser? (Chrome/Firefox/both)
  2. Language? (TS/JS)
  3. Popup UI or context menu only?
  4. Is there a backend (for metadata API) or everything in the browser?

User: Chrome, TS, popup exists, metadata via fetch directly from the extension

JARVIS: got it, generating custom archetype "chrome-extension-downloader":
  - Stack: TypeScript + Chrome Manifest V3 + Vite
  - Close to `extension` archetype (using as base)
  - Triggers: manifest.json changed → permissions audit
  - Wiki: Permissions/, Storage/, Popup/, ContentScripts/
  - Skills: (base + found alice/chrome-ext-helper 45★)

  Save this archetype for future chrome extensions?
```
