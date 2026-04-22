#!/bin/bash
# JARVIS wiki live-update — updates YAML last-edited + ## Last edit section in
# wiki/Systems/<X>.md when JARVIS detects an edit in a tracked module.
#
# Usage:
#   live-update.sh <system-name> <edited-file-path>
#
# Example:
#   live-update.sh Dashboard src/features/dashboard/chart.tsx
#
# Anti-spam: updates no more often than once every 10 minutes per-system.
# Idempotent + crash-safe: uses temp-file + atomic rename.
# Lock: .jarvis/wiki-write.lock (short, no fuss on stale).

set -e

SYSTEM_NAME="$1"
EDITED_FILE="$2"

if [ -z "${SYSTEM_NAME}" ] || [ -z "${EDITED_FILE}" ]; then
  exit 0
fi

# Skip if wiki-ownership is off
if [ -f .jarvis/preferences.md ] && grep -qE '^wiki-ownership:[[:space:]]*off' .jarvis/preferences.md 2>/dev/null; then
  exit 0
fi

# Resolve wiki-location
WIKI_LOCATION="wiki/Systems"
if [ -f .jarvis/state.md ]; then
  LOC=$(grep -E '^wiki-location:' .jarvis/state.md 2>/dev/null | sed 's/^wiki-location:[[:space:]]*//' | head -1)
  [ -n "${LOC}" ] && WIKI_LOCATION="${LOC%/}/Systems"
  case "${LOC}" in
    .jarvis/*|.jarvis) WIKI_LOCATION=".jarvis/systems" ;;
  esac
fi

DEST="${WIKI_LOCATION}/${SYSTEM_NAME}.md"
[ ! -f "${DEST}" ] && exit 0

# Skip if the file is not JARVIS-managed (per-file opt-out)
if grep -qE '^jarvis-managed:[[:space:]]*off' "${DEST}" 2>/dev/null; then
  exit 0
fi

# Anti-spam: once per 10 min per system
STAMP_FILE=".jarvis/wiki-live-${SYSTEM_NAME}.stamp"
NOW=$(date +%s)
LAST=$(stat -f "%m" "${STAMP_FILE}" 2>/dev/null || stat -c "%Y" "${STAMP_FILE}" 2>/dev/null || echo 0)
if [ "$((NOW - LAST))" -lt 600 ]; then
  exit 0
fi

# Lock (tiny — single sed operation)
LOCK=".jarvis/wiki-write.lock"
if [ -f "${LOCK}" ]; then
  AGE=$(($(date +%s) - $(stat -f "%m" "${LOCK}" 2>/dev/null || stat -c "%Y" "${LOCK}" 2>/dev/null || echo 0)))
  [ "${AGE}" -lt 5 ] && exit 0
fi
touch "${LOCK}"
trap 'rm -f "${LOCK}"' EXIT

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update the file via python (atomic + safe)
python3 - "${DEST}" "${TS}" "${EDITED_FILE}" <<'PY'
import sys, re, os

path, ts, edited_file = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as f:
    content = f.read()

# 1. Update YAML last-edited
content = re.sub(
    r"^last-edited:[^\n]*",
    f"last-edited: {ts}",
    content,
    count=1,
    flags=re.MULTILINE,
)

# 2. Update "## Last edit" line after header
content = re.sub(
    r"(## Last edit\n)[^\n]*",
    rf"\g<1>{ts} (auto-updated)",
    content,
    count=1,
)

# 3. Add edited_file to ## Files if missing
rel = edited_file.lstrip("./")
files_marker = f"- `{rel}`"
if files_marker not in content:
    m = re.search(r"(## Files\n)(.*?)(\n## |\Z)", content, re.DOTALL)
    if m:
        header, body, next_hdr = m.group(1), m.group(2), m.group(3)
        if "<!-- empty" in body or "<!-- TODO" in body:
            new_body = f"{files_marker}\n"
        else:
            new_body = body.rstrip() + f"\n{files_marker}\n"
        content = content[:m.start()] + header + new_body + next_hdr + content[m.end():]

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PY

touch "${STAMP_FILE}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/../usage-log.sh" wiki-maintenance LIVE-UPDATE "system=${SYSTEM_NAME}" 2>/dev/null || true

exit 0
