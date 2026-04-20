# Wiki Update Templates

When JARVIS proposes a wiki update, it uses these templates.

## Template: new System.md

```markdown
---
tags: [system, <name-lowercase>]
status: wip
---

# <Name>

## TL;DR
- <1 line: what the system does>
- <1 line: key file/module>
- <1 line: important pattern or pitfall>

## Description
<1-2 paragraphs: what this system does>

## Key files
- `<path>` — <file role>

## Patterns / pitfalls
<Optional section — fills in over time>

## Related
→ [[OtherSystem]] · [[Architecture]]
```

## Template: architecture entry

```markdown
---
tags: [architecture, <topic>]
---

# <Topic>

## TL;DR
- <main principle>
- <key implementation detail>
- <main pitfall>

## Approach
<Description>

## When it applies
<Context>
```

## Template: devlog entry (for `jarvis remember` or major changes)

```markdown
### <YYYY-MM-DD> — <topic>
<1-3 sentences: what was done/decided>
**Why:** <motivation or constraint>
```

## Template: TL;DR for existing files

If JARVIS notices a System file without a TL;DR, it proposes:

```markdown
## TL;DR
- <key fact 1>
- <key file>
- <important pattern or gotcha>
```

Placed right after frontmatter and before the `#` heading.

## Filling rules

- **TL;DR is mandatory** — this is the main token optimization (it's read first)
- **Max 3-5 lines** in TL;DR
- **No generic phrases** — be specific
- **Links in `[[Link]]` format** (works in Obsidian and other vault-compatible editors)
- **Frontmatter is required** for tags/status — works with Dataview and Bases in Obsidian