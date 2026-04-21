#!/bin/bash
# JARVIS stack-matcher — reads project archetype + stack from .jarvis/state.md,
# walks known-registry.md, ranks entries by stack-tag overlap,
# and prints the top-N relevant skills with rationale.
#
# Usage:
#   bash stack-matcher.sh [--top N] [--archetype ARCH] [--stack "tag1,tag2"]
#
# Without flags — reads from .jarvis/state.md.
# Skill path is resolved relative to this script's location.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REGISTRY="${SKILL_PATH}/on-demand/skill-discovery/known-registry.md"

TOP=5
ARCHETYPE=""
STACK=""

while [ $# -gt 0 ]; do
  case "$1" in
    --top) TOP="$2"; shift 2 ;;
    --archetype) ARCHETYPE="$2"; shift 2 ;;
    --stack) STACK="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--top N] [--archetype ARCH] [--stack tag1,tag2,...]"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# ─── Auto-detect from .jarvis/state.md if not provided ────────────
if [ -z "${ARCHETYPE}" ] && [ -f .jarvis/state.md ]; then
  ARCHETYPE=$(grep -E '^archetype-detected:' .jarvis/state.md 2>/dev/null | sed 's/^archetype-detected:[[:space:]]*//' | head -1 | grep -oE '^[a-z-]+' | head -1)
  if [ -z "${ARCHETYPE}" ]; then
    ARCHETYPE=$(grep -E '^archetype-applied:' .jarvis/state.md 2>/dev/null | sed 's/^archetype-applied:[[:space:]]*//' | head -1 | grep -oE '^[a-z-]+' | head -1)
  fi
fi

if [ -z "${STACK}" ] && [ -f .jarvis/state.md ]; then
  STACK_LINE=$(grep -iE '^stack:' .jarvis/state.md 2>/dev/null | sed 's/^stack:[[:space:]]*//' | head -1)
  STACK=$(echo "${STACK_LINE}" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]+,' ',' | sed 's/^,//;s/,$//')
fi

if [ -z "${ARCHETYPE}" ] && [ -z "${STACK}" ]; then
  echo "❌ Couldn't find archetype/stack in .jarvis/state.md and none passed as flags."
  echo "   Usage: $0 --archetype web-app --stack \"react,nextjs,tailwind\""
  exit 1
fi

if [ ! -f "${REGISTRY}" ]; then
  echo "❌ Registry not found: ${REGISTRY}" >&2
  exit 1
fi

# ─── Parse registry: single Python instead of awk acrobatics ──────
RESULTS=$(python3 - "${REGISTRY}" "${ARCHETYPE}" "${STACK}" "${TOP}" <<'PY'
import re, sys

registry_path, archetype, stack_str, top = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

stack_tags = set([t.strip() for t in stack_str.split(",") if t.strip()])

entries = []
with open(registry_path, encoding="utf-8") as f:
    for line in f:
        if not line.startswith("|"):
            continue
        if "---" in line:
            continue
        if "Package" in line and "Description" in line:
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 4:
            continue
        package, desc, archs, tags = cells
        if package == "Package":
            continue
        archs_list = set([a.strip().lower() for a in archs.split(",")])
        tags_list = set()
        if tags and tags != "-":
            tags_list = set([t.strip().lower() for t in tags.split(",") if t.strip()])
        entries.append({
            "package": package,
            "desc": desc,
            "archs": archs_list,
            "tags": tags_list,
        })

def score(entry):
    s = 0
    arch_match = entry["archs"] == {"*"} or archetype.lower() in entry["archs"]
    if not arch_match:
        return 0
    s += 2
    if not stack_tags:
        return s
    overlap = entry["tags"] & stack_tags
    s += len(overlap)
    return s

scored = [(score(e), e) for e in entries]
scored = [(s, e) for s, e in scored if s > 0]
scored.sort(key=lambda x: (-x[0], x[1]["package"]))

if not scored:
    print("(no matches in registry for this archetype)")
    sys.exit(0)

stars_for = lambda s: "★" * min(5, s)
for s, e in scored[:top]:
    overlap = sorted(e["tags"] & stack_tags) if stack_tags else []
    rationale_bits = [f"archetype={archetype}"]
    if overlap:
        rationale_bits.append(f"stack-overlap=[{','.join(overlap)}]")
    rationale = "  ".join(rationale_bits)
    print(f"  {stars_for(s):5} {e['package']:48} {e['desc'][:60]}")
    print(f"        match: {rationale}")
PY
)

echo "💠 Relevant skills for archetype=${ARCHETYPE}${STACK:+, stack=[${STACK}]}:"
echo ""
echo "${RESULTS}"
echo ""
echo "Install via \`jarvis find\` or directly: \`npx skills add <package>\`"
