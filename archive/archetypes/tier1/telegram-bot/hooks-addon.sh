#!/bin/bash
# Telegram bot specific triggers for post-edit/post-bash hooks

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE" ]; then
  exit 0
fi

# New handler
if echo "$FILE" | grep -qE "handlers/[^/]+\.(py|ts|js)$"; then
  HANDLER=$(basename "$FILE" | sed 's/\.[^.]*$//')
  if [ ! -f "wiki/Commands/${HANDLER}.md" ]; then
    echo "💠 JARVIS: new handler \`${HANDLER}\` → create wiki/Commands/${HANDLER}.md?"
  fi
fi

# Warning on bot token in code
if echo "$FILE" | grep -qE "\.(py|ts|js)$"; then
  if grep -qE "BOT_TOKEN\s*=\s*['\"]\d+:" "$FILE" 2>/dev/null; then
    echo "⚠️ JARVIS: looks like a bot token is hardcoded — move to .env!"
  fi
fi

exit 0
