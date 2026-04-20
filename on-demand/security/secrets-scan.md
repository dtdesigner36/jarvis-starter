# jarvis security secrets — secrets scan

Full scan of code + git history for hardcoded secrets.

## Usage

```
> jarvis security secrets
> jarvis security secrets --history  # also git log
```

## Workflow

### 1. Scan current files
Run `core/security-watch/secret-scanner.sh` on all project files:
- Exclude: `node_modules/`, `dist/`, `build/`, `.next/`, `.git/`
- Apply all patterns from `patterns.md`

### 2. Git history scan (if --history)

```bash
# Search commits for traces of secrets
git log -p | grep -E "(sk-ant|sk-[A-Za-z0-9]{20}|AKIA[0-9A-Z]{16}|BOT_TOKEN=['\"][0-9]{8})"
```

If found — **the secret is compromised** even if removed from the latest commit. You need to:
1. Rotate the secret with the provider
2. Remove from history via `git filter-repo` or BFG Repo-Cleaner
3. Force-push (careful if repo is public)

### 3. Output

```
💠 JARVIS Secrets Scan

Current files: 2 secrets found
  🔴 src/config.ts:14 — Telegram bot token
  🔴 src/api.ts:8 — OpenAI API key

Git history: 1 secret
  🔴 commit abc123 (3 weeks ago): committed .env

Actions:
1. Immediately rotate these secrets with the providers (Telegram, OpenAI)
2. Move to .env (check .gitignore)
3. For history — use `git filter-repo --path .env --invert-paths`

Show specific lines? (y/n)
```

## Cost

500-1000 tokens + `grep` pass. Fast.