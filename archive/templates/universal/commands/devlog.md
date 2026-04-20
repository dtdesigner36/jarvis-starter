---
name: devlog
description: Add a dated entry to wiki/Devlog/README.md — use after any non-trivial decision or implementation
---

# Devlog Entry

Adds an entry to `wiki/Devlog/README.md`.

## Usage

`/devlog <topic>` or `/devlog` (infer from context).

## Steps

1. Read `wiki/Devlog/README.md`
2. Compose entry:
   ```markdown
   ### <YYYY-MM-DD> — <topic>
   <1-3 sentences: what was done/decided>
   **Why:** <motivation>
   ```
3. Insert after `## Entries` heading (newest first)
4. Save

## Entry rules

- Date: today (currentDate)
- Topic: short noun phrase
- Body: past tense, factual
- **Why:** mandatory — this is the most valuable part
- No bullets inside entries
- Max 5 sentences

## Proactive usage

Automatically create an entry (without `/devlog` call) when:
- Architectural decision
- Bug fix with non-trivial fix
- New system added
- Significant refactor
