#!/bin/bash
# JARVIS security-watch: secret scanner
# PostToolUse on Edit/Write — detects hardcoded secrets, credentials, tokens

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE" ] || [ ! -d ".jarvis" ]; then
  exit 0
fi

# Skip if disabled
if [ -f ".jarvis/plugins.md" ] && grep -q "security-watch: off" ".jarvis/plugins.md"; then
  exit 0
fi

# Skip non-code files and node_modules
if echo "$FILE" | grep -qE "(node_modules|\.next|dist|build|\.cache|\.git)/"; then
  exit 0
fi

# Only scan code files
if ! echo "$FILE" | grep -qE "\.(ts|tsx|js|jsx|py|go|rs|java|rb|php|c|cpp|yaml|yml|json|env|sh)$"; then
  exit 0
fi

# File missing or unreadable — skip
if [ ! -r "$FILE" ]; then
  exit 0
fi

WARNINGS=""

# ─── Secret patterns ──────────────────────────────────────────────

# Telegram bot token: digits:alphanumeric (typically 8-10 digits + : + 35+ chars)
if grep -qE "['\"][0-9]{8,10}:[A-Za-z0-9_-]{35,}['\"]" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Telegram bot token — move to .env!"
fi

# Anthropic API key
if grep -qE "sk-ant-[A-Za-z0-9_-]{20,}" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Anthropic API key (sk-ant-...) — move to .env!"
fi

# OpenAI API key
if grep -qE "sk-[A-Za-z0-9]{20,}" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • OpenAI API key (sk-...) — move to .env!"
fi

# Slack tokens
if grep -qE "xox[bpoa]-[A-Za-z0-9-]{20,}" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Slack token (xoxb/xoxp/...) — move to .env!"
fi

# AWS Access Key
if grep -qE "AKIA[0-9A-Z]{16}" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • AWS Access Key (AKIA...) — move to .env!"
fi

# Generic BOT_TOKEN / API_KEY / SECRET with hardcoded value
if grep -qE "(BOT_TOKEN|API_KEY|SECRET|PRIVATE_KEY|PASSWORD)\s*=\s*['\"][A-Za-z0-9_.+/=-]{16,}['\"]" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Hardcoded credential (BOT_TOKEN/API_KEY/SECRET/...) — move to .env!"
fi

# JWT secrets (HS256 signing keys)
if grep -qE "(jwt_secret|JWT_SECRET|jwtSecret)\s*[:=]\s*['\"][A-Za-z0-9_.+/=-]{12,}['\"]" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • JWT secret hardcoded — use an env variable!"
fi

# Database URL with credentials
if grep -qE "(postgres|mysql|mongodb)://[^:]+:[^@]+@" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Database URL with credentials in code — move to .env!"
fi

# Private keys
if grep -qE "BEGIN (RSA |DSA |EC )?PRIVATE KEY" "$FILE" 2>/dev/null; then
  WARNINGS="$WARNINGS\n  • Private key in code! — REMOVE and regenerate (the key may be compromised)"
fi

# ─── Output if warnings exist ─────────────────────────────────────
if [ -n "$WARNINGS" ]; then
  echo "⚠️ JARVIS SECURITY: possible secret in $(basename "$FILE"):"
  echo -e "$WARNINGS" | head -3
  echo "  Check and move to .env (+ make sure .env is in .gitignore)"
fi

exit 0
