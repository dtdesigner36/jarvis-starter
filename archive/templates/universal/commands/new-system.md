---
name: new-system
description: Scaffold wiki/Systems/<Name>.md + update HOME.md + devlog entry
---

# New System Scaffold

One call creates the full wiki structure for a new system.

## Usage

`/new-system <Name>` or `/new-system <Name> <description>`

## Steps

1. Create `wiki/Systems/<Name>.md` using template (with TL;DR)
2. Add link to `wiki/HOME.md` in the Systems section
3. Add a devlog entry with today's date

## Template

```markdown
---
tags: [system, <name-lowercase>]
status: wip
---
# <Name>

## TL;DR
- <key fact 1>
- <key fact 2>
- <key fact 3>

## Description
<what this system does>

## Key files
- `<path>` — <role>

## Patterns / pitfalls
<known gotchas>

## Related
→ [[OtherSystem]]
```
