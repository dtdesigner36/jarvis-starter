# jarvis forget — remove from memory

## Usage
```
> jarvis forget "<fact>"
> jarvis forget "old decision about X"
```

## Workflow

1. Search `.jarvis/memory.md` for matching entries
2. Show matches:
   ```
   💠 JARVIS: found 2 entries:
     1. 2026-04-20 — "API uses bearer token, not sessions"
     2. 2026-03-15 — "switched to JWT"

   Remove? Say a number or "all"
   ```
3. Remove selected entries from memory.md
4. Confirm

## Use cases
- Outdated decision (switched to something else)
- Mistakenly recorded
- Changed your mind
