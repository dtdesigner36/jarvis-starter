#!/bin/bash
# JARVIS focus-tracker hook
# PostToolUse — passively updates .jarvis/focus.md (no tokens, shell only)
# Tracks recently touched files/modules for jarvis status and memory-recall

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# Only for Edit/Write
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
  exit 0
fi

if [ -z "$FILE" ] || [ ! -d ".jarvis" ]; then
  exit 0
fi

# Ignore node_modules, dist, .next, build
if echo "$FILE" | grep -qE "(node_modules|\.next|dist|build|\.cache)/"; then
  exit 0
fi

# Extract module/feature name (src/modules/X/* → X, src/features/X/* → X)
AREA=""
if echo "$FILE" | grep -qE "(server/)?src/modules/([^/]+)/"; then
  AREA="module:$(echo "$FILE" | sed -E 's|.*src/modules/([^/]+)/.*|\1|')"
elif echo "$FILE" | grep -qE "(client/)?src/features/([^/]+)/"; then
  AREA="feature:$(echo "$FILE" | sed -E 's|.*src/features/([^/]+)/.*|\1|')"
elif echo "$FILE" | grep -qE "wiki/"; then
  AREA="wiki"
elif echo "$FILE" | grep -qE "prisma/"; then
  AREA="prisma"
else
  AREA="other"
fi

NOW=$(date +%s)
FOCUS_FILE=".jarvis/focus.md"

# Append entry + rotate (keep last 20)
TMP=$(mktemp)
{
  echo "# Focus Log"
  echo "<!-- Auto-updated by focus-updater.sh. Last 20 changes. -->"
  echo ""
  echo "| Timestamp | Area | File |"
  echo "|-----------|------|------|"
  echo "| $NOW | $AREA | $FILE |"

  # Keep previous entries (skip header)
  if [ -f "$FOCUS_FILE" ]; then
    grep -E "^\| [0-9]+ " "$FOCUS_FILE" 2>/dev/null | head -19
  fi
} > "$TMP"

mv "$TMP" "$FOCUS_FILE"

# usage-log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/../usage-log.sh" focus-tracker TRACKED "area=${AREA}" 2>/dev/null || true

exit 0
