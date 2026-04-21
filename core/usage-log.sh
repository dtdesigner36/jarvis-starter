#!/bin/bash
# JARVIS usage-log helper — invoked from core hooks when they fire
#
# Usage (from core scripts):
#   bash "{{SKILL_PATH}}/core/usage-log.sh" <hook-name> <action> [<detail>]
#
# Appends one line to .jarvis/usage-log.md:
#   2026-04-21T14:57:12Z adr-detector FIRED prompt-hash=a1b2c3
#
# self-audit reads this log to surface "what actually fires vs what stays silent".

# Must have .jarvis/ — otherwise not a JARVIS project, silent exit
[ ! -d .jarvis ] && exit 0

HOOK="${1:-unknown}"
ACTION="${2:-TRIGGERED}"
DETAIL="${3:-}"

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
LOG=".jarvis/usage-log.md"

# Create with header on first call (idempotent)
if [ ! -f "${LOG}" ]; then
  cat > "${LOG}" <<'EOF'
# JARVIS Usage Log
# Format: <ISO-timestamp> <hook-name> <action> [<detail>]
# Read by: jarvis self-audit
EOF
fi

# Append line
if [ -n "${DETAIL}" ]; then
  echo "${TS} ${HOOK} ${ACTION} ${DETAIL}" >> "${LOG}"
else
  echo "${TS} ${HOOK} ${ACTION}" >> "${LOG}"
fi

# Rotation: if >2000 lines, keep last 1500
LINES=$(wc -l < "${LOG}" | tr -d ' ')
if [ "${LINES}" -gt 2000 ]; then
  tail -1500 "${LOG}" > "${LOG}.tmp" && mv "${LOG}.tmp" "${LOG}"
fi

exit 0
