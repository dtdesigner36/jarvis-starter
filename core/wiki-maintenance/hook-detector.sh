#!/bin/bash
# JARVIS wiki-maintenance hook
# PostToolUse hook — detects high-signal events and injects wiki reminders

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE" ]; then
  exit 0
fi

# Skip if .jarvis/ missing — bootstrap not completed
if [ ! -d ".jarvis" ]; then
  exit 0
fi

# ─── New module/feature created ───────────────────────────────────
# Detect via Write tool on a file in a new folder src/modules/<name>/ or server/src/modules/<name>/
if [ "$TOOL" = "Write" ]; then
  # Extract potential system name
  SYSTEM=""
  if echo "$FILE" | grep -qE "(server/)?src/modules/([^/]+)/"; then
    SYSTEM=$(echo "$FILE" | sed -E 's|.*src/modules/([^/]+)/.*|\1|')
  elif echo "$FILE" | grep -qE "(client/)?src/features/([^/]+)/"; then
    SYSTEM=$(echo "$FILE" | sed -E 's|.*src/features/([^/]+)/.*|\1|')
  fi

  if [ -n "$SYSTEM" ] && [ ! -f "wiki/Systems/${SYSTEM}.md" ]; then
    # Verify this is really a new module (count files in folder)
    MODULE_DIR=$(dirname "$FILE")
    FILES_IN_MODULE=$(find "$MODULE_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
    if [ "$FILES_IN_MODULE" -le 3 ]; then
      echo "💠 JARVIS: new system \`${SYSTEM}\`. Create wiki/Systems/${SYSTEM}.md? (jarvis new-system ${SYSTEM})"
    fi
  fi
fi

# ─── schema.prisma → update PrismaSchema canvas ───────────────────
if echo "$FILE" | grep -q "schema\.prisma"; then
  if [ -f "wiki/Canvas/PrismaSchema.canvas" ]; then
    echo "💠 JARVIS: schema.prisma changed → update wiki/Canvas/PrismaSchema.canvas if models were added/removed"
  fi
fi

# ─── Architectural decision (middleware, service, pattern) ────────
if echo "$FILE" | grep -qE "(middleware|interceptor|guard|decorator|provider)\.(ts|js|py)$"; then
  echo "💠 JARVIS: looks like an architectural pattern — record in wiki/Architecture/?"
fi

# ─── Stale wiki + active code ─────────────────────────────────────
# If last wiki edit was > 14 days ago while code is actively edited
if [ -d "wiki" ]; then
  LATEST_WIKI=$(find wiki -type f -name "*.md" -exec stat -f "%m" {} + 2>/dev/null | sort -nr | head -1)
  NOW=$(date +%s)
  if [ -n "$LATEST_WIKI" ]; then
    DAYS_OLD=$(( (NOW - LATEST_WIKI) / 86400 ))
    if [ "$DAYS_OLD" -gt 14 ]; then
      # Don't spam — check "last-warned" flag in .jarvis/
      LAST_WARN_FILE=".jarvis/last-wiki-warning"
      if [ ! -f "$LAST_WARN_FILE" ] || [ $(( (NOW - $(stat -f "%m" "$LAST_WARN_FILE" 2>/dev/null || echo 0)) / 86400 )) -gt 7 ]; then
        echo "💠 JARVIS: wiki hasn't been updated for $DAYS_OLD days while code is active. jarvis docs for a check."
        touch "$LAST_WARN_FILE"
      fi
    fi
  fi
fi

exit 0
