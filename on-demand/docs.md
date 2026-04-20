# jarvis docs — check wiki freshness

Verifies wiki/ against current code state. Finds what's stale.

## Usage

```
> jarvis docs
```

## Workflow

### 1. Scan wiki

For each `wiki/Systems/<X>.md`:
- Find mentioned files/paths (`server/src/modules/X/`, `src/features/X/`)
- Get last-modified dates of the corresponding code files
- Get last-modified date of the wiki file

If `code_mtime > wiki_mtime + 7_days` → possibly stale.

### 2. Scan git diff (if git)

```bash
git log --since="1 week ago" --name-only --pretty=format: | sort -u
```

Intersect changed files with what's mentioned in wiki.

### 3. Scan gap between TL;DR and reality

For each System file with a TL;DR — check whether mentioned key files/models exist in code. If TL;DR says X and X is not in code → stale.

### 4. Output

```
💠 JARVIS: wiki check (9 System files):

⚠️ Possibly stale (3):
  • wiki/Systems/Auth.md — handlers/auth/ changed 5 days ago, wiki 3 weeks
  • wiki/Systems/Payments.md — mentions Stripe v3, code is v4
  • wiki/Systems/User.md — TL;DR talks about session storage, code switched to JWT

✅ Current (5):
  • Combat, Skills, Inventory, World, Economy

❓ Missing TL;DR (1):
  • wiki/Systems/Quests.md — add TL;DR for quick reading

Update stale ones? Say which or "all".
```

### 5. Update

If the user says "update Auth" → JARVIS:
- Reads current `handlers/auth/*`
- Compares with wiki/Systems/Auth.md
- Proposes specific edits to TL;DR and sections
- Applies after confirmation

## Automation via hook

`core/wiki-maintenance/hook-detector.sh` already reminds about staleness. `jarvis docs` is the manual deep audit.