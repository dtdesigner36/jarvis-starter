#!/bin/bash
# JARVIS Safe Uninstall — removes only JARVIS traces, backs up CLAUDE.md/settings.json
#
# What gets removed:
#   .jarvis/                            (entirely)
#   .claude/hooks/jarvis-*.sh           (only JARVIS hooks)
#   .claude/hooks/{post-edit,post-bash,pre-prompt}.sh    (legacy bootstrap names)
#   .claude/hooks/*.pre-jarvis*.bak     (our own hook backups)
#   hooks block from .claude/settings.json (via jq, structured delete)
#   JARVIS section from CLAUDE.md (from the first jarvis marker to EOF)
#   .agents/skills/jarvis-starter       (npm install)
#
# What's preserved:
#   .claude/settings.local.json         (user permissions)
#   wiki/                                (user content even if JARVIS created it)
#   .gitignore / other user files
#
# A backup is taken into .jarvis-uninstall-backup-<TS>/ before any edit.

set -euo pipefail

echo "=== JARVIS Safe Uninstall ==="

# 0. Confirm
if [ "${1:-}" != "--yes" ]; then
  read -p "Remove JARVIS from the current folder? (y/N) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 0; }
fi

# 1. Backup critical files BEFORE any edit
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="jarvis-uninstall-backup-${TS}"
mkdir -p "${BACKUP_DIR}"
for f in CLAUDE.md .claude/settings.json; do
  [ -f "$f" ] && cp "$f" "${BACKUP_DIR}/$(basename "$f")"
done
# Backup .jarvis/ — memory.md / state.md / usage-log.md may contain
# valuable user context (retest v0.2.1 feedback).
if [ -d .jarvis ]; then
  cp -R .jarvis "${BACKUP_DIR}/.jarvis"
fi
echo "→ Backups in ${BACKUP_DIR}/ (incl. .jarvis/)"

# 2. .jarvis/ — entire dir (backup already taken)
if [ -d .jarvis ]; then
  rm -rf .jarvis/
  echo "→ .jarvis/ removed"
fi

# 3. JARVIS hooks only
if [ -d .claude/hooks ]; then
  rm -f .claude/hooks/jarvis-*.sh
  rm -f .claude/hooks/post-edit.sh .claude/hooks/post-bash.sh .claude/hooks/pre-prompt.sh
  rm -f .claude/hooks/*.pre-jarvis*.bak
  rmdir .claude/hooks 2>/dev/null || true
  echo "→ JARVIS hooks removed"
fi

# 4. Strip hooks from settings.json (jq — atomic, preserves user config)
if [ -f .claude/settings.json ]; then
  if command -v jq >/dev/null 2>&1; then
    jq 'del(.hooks)' .claude/settings.json > .claude/settings.json.new
    mv .claude/settings.json.new .claude/settings.json
    echo "→ .claude/settings.json: hooks removed, user config (theme/permissions/env) preserved"
  else
    echo "⚠️  jq not installed — settings.json untouched (manually remove the \"hooks\" block)"
  fi
fi

# 5. Cleanup CLAUDE.md from JARVIS section — SAFE method
# Finds the FIRST jarvis marker and deletes from there to EOF.
# Supports both bootstrap and adopt markers; archetype-overlay too if it
# came after the main marker.
if [ -f CLAUDE.md ]; then
  python3 - CLAUDE.md <<'PY'
import sys, re
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

markers = [
    "<!-- jarvis-starter-bootstrap -->",
    "<!-- jarvis-starter-adopt:",
    "<!-- jarvis-archetype-overlay:",
]
positions = []
for m in markers:
    idx = content.find(m)
    if idx != -1:
        positions.append(idx)

if not positions:
    print("→ CLAUDE.md: no JARVIS markers found, leaving as is")
    sys.exit(0)

cut_at = min(positions)

if cut_at == 0:
    new_content = ""
else:
    new_content = content[:cut_at].rstrip() + "\n"

# Guard: if the cleanup made the file empty while the source wasn't — DON'T save
if not new_content.strip() and content.strip():
    print("⚠️  Cleanup produced an empty file while the source wasn't empty. Leaving CLAUDE.md as is.", file=sys.stderr)
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)
print("→ CLAUDE.md: JARVIS section removed, user content preserved")
PY
fi

# 6. npm install
if [ -d .agents/skills/jarvis-starter ]; then
  rm -rf .agents/skills/jarvis-starter
  echo "→ .agents/skills/jarvis-starter removed"
fi

echo ""
echo "✅ Uninstall complete. Backup at ${BACKUP_DIR}/ contains:"
find "${BACKUP_DIR}" -type f 2>/dev/null | sed "s|^${BACKUP_DIR}/|  - |" | head -20
EXTRA=$(find "${BACKUP_DIR}" -type f 2>/dev/null | wc -l | tr -d ' ')
[ "${EXTRA}" -gt 20 ] && echo "  ... and $((EXTRA - 20)) more (full: find ${BACKUP_DIR} -type f)"
echo ""
echo "To reinstall:"
echo "  npx skills add dtdesigner36/jarvis-starter --yes"
