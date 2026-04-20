# Memory Recall Rules

When to inject an "already solved" hint, and when to stay silent.

## Triggers if

- Prompt is longer than 30 characters (not a tiny edit)
- `.jarvis/memory.md` has an entry matching a keyword (4+ letters)
- OR `wiki/Systems/*.md` has a system whose name matches a keyword

## Does NOT trigger if

- Short prompt (< 30 chars)
- Only common words in prompt (will, might, need, ...)
- User explicitly said "don't remind me about X"

## Keyword filter

Skip: the, a, an, will, would, might, need, needs, want, make, do, this, that, these, those, just, also, only, is, are, now, when, after, before, so, that.

Match on 4-letter prefix (authorization → auth, users → user).

## Output format

```
💠 JARVIS: found that you've already solved something similar:
  • [[wiki/Systems/Auth.md]] — already documented
  • JWT with refresh token rotation (memory)
  (don't reinvent — use what's there)
```

Max 3 wiki matches + 2 memory matches to avoid context noise.

## Learning

If the user says "I know, but I want to do it differently" — JARVIS can remember:
```
> jarvis remember "for this project, auth via sessions, not JWT like the old one"
```

This updates memory.md and surfaces in the future.

## Anti-spam

- Don't trigger the same hint more than 2 times per session
- Tracking in `.jarvis/focus.md` (which topics already surfaced today)