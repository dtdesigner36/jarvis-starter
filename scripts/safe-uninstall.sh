#!/bin/bash
# JARVIS Safe Uninstall — removes only JARVIS traces, preserves user hooks/config
#
# What gets removed:
#   .jarvis/                            (entirely)
#   .claude/hooks/jarvis-*.sh           (only JARVIS hooks)
#   JARVIS-appended block in legacy {post-edit,post-bash,pre-prompt}.sh
#   .claude/hooks/*.pre-jarvis*.bak     (our own backups, after restore)
#   JARVIS hook entries from .claude/settings.json (selective jq filter)
#   JARVIS section from CLAUDE.md (from the first jarvis marker to EOF)
#   .agents/skills/jarvis-starter       (npm install)
#
# What's preserved (non-destructive guarantees):
#   user-owned post-edit.sh / post-bash.sh / pre-prompt.sh — restored from
#     .pre-jarvis.bak if present, else JARVIS-appended block stripped by sentinel,
#     else file left untouched
#   user hook entries in settings.json (only entries whose command points at
#     a JARVIS hook file are removed — non-JARVIS hooks stay)
#   .claude/settings.local.json         (user permissions)
#   wiki/                                (user content even if JARVIS created it)
#   .gitignore / other user files
#
# A backup is taken into jarvis-uninstall-backup-<TS>/ before any edit.

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
# Backup legacy hook files too — they may have been merged with user content
for h in .claude/hooks/post-edit.sh .claude/hooks/post-bash.sh .claude/hooks/pre-prompt.sh; do
  [ -f "$h" ] && cp "$h" "${BACKUP_DIR}/$(basename "$h")"
done
# Backup .jarvis/ — memory.md / state.md / usage-log.md may contain
# valuable user context.
if [ -d .jarvis ]; then
  cp -R .jarvis "${BACKUP_DIR}/.jarvis"
fi
echo "→ Backups in ${BACKUP_DIR}/ (incl. .jarvis/ and legacy hook files)"

# 2. .jarvis/ — entire dir (backup already taken)
if [ -d .jarvis ]; then
  rm -rf .jarvis/
  echo "→ .jarvis/ removed"
fi

# 3. Hooks — non-destructive
# JARVIS-owned hooks (jarvis-*.sh) are removed wholesale.
# Legacy bootstrap names (post-edit/post-bash/pre-prompt.sh) are restored from
# .pre-jarvis.bak if present, otherwise the JARVIS-appended block is stripped
# by sentinel, otherwise file is left untouched (it's user-owned).

restore_or_skip() {
  local path="$1"
  local bak="${path}.pre-jarvis.bak"
  if [ ! -f "$path" ]; then
    return 0
  fi
  if [ -f "$bak" ]; then
    mv "$bak" "$path"
    echo "→ ${path}: restored from $(basename "$bak")"
    return 0
  fi
  if grep -qF '# === JARVIS-starter hooks (appended) ===' "$path"; then
    python3 - "$path" <<'PY'
import sys
path = sys.argv[1]
sentinel = "# === JARVIS-starter hooks (appended) ==="
with open(path, encoding="utf-8") as f:
    content = f.read()
idx = content.find(sentinel)
if idx == -1:
    sys.exit(0)
# Backtrack over the blank line bootstrap.sh added before the sentinel,
# so the user's pre-existing tail isn't padded with our newline.
prefix = content[:idx].rstrip("\n")
new = prefix + ("\n" if prefix else "")
with open(path, "w", encoding="utf-8") as f:
    f.write(new)
PY
    echo "→ ${path}: stripped JARVIS-appended block, kept user content"
    return 0
  fi
  # Greenfield install: no .bak, no sentinel — file was cp'd verbatim from our
  # template. Detect by the exact bootstrap dispatch idiom — a command line
  # of the form  bash "<skill-path>/core/<feature>/<script>.sh" <<< "$INPUT"
  # — which is specific enough that a user hook merely referencing those core
  # paths in a comment will NOT trigger removal.
  if grep -qE 'bash "[^"]*/core/(wiki-maintenance|security-watch|focus-tracker|task-routing|memory-recall)/[^"]*\.sh" *<<< *"\$INPUT"' "$path"; then
    rm -f "$path"
    echo "→ ${path}: greenfield JARVIS install — removed"
    return 0
  fi
  echo "→ ${path}: no JARVIS markers — left untouched"
}

if [ -d .claude/hooks ]; then
  rm -f .claude/hooks/jarvis-*.sh
  for legacy in .claude/hooks/post-edit.sh .claude/hooks/post-bash.sh .claude/hooks/pre-prompt.sh; do
    restore_or_skip "$legacy"
  done
  # Cleanup our own backups AFTER restore (otherwise we'd remove the source we need)
  rm -f .claude/hooks/*.pre-jarvis*.bak
  rmdir .claude/hooks 2>/dev/null || true
  echo "→ JARVIS hooks removed (user hooks preserved)"
fi

# 4. Strip ONLY JARVIS hook entries from settings.json
# Selective filter: drops inner hook entries whose command points at jarvis-*.sh
# or legacy {post-edit,post-bash,pre-prompt}.sh under .claude/hooks/.
# User hook entries (any other command) are preserved.
if [ -f .claude/settings.json ]; then
  if command -v jq >/dev/null 2>&1; then
    # Defensive: .hooks may be missing / null / not-an-object; event values may
    # be not-an-array; matcher-group .hooks may be not-an-array. In all those
    # weird shapes, leave that piece untouched rather than aborting.
    if jq '
      if (.hooks | type) != "object" then .
      else
        .hooks |= (
          to_entries
          | map(
              if (.value | type) != "array" then .
              else
                .value |= (
                  map(
                    if (.hooks | type) != "array" then .
                    else
                      .hooks |= map(select(
                        (.command // "") | test("jarvis-|/\\.claude/hooks/(post-edit|post-bash|pre-prompt)\\.sh") | not
                      ))
                    end
                  )
                  | map(select((.hooks | type) != "array" or (.hooks | length) > 0))
                )
              end
            )
          | map(select((.value | type) != "array" or (.value | length) > 0))
          | from_entries
        )
        | if (.hooks // {}) == {} then del(.hooks) else . end
      end
    ' .claude/settings.json > .claude/settings.json.new 2>/dev/null; then
      mv .claude/settings.json.new .claude/settings.json
      echo "→ .claude/settings.json: only JARVIS hook entries removed; user hooks/config preserved"
    else
      rm -f .claude/settings.json.new
      echo "⚠️  settings.json has an unusual shape — left untouched. Inspect manually: .claude/settings.json"
    fi
  else
    echo "⚠️  jq not installed — settings.json untouched (manually remove JARVIS hook entries)"
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
    # Marker at byte 0 → the whole file is JARVIS-owned (bootstrap created it).
    # Delete rather than truncate-to-empty; user reverts to pre-install state.
    import os
    os.remove(path)
    print("→ CLAUDE.md: JARVIS-owned — file removed")
    sys.exit(0)

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
