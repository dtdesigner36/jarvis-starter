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

# Portable file mtime — BSD (macOS) first, GNU (Linux) fallback
_mtime() { stat -f "%m" "$1" 2>/dev/null || stat -c "%Y" "$1" 2>/dev/null || echo 0; }

FIRED=0

# Counter "edits without wiki touched" — for periodic suggestion of `jarvis docs`
COUNTER_FILE=".jarvis/wiki-stale-counter"
CURRENT=$(cat "${COUNTER_FILE}" 2>/dev/null || echo 0)
if echo "$FILE" | grep -q "^wiki/"; then
  echo 0 > "${COUNTER_FILE}"
else
  CURRENT=$((CURRENT + 1))
  echo "${CURRENT}" > "${COUNTER_FILE}"
fi

# ─── System detection by file path (module/feature) ──────────────
SYSTEM=""
MODULE_DIR=""
if echo "$FILE" | grep -qE "(server/)?src/modules/([^/]+)/"; then
  SYSTEM=$(echo "$FILE" | sed -E 's|.*src/modules/([^/]+)/.*|\1|')
  MODULE_DIR=$(echo "$FILE" | sed -E 's|(.*src/modules/[^/]+)/.*|\1|')
elif echo "$FILE" | grep -qE "(client/)?src/features/([^/]+)/"; then
  SYSTEM=$(echo "$FILE" | sed -E 's|.*src/features/([^/]+)/.*|\1|')
  MODULE_DIR=$(echo "$FILE" | sed -E 's|(.*src/features/[^/]+)/.*|\1|')
fi

# ─── Resolve wiki-location for checks ─────────────────────────────
SYSTEMS_DIR="wiki/Systems"
if [ -f .jarvis/state.md ]; then
  LOC=$(grep -E '^wiki-location:' .jarvis/state.md 2>/dev/null | sed 's/^wiki-location:[[:space:]]*//' | head -1)
  [ -n "${LOC}" ] && SYSTEMS_DIR="${LOC%/}/Systems"
  case "${LOC}" in
    .jarvis/*|.jarvis) SYSTEMS_DIR=".jarvis/systems" ;;
  esac
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── New module (Write) → ACTIVE OWNERSHIP: scaffold.sh ────────────
if [ "$TOOL" = "Write" ] && [ -n "$SYSTEM" ] && [ ! -f "${SYSTEMS_DIR}/${SYSTEM}.md" ]; then
  FILES_IN_MODULE=$(find "$(dirname "$FILE")" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$FILES_IN_MODULE" -le 3 ]; then
    bash "${SCRIPT_DIR}/scaffold.sh" "${SYSTEM}" "${MODULE_DIR}" 2>&1 || true
    FIRED=1
  fi
fi

# ─── Edit in tracked module → live-update ─────────────────────────
if [ "$TOOL" = "Edit" ] && [ -n "$SYSTEM" ] && [ -f "${SYSTEMS_DIR}/${SYSTEM}.md" ]; then
  if ! grep -qE '^jarvis-managed:[[:space:]]*off' "${SYSTEMS_DIR}/${SYSTEM}.md" 2>/dev/null; then
    bash "${SCRIPT_DIR}/live-update.sh" "${SYSTEM}" "${FILE}" 2>/dev/null || true
  fi
fi

# ─── schema.prisma → update PrismaSchema canvas ───────────────────
if echo "$FILE" | grep -q "schema\.prisma"; then
  if [ -f "wiki/Canvas/PrismaSchema.canvas" ]; then
    echo "💠 JARVIS: schema.prisma changed → update wiki/Canvas/PrismaSchema.canvas if models were added/removed"
    FIRED=1
  fi
fi

# ─── Architectural decision (middleware, service, pattern) ────────
if echo "$FILE" | grep -qE "(middleware|interceptor|guard|decorator|provider)\.(ts|js|py)$"; then
  echo "💠 JARVIS: looks like an architectural pattern — record in wiki/Architecture/?"
  FIRED=1
fi

# ─── Stale wiki + active code ─────────────────────────────────────
# If last wiki edit was > 14 days ago while code is actively edited
if [ -d "wiki" ]; then
  LATEST_WIKI=$(find wiki -type f -name "*.md" -print0 2>/dev/null | while IFS= read -r -d '' f; do _mtime "$f"; done | sort -nr | head -1)
  NOW=$(date +%s)
  if [ -n "$LATEST_WIKI" ]; then
    DAYS_OLD=$(( (NOW - LATEST_WIKI) / 86400 ))
    if [ "$DAYS_OLD" -gt 14 ]; then
      # Don't spam — check "last-warned" flag in .jarvis/
      LAST_WARN_FILE=".jarvis/last-wiki-warning"
      if [ ! -f "$LAST_WARN_FILE" ] || [ $(( (NOW - $(_mtime "$LAST_WARN_FILE")) / 86400 )) -gt 7 ]; then
        echo "💠 JARVIS: wiki hasn't been updated for $DAYS_OLD days while code is active. jarvis docs for a check."
        touch "$LAST_WARN_FILE"
        FIRED=1
      fi
    fi
  fi
fi

# Periodic suggestion: after 30 code edits without a wiki touch — hint at `jarvis docs`
if [ "${CURRENT}" -ge 30 ] && [ "${FIRED}" = "0" ]; then
  LAST_DOCS_HINT=".jarvis/last-docs-hint"
  NOW_TS=$(date +%s)
  LAST_TS=$(_mtime "${LAST_DOCS_HINT}")
  # No more often than once every 3 days
  if [ $(( (NOW_TS - LAST_TS) / 86400 )) -gt 3 ]; then
    echo "💡 JARVIS: ${CURRENT} code edits without a wiki update. Try \`jarvis docs\` to check wiki freshness."
    touch "${LAST_DOCS_HINT}"
    echo 0 > "${COUNTER_FILE}"
    FIRED=1
  fi
fi

# Periodic suggestion: after 100 edits — hint at `jarvis suggest` / `audit`
SUGGEST_COUNTER_FILE=".jarvis/suggest-counter"
SUGGEST_CURRENT=$(cat "${SUGGEST_COUNTER_FILE}" 2>/dev/null || echo 0)
SUGGEST_CURRENT=$((SUGGEST_CURRENT + 1))
echo "${SUGGEST_CURRENT}" > "${SUGGEST_COUNTER_FILE}"
if [ "${SUGGEST_CURRENT}" -ge 100 ] && [ "${FIRED}" = "0" ]; then
  LAST_SUGGEST_HINT=".jarvis/last-suggest-hint"
  NOW_TS=$(date +%s)
  LAST_TS=$(_mtime "${LAST_SUGGEST_HINT}")
  # No more often than once every 7 days
  if [ $(( (NOW_TS - LAST_TS) / 86400 )) -gt 7 ]; then
    echo "💡 JARVIS: ${SUGGEST_CURRENT} edits without an audit. Try \`jarvis suggest\` or \`jarvis audit\` for a quality review."
    touch "${LAST_SUGGEST_HINT}"
    echo 0 > "${SUGGEST_COUNTER_FILE}"
    FIRED=1
  fi
fi

# usage-log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${FIRED}" = "1" ]; then
  bash "${SCRIPT_DIR}/../usage-log.sh" wiki-maintenance FIRED "file=${FILE}" 2>/dev/null || true
else
  bash "${SCRIPT_DIR}/../usage-log.sh" wiki-maintenance CHECKED "file=${FILE}" 2>/dev/null || true
fi

exit 0
