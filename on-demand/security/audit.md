# jarvis security — comprehensive security audit

Full security audit of the project, on user request.

## Usage

```
> jarvis security          # full audit
> jarvis security secrets  # secrets only
> jarvis security deps     # dependencies only
> jarvis security quick    # quick check
```

## What's checked (full audit)

### 1. Secrets in code
See `secrets-scan.md`. Run `secret-scanner.sh` across all project files + git history (`git log -p` → grep patterns).

### 2. Git hygiene
- Does `.gitignore` contain: `.env`, `.env.local`, `.env.*.local`, `node_modules`, `dist`, `*.key`, `*.pem`?
- No secrets in staging?
- No accidentally committed secrets in history?

### 3. Dependencies
See `deps-audit.md`. `npm audit` / `pip-audit` / `cargo audit` / `bundler-audit`.

### 4. Permissions / Exposed surfaces

**For web-api:**
- Rate limits on public endpoints?
- CORS configured (not `*` in production)?
- CSP headers?
- DTO validation on all controllers?

**For web-app:**
- XSS via dangerouslySetInnerHTML (if used — justified?)
- Inline scripts in HTML?
- Secure cookies (httpOnly, secure, sameSite)?

**For telegram-bot/discord-bot:**
- Bot token not in code?
- Webhook signature verification?
- Rate limits on handlers?

**For extension:**
- Minimal permissions in manifest.json?
- Content scripts not injecting into sensitive domains?
- CSP in manifest?

**For desktop (Electron):**
- `nodeIntegration: false`?
- `contextIsolation: true`?
- Minimal `preload` scripts?

**For desktop (Tauri):**
- tauri.conf.json permissions — minimal?
- Allowlist API calls strictly scoped?

### 5. Auth patterns

- Passwords via bcrypt/argon2, not plain?
- JWT: expiration set? refresh rotation?
- Session fixation protection?
- Password reset: rate-limited + expiring tokens?

### 6. Input validation

- API endpoints validate input (class-validator / pydantic / zod)?
- SQL queries through an ORM, not raw?
- File uploads: type/size limits?

## Output

Structured report:

```
💠 JARVIS Security Audit

═══ Secrets: 0 found ═══
✅ Code clean

═══ Git: 8/10 ═══
✅ .gitignore correct
⚠️ Found 2 old .env commits in history — consider `git filter-repo`

═══ Dependencies: 3 vulnerabilities ═══
🔴 axios 0.21.1 — HIGH (CVE-2021-3749)
🟡 lodash 4.17.19 — MEDIUM
🟡 semver 5.7.1 — LOW

═══ Auth patterns: 5/7 ═══
✅ Passwords via bcrypt
❌ JWT without expiration
❌ No rate limit on /login

═══ Input validation: 7/10 ═══
⚠️ 3 controllers without DTO validation

═══ Archetype-specific (web-app) ═══
✅ No dangerouslySetInnerHTML
⚠️ CSP header missing

📊 Overall: 7/10 — needs attention.

Fix priority:
1. 🔴 axios update (npm update axios)
2. 🔴 JWT expiration + rate limit on /login
3. 🟡 3 controllers — add DTO validation
4. 🟡 CSP header setup
```

## Cost

- `jarvis security` — full: 3-5K tokens
- `jarvis security quick` — key checks: 1K tokens
- `jarvis security secrets` — secrets only: 500 tokens
- `jarvis security deps` — deps only: 500 tokens (+ npm/pip call)

## Integration with anthropics/skills#security-review

If the user has installed this official skill — JARVIS delegates part of the checks to it.