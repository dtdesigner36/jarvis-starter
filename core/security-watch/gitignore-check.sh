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

# ─── .env created/edited → check .gitignore ───────────────────────
if [ -n "$FILE" ] && echo "$FILE" | grep -qE "\.env(\.[a-z]+)?$" && ! echo "$FILE" | grep -qE "\.env\.example"; then
  # Check .gitignore existence and .env pattern
  if [ ! -f ".gitignore" ]; then
    echo "⚠️ JARVIS SECURITY: .env created but .gitignore is missing — create it immediately!"
    echo "  echo '.env' >> .gitignore && echo '.env.local' >> .gitignore"
  elif ! grep -qE "^\.env$|^\.env\*|^\*\.env|^\.env\.local" ".gitignore" 2>/dev/null; then
    echo "⚠️ JARVIS SECURITY: .env is not in .gitignore! Add:"
    echo "  echo '.env' >> .gitignore"
    echo "  echo '.env.local' >> .gitignore"
  fi

  # Suggest creating .env.example if missing
  if [ ! -f ".env.example" ]; then
    echo "💡 JARVIS: create .env.example — to document required variables"
  fi
fi

# ─── git add .env → error! ────────────────────────────────────────
if [ "$TOOL" = "Bash" ] && echo "$CMD" | grep -qE "git add .*\.env(\s|$)"; then
  echo "🚨 JARVIS SECURITY: YOU'RE ADDING .env TO GIT! Undo:"
  echo "  git reset HEAD .env"
  echo "  echo '.env' >> .gitignore"
fi

# ─── git commit → verify staging has no .env ──────────────────────
if [ "$TOOL" = "Bash" ] && echo "$CMD" | grep -qE "git commit"; then
  if git diff --cached --name-only 2>/dev/null | grep -qE "^\.env$|\.env\."; then
    STAGED=$(git diff --cached --name-only | grep -E "\.env" | head -3)
    echo "🚨 JARVIS SECURITY: .env files in staging! Remove before commit:"
    echo "$STAGED" | sed 's/^/  • /'
    echo "  git reset HEAD <file>"
  fi
fi

exit 0
