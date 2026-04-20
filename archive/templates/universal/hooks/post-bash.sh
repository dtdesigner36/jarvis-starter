#!/bin/bash
# Post-Bash hook — tracks important commands

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$CMD" ] || [ ! -d ".jarvis" ]; then
  exit 0
fi

# Security: gitignore-check also handles Bash (git add .env, git commit)
bash {{SKILL_PATH}}/core/security-watch/gitignore-check.sh <<< "$INPUT"

# Prisma migration → remind about canvas (if present)
if echo "$CMD" | grep -q "prisma migrate"; then
  if [ -f "wiki/Canvas/PrismaSchema.canvas" ]; then
    echo "💠 JARVIS: migration done — update wiki/Canvas/PrismaSchema.canvas if models were added"
  fi
fi

# npm install with --save → check new dependency via brownfield detection
if echo "$CMD" | grep -qE "(npm install|yarn add|pnpm add) .* (--save|$)"; then
  echo "💠 JARVIS: new dependency installed. jarvis suggest if you want to check for archetype-shift."
fi

# Large pip install → same
if echo "$CMD" | grep -qE "pip install .*(telegram|discord|fastapi|django|flask|scrapy)"; then
  echo "💠 JARVIS: major framework installed. Verify archetype currency: jarvis status"
fi

# Archetype-specific Bash triggers
{{ARCHETYPE_POST_BASH_TRIGGERS}}

exit 0
