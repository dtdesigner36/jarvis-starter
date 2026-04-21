#!/bin/bash
# JARVIS security-watch: gitignore checker
# PostToolUse on Edit/Write — watches .env and sensitive files in git

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ ! -d ".jarvis" ]; then
  exit 0
fi

if [ -f ".jarvis/plugins.md" ] && grep -q "security-watch: off" ".jarvis/plugins.md"; then
  exit 0
fi

FIRED=0

# ─── .env created/edited → check .gitignore ───────────────────────
if [ -n "$FILE" ] && echo "$FILE" | grep -qE "\.env(\.[a-z]+)?$" && ! echo "$FILE" | grep -qE "\.env\.example"; then
  # Check .gitignore existence and .env pattern
  if [ ! -f ".gitignore" ]; then
    echo "⚠️ JARVIS SECURITY: .env created but .gitignore is missing — create it immediately!"
    echo "  echo '.env' >> .gitignore && echo '.env.local' >> .gitignore"
    FIRED=1
  elif ! grep -qE "^\.env$|^\.env\*|^\*\.env|^\.env\.local" ".gitignore" 2>/dev/null; then
    echo "⚠️ JARVIS SECURITY: .env is not in .gitignore! Add:"
    echo "  echo '.env' >> .gitignore"
    echo "  echo '.env.local' >> .gitignore"
    FIRED=1
  fi

  # Suggest creating .env.example if missing
  if [ ! -f ".env.example" ]; then
    echo "💡 JARVIS: create .env.example — to document required variables"
    FIRED=1
  fi
fi

# ─── git add .env → error! ────────────────────────────────────────
if [ "$TOOL" = "Bash" ] && echo "$CMD" | grep -qE "git add .*\.env(\s|$)"; then
  echo "🚨 JARVIS SECURITY: YOU'RE ADDING .env TO GIT! Undo:"
  echo "  git reset HEAD .env"
  echo "  echo '.env' >> .gitignore"
  FIRED=1
fi

# ─── git commit → verify staging has no .env ──────────────────────
if [ "$TOOL" = "Bash" ] && echo "$CMD" | grep -qE "git commit"; then
  if git diff --cached --name-only 2>/dev/null | grep -qE "^\.env$|\.env\."; then
    STAGED=$(git diff --cached --name-only | grep -E "\.env" | head -3)
    echo "🚨 JARVIS SECURITY: .env files in staging! Remove before commit:"
    echo "$STAGED" | sed 's/^/  • /'
    echo "  git reset HEAD <file>"
    FIRED=1
  fi
fi

# ─── Edit on auth/RLS/middleware/migration files → suggest jarvis security ─
if [ -n "$FILE" ] && echo "$FILE" | grep -qE "(auth|rls|middleware|policies|policy|migrations?/)" && ! echo "$FILE" | grep -qE "(test|spec|node_modules|\.next/)"; then
  LAST_SEC_HINT=".jarvis/last-security-hint"
  NOW_TS=$(date +%s)
  LAST_TS=$(stat -f "%m" "${LAST_SEC_HINT}" 2>/dev/null || echo 0)
  # No more often than once every 7 days
  if [ $(( (NOW_TS - LAST_TS) / 86400 )) -gt 7 ]; then
    echo "💡 JARVIS: editing an auth/security-sensitive file. Try \`jarvis security\` for an audit (RLS, policies, secret leaks)."
    touch "${LAST_SEC_HINT}"
    FIRED=1
  fi
fi

# usage-log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${FIRED}" = "1" ]; then
  bash "${SCRIPT_DIR}/../usage-log.sh" security-watch FIRED "check=gitignore" 2>/dev/null || true
fi

exit 0
