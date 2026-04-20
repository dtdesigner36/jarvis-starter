# jarvis security deps — dependency audit

Check known vulnerabilities in npm/pip/cargo/etc. dependencies.

## Usage

```
> jarvis security deps
> jarvis security deps --fix  # apply auto-fixes where possible
```

## By stack

### Node.js (package.json)
```bash
npm audit
# or
pnpm audit
# or
yarn audit
```

Parse output, categorize by severity (LOW/MEDIUM/HIGH/CRITICAL).

### Python (pyproject.toml / requirements.txt)
```bash
pip-audit
# or
safety check
```

### Rust (Cargo.toml)
```bash
cargo audit
```

### Go (go.mod)
```bash
govulncheck ./...
```

### Ruby (Gemfile)
```bash
bundle audit
```

## Workflow

1. Determine the stack from `.jarvis/state.md` or detect from config files
2. Run the appropriate audit tool
3. Categorize results
4. Propose actions

## Output

```
💠 JARVIS Deps Audit

Stack: Node.js (package.json)
Run: npm audit

Vulnerabilities: 5 found
  🔴 2 HIGH:
    • axios@0.21.1 — CVE-2021-3749 (SSRF)
    • ws@7.4.2 — CVE-2021-32640 (DoS)
  🟡 2 MEDIUM:
    • lodash@4.17.19
    • semver@5.7.1
  🔵 1 LOW:
    • chalk@3.0.0

Actions:
  • npm audit fix           — attempt auto-fix (safe)
  • npm audit fix --force   — including major upgrades (risky)

For critical CVE-2021-3749:
  npm install axios@^1.6.0
  (major upgrade, check for breaking changes)
```

## Regular schedule

Can be proposed via `cron-scheduler` or a CI hook:
- `npm audit --audit-level=high` in CI before merge
- JARVIS can remind via wiki-maintenance if audit > 30 days ago

## Cost

500 tokens + npm audit execution time (usually < 10 sec).