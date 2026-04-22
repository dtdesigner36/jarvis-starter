#!/bin/bash
# JARVIS wiki scaffolding — creates a wiki/Systems/<X>.md skeleton when a new module is detected.
# Called from hook-detector.sh on a Write event in a fresh module dir.
#
# Usage:
#   scaffold.sh <system-name> <source-module-dir>
#
# Example:
#   scaffold.sh Dashboard src/features/dashboard
#
# Idempotent: if the file already exists — does NOT overwrite (user may have edited it).

set -e

SYSTEM_NAME="$1"
SOURCE_MODULE="$2"

if [ -z "${SYSTEM_NAME}" ] || [ -z "${SOURCE_MODULE}" ]; then
  echo "scaffold.sh: usage: scaffold.sh <system-name> <source-module-dir>" >&2
  exit 1
fi

# Resolve wiki-location via state.md (namespace matrix: wiki/ | .jarvis/systems/ | docs/)
WIKI_LOCATION="wiki/Systems"
if [ -f .jarvis/state.md ]; then
  LOC=$(grep -E '^wiki-location:' .jarvis/state.md 2>/dev/null | sed 's/^wiki-location:[[:space:]]*//' | head -1)
  [ -n "${LOC}" ] && WIKI_LOCATION="${LOC%/}/Systems"
  case "${LOC}" in
    .jarvis/*|.jarvis) WIKI_LOCATION=".jarvis/systems" ;;
  esac
fi

# Skip if wiki-ownership is off
if [ -f .jarvis/preferences.md ] && grep -qE '^wiki-ownership:[[:space:]]*off' .jarvis/preferences.md 2>/dev/null; then
  exit 0
fi

# Skip if path matches wiki-ignore
if [ -f .jarvis/wiki-ignore ]; then
  while IFS= read -r pattern; do
    [ -z "${pattern}" ] && continue
    [[ "${pattern}" == \#* ]] && continue
    case "${SOURCE_MODULE}" in
      ${pattern}) exit 0 ;;
    esac
  done < .jarvis/wiki-ignore
fi

mkdir -p "${WIKI_LOCATION}"
DEST="${WIKI_LOCATION}/${SYSTEM_NAME}.md"

# Idempotent: if the file already exists — do nothing
if [ -f "${DEST}" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TEMPLATE="${SKILL_PATH}/archive/templates/universal/wiki-system-scaffold.md.template"

if [ ! -f "${TEMPLATE}" ]; then
  exit 0
fi

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CREATED_DATE=$(date +%Y-%m-%d)

# Build file list for the module (max 15)
FILES_LIST=""
if [ -d "${SOURCE_MODULE}" ]; then
  while IFS= read -r f; do
    REL="${f#./}"
    FILES_LIST="${FILES_LIST}- \`${REL}\`"$'\n'
  done < <(find "${SOURCE_MODULE}" -maxdepth 3 -type f \
             \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
                -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.md" \) \
             2>/dev/null | head -15 | sort)
fi
[ -z "${FILES_LIST}" ] && FILES_LIST="<!-- empty — JARVIS will fill on subsequent edits -->"

DECISIONS_SECTION="<!-- JARVIS appends here on \`jarvis decide\` — one line per decision -->"

# Render template with substitutions via python (portable + safe)
python3 - "${TEMPLATE}" "${DEST}" "${SYSTEM_NAME}" "${SOURCE_MODULE}" "${CREATED_DATE}" "${TS}" "${FILES_LIST}" "${DECISIONS_SECTION}" <<'PY'
import sys
tmpl, dest, system, module, created, ts, files, decisions = sys.argv[1:]
with open(tmpl, encoding="utf-8") as f:
    content = f.read()
content = content.replace("{{SYSTEM_NAME}}", system)
content = content.replace("{{SOURCE_MODULE}}", module)
content = content.replace("{{CREATED_DATE}}", created)
content = content.replace("{{LAST_EDITED}}", ts)
content = content.replace("{{FILES_LIST}}", files.rstrip())
content = content.replace("{{DECISIONS_SECTION}}", decisions)
with open(dest, "w", encoding="utf-8") as f:
    f.write(content)
PY

# Update state.md: append owned-file if present
STATE=".jarvis/state.md"
if [ -f "${STATE}" ]; then
  if ! grep -qE "^owned-files:" "${STATE}"; then
    echo "owned-files:" >> "${STATE}"
  fi
  if ! grep -qF "  - ${DEST}" "${STATE}"; then
    python3 - "${STATE}" "${DEST}" <<'PY'
import sys
path, new_file = sys.argv[1], sys.argv[2]
with open(path) as f:
    lines = f.readlines()
out = []
added = False
for l in lines:
    out.append(l)
    if not added and l.startswith("owned-files:"):
        out.append(f"  - {new_file}\n")
        added = True
with open(path, "w") as f:
    f.writelines(out)
PY
  fi
fi

echo "💠 JARVIS: scaffolded wiki stub for new system \`${SYSTEM_NAME}\` → ${DEST}"
echo "   (Fill in TL;DR and Decisions at your leisure; Files + Last edit are maintained by JARVIS)"
