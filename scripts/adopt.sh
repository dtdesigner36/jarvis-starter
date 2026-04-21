#!/bin/bash
# JARVIS Adopt — soft brownfield installer (atomic, idempotent, cwd-pinned)
#
# Differences from bootstrap.sh:
# - Respects existing CLAUDE.md / docs / hooks (.jarvis/ namespace + separate jarvis-*.sh files)
# - Gap analysis: installs only features without a user analogue AND with content to match against
# - One hook file per feature (can be disabled via a single settings.json entry)
# - Minimal wiki/ is created ONLY when the project has no documentation at all
# - Auto-seeds .jarvis/memory.md from git log / README / CLAUDE.md when installing memory-recall
#
# Usage:
#   adopt.sh [--enable task-routing,focus-tracker] [--skip memory-recall] [--dry-run]
#
# Without --enable/--skip — interactive: prints the gap matrix and waits for y/n.

set -euo pipefail

# ─── CWD lock ─────────────────────────────────────────────────────
# Pin the project root at the very start — any cd inside won't affect returns.
PROJECT_ROOT="$(pwd)"
cd "${PROJECT_ROOT}"

SKILL_PATH="$(cd "$(dirname "$(realpath "$0")")/.." && pwd)"
UNIVERSAL="${SKILL_PATH}/archive/templates/universal"

# ─── Args ─────────────────────────────────────────────────────────
ENABLE=""
SKIP=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --enable) ENABLE="$2"; shift 2 ;;
    --skip) SKIP="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

ALL_FEATURES="task-routing adr-detector memory-recall focus-tracker wiki-maintenance security-watch"

# ─── Phase A — Observe (read-only) ────────────────────────────────
echo "💠 JARVIS Adopt — Phase A: scanning project state"
echo "   Project: ${PROJECT_ROOT}"
echo "   Skill:   ${SKILL_PATH}"
echo ""

HAS_CLAUDEMD=$([ -f CLAUDE.md ] && echo 1 || echo 0)
HAS_DOTCLAUDE=$([ -d .claude ] && echo 1 || echo 0)
HAS_SETTINGS=$([ -f .claude/settings.json ] && echo 1 || echo 0)
HAS_DOCS=$([ -d docs ] && echo 1 || echo 0)
HAS_WIKI=$([ -d wiki ] && echo 1 || echo 0)
HAS_CHANGELOG=$([ -f CHANGELOG.md ] && echo 1 || echo 0)
HAS_HUSKY=$([ -d .husky ] && echo 1 || echo 0)
HAS_GITLEAKS=$([ -f .gitleaks.toml ] && echo 1 || echo 0)
HAS_TODO=$([ -f TODO.md ] && echo 1 || echo 0)
HAS_README=$([ -f README.md ] && echo 1 || echo 0)
README_LINES=0
[ "${HAS_README}" = "1" ] && README_LINES=$(wc -l < README.md | tr -d ' ')
HAS_GIT=$([ -d .git ] && echo 1 || echo 0)
GIT_COMMITS=0
if [ "${HAS_GIT}" = "1" ]; then
  GIT_COMMITS=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ') || GIT_COMMITS=0
fi

echo "   ┌─ Existing infrastructure:"
[ "${HAS_CLAUDEMD}" = "1" ] && echo "   │  • CLAUDE.md ($(wc -l < CLAUDE.md | tr -d ' ') lines)"
[ "${HAS_DOTCLAUDE}" = "1" ] && echo "   │  • .claude/ (settings: ${HAS_SETTINGS})"
[ "${HAS_DOCS}" = "1" ] && echo "   │  • docs/"
[ "${HAS_WIKI}" = "1" ] && echo "   │  • wiki/"
[ "${HAS_CHANGELOG}" = "1" ] && echo "   │  • CHANGELOG.md"
[ "${HAS_README}" = "1" ] && echo "   │  • README.md (${README_LINES} lines)"
[ "${HAS_HUSKY}" = "1" ] && echo "   │  • .husky/ (pre-commit)"
[ "${HAS_GITLEAKS}" = "1" ] && echo "   │  • .gitleaks.toml"
[ "${HAS_TODO}" = "1" ] && echo "   │  • TODO.md"
[ "${HAS_GIT}" = "1" ] && echo "   │  • git (${GIT_COMMITS} commits)"
echo "   └─"
echo ""

# CLAUDE.md — check if it already has model/plan/complexity rules
CLAUDE_HAS_MODEL_RULES=0
if [ "${HAS_CLAUDEMD}" = "1" ]; then
  if grep -qiE "opus|sonnet|haiku|plan.?mode|trivial|simple|medium|complex|architectural" CLAUDE.md 2>/dev/null; then
    CLAUDE_HAS_MODEL_RULES=1
  fi
fi

# Docs freshness — git log on docs/ wiki/ within last 30 days
DOCS_FRESH=0
if [ "${HAS_GIT}" = "1" ] && ([ "${HAS_DOCS}" = "1" ] || [ "${HAS_WIKI}" = "1" ]); then
  FRESH=$(git log --since="30 days ago" --oneline -- docs/ wiki/ 2>/dev/null | head -1)
  [ -n "${FRESH}" ] && DOCS_FRESH=1
fi

# ─── Phase B — Gap analysis ───────────────────────────────────────
echo "💠 Phase B: gap analysis"
echo ""

FEATURES_TO_INSTALL=()
FEATURES_SKIPPED=()
SKIP_REASONS=()  # parallel to FEATURES_SKIPPED (bash 3.2 — no assoc arrays)

consider() {
  local feature="$1"
  local skip_reason="$2"
  local dead_reason="$3"

  if [ -n "${SKIP}" ] && echo ",${SKIP}," | grep -q ",${feature},"; then
    FEATURES_SKIPPED+=("${feature}")
    SKIP_REASONS+=("user --skip")
    return
  fi
  if [ -n "${ENABLE}" ]; then
    if echo ",${ENABLE}," | grep -q ",${feature},"; then
      FEATURES_TO_INSTALL+=("${feature}")
      return
    fi
    FEATURES_SKIPPED+=("${feature}")
    SKIP_REASONS+=("not in --enable list")
    return
  fi
  if [ -n "${skip_reason}" ]; then
    FEATURES_SKIPPED+=("${feature}")
    SKIP_REASONS+=("${skip_reason}")
    return
  fi
  if [ -n "${dead_reason}" ]; then
    FEATURES_SKIPPED+=("${feature}")
    SKIP_REASONS+=("dead-by-construction: ${dead_reason}")
    return
  fi
  FEATURES_TO_INSTALL+=("${feature}")
}

skip_reason_for() {
  local feature="$1"
  local i=0
  for f in "${FEATURES_SKIPPED[@]:-}"; do
    if [ "${f}" = "${feature}" ]; then
      echo "${SKIP_REASONS[${i}]}"
      return
    fi
    i=$((i+1))
  done
  echo "unknown"
}

TR_SKIP=""
[ "${CLAUDE_HAS_MODEL_RULES}" = "1" ] && TR_SKIP="CLAUDE.md already has model/plan rules"
consider "task-routing" "${TR_SKIP}" ""

consider "adr-detector" "" ""

MR_SKIP=""
if [ "${DOCS_FRESH}" = "1" ]; then
  MR_SKIP="docs/ or wiki/ updated within 30 days (user has own recall)"
fi
consider "memory-recall" "${MR_SKIP}" ""

FT_SKIP=""
if [ "${HAS_TODO}" = "1" ]; then
  FT_SKIP="TODO.md is maintained"
elif [ "${HAS_CHANGELOG}" = "1" ] && [ "${HAS_GIT}" = "1" ]; then
  CH_FRESH=$(git log --since="30 days ago" --oneline -- CHANGELOG.md 2>/dev/null | head -1)
  [ -n "${CH_FRESH}" ] && FT_SKIP="CHANGELOG.md actively maintained"
fi
consider "focus-tracker" "${FT_SKIP}" ""

WM_SKIP=""
[ "${DOCS_FRESH}" = "1" ] && WM_SKIP="user maintains docs their way"
consider "wiki-maintenance" "${WM_SKIP}" ""

SW_SKIP=""
[ "${HAS_GITLEAKS}" = "1" ] && SW_SKIP=".gitleaks.toml present"
if [ -z "${SW_SKIP}" ] && [ "${HAS_HUSKY}" = "1" ]; then
  if grep -rqiE "gitleaks|trufflehog|detect-secrets" .husky/ 2>/dev/null; then
    SW_SKIP="husky pre-commit has secret scanning"
  fi
fi
consider "security-watch" "${SW_SKIP}" ""

# ─── Phase C — Proposal ───────────────────────────────────────────
echo "   ┌─ Will install:"
for f in "${FEATURES_TO_INSTALL[@]:-}"; do
  [ -z "${f}" ] && continue
  echo "   │  ✓ ${f}"
done
echo "   ├─ Will skip:"
for f in "${FEATURES_SKIPPED[@]:-}"; do
  [ -z "${f}" ] && continue
  echo "   │  × ${f}  — $(skip_reason_for "${f}")"
done
echo "   └─"
echo ""

if [ "${DRY_RUN}" = "1" ]; then
  echo "💠 Dry-run mode — exiting before install"
  exit 0
fi

if [ -z "${ENABLE}" ] && [ -z "${SKIP}" ] && [ ${#FEATURES_TO_INSTALL[@]} -gt 0 ]; then
  read -p "Proceed with install? (y/n) " -n 1 -r
  echo ""
  [[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Aborted."; exit 0; }
fi

# ─── Phase D — Soft install ───────────────────────────────────────
echo "💠 Phase D: soft install"

mkdir -p .jarvis
[ -f .jarvis/state.md ] || cat > .jarvis/state.md <<EOF
# JARVIS State
mode: adopt
adopt-date: $(date +%Y-%m-%d)
project-root: ${PROJECT_ROOT}
skill-path: ${SKILL_PATH}
archetype-detected: (not set — adopt does not apply overlay)
archetype-applied: none
EOF
touch .jarvis/memory.md .jarvis/focus.md .jarvis/timeline.md
if [ ! -f .jarvis/preferences.md ] && [ -f "${SKILL_PATH}/core/state/preferences.md.template" ]; then
  cp "${SKILL_PATH}/core/state/preferences.md.template" .jarvis/preferences.md
fi

MARKER="<!-- jarvis-starter-adopt: see .jarvis/state.md -->"
if [ ! -f CLAUDE.md ]; then
  echo "${MARKER}" > CLAUDE.md
elif ! grep -qF "${MARKER}" CLAUDE.md; then
  echo "" >> CLAUDE.md
  echo "${MARKER}" >> CLAUDE.md
fi

WIKI_CREATED=0
if [ "${HAS_DOCS}" = "0" ] && [ "${HAS_WIKI}" = "0" ] && [ "${HAS_CHANGELOG}" = "0" ] && [ "${README_LINES}" -lt 100 ]; then
  mkdir -p wiki/{Systems,Architecture,Devlog,Decisions}
  WIKI_CREATED=1
  if [ ! -f wiki/HOME.md ]; then
    PROJECT_NAME=$(basename "${PROJECT_ROOT}")
    cat > wiki/HOME.md <<EOF
---
tags: [moc, home]
---

# ${PROJECT_NAME} — Knowledge base

<!-- TODO: short project description -->

**Stack**: <!-- TODO: fill after Phase 1 classification -->
**Archetypes**: <!-- TODO: web-app / telegram-bot / ... -->

---

## Systems
\`\`\`dataview
TABLE tags, status
FROM "wiki/Systems"
SORT file.name ASC
\`\`\`

## Architecture
\`\`\`dataview
TABLE tags
FROM "wiki/Architecture"
SORT file.name ASC
\`\`\`

## Decisions
\`\`\`dataview
LIST
FROM "wiki/Decisions"
SORT file.ctime DESC
\`\`\`

## Devlog
\`\`\`dataview
LIST
FROM "wiki/Devlog"
SORT file.ctime DESC
LIMIT 10
\`\`\`
EOF
  fi
  [ -f wiki/Devlog/README.md ] || echo "# Devlog" > wiki/Devlog/README.md
  [ -f wiki/Systems/_template.md ] || echo "# System — <Name>" > wiki/Systems/_template.md
  echo "   ✓ minimal wiki/ created (no docs detected)"
fi

seed_memory() {
  if [ -s .jarvis/memory.md ]; then
    return
  fi
  {
    echo "# JARVIS Memory (auto-seeded)"
    echo ""
    if [ "${HAS_GIT}" = "1" ]; then
      echo "## Recent commits (git log -50)"
      git log --oneline -50 2>/dev/null | head -50 | sed 's/^/- /'
      echo ""
    fi
    if [ "${HAS_README}" = "1" ]; then
      echo "## From README.md (first 40 lines)"
      head -40 README.md
      echo ""
    fi
    if [ "${HAS_CLAUDEMD}" = "1" ]; then
      echo "## From CLAUDE.md"
      grep -v '^<!-- jarvis' CLAUDE.md | head -60
      echo ""
    fi
  } > .jarvis/memory.md
  echo "   ✓ .jarvis/memory.md seeded from git/README/CLAUDE.md ($(wc -l < .jarvis/memory.md | tr -d ' ') lines)"
}

mkdir -p .claude/hooks
install_hook() {
  local feature="$1"
  local event="$2"
  local matcher="${3:-}"
  local body="$4"
  local hook_file=".claude/hooks/jarvis-${feature}.sh"

  if [ -f "${hook_file}" ]; then
    echo "   ℹ skipping ${feature} — hook file already exists (idempotent)"
    return
  fi

  cat > "${hook_file}" <<EOF
#!/bin/bash
# JARVIS hook: ${feature} — installed by adopt.sh $(date +%Y-%m-%d)
INPUT=\$(cat)
${body}
exit 0
EOF
  chmod +x "${hook_file}"
  echo "   ✓ ${hook_file}"
}

install_hooks_registration() {
  local tmpfile="${PROJECT_ROOT}/.claude/settings.json.jarvis-adopt.tmp"

  python3 - "${PROJECT_ROOT}" "${FEATURES_TO_INSTALL[*]:-}" > "${tmpfile}" <<'PY'
import json, sys
project_root, features = sys.argv[1], sys.argv[2].split()

def pt(matcher, cmd):
    return {"matcher": matcher, "hooks": [{"type": "command", "command": f"bash {project_root}/.claude/hooks/{cmd}"}]}
def ups(cmd):
    return {"hooks": [{"type": "command", "command": f"bash {project_root}/.claude/hooks/{cmd}"}]}

hooks = {"PostToolUse": [], "UserPromptSubmit": []}
for f in features:
    if f == "task-routing":
        hooks["UserPromptSubmit"].append(ups("jarvis-task-routing.sh"))
    elif f == "adr-detector":
        hooks["UserPromptSubmit"].append(ups("jarvis-adr-detector.sh"))
    elif f == "memory-recall":
        hooks["UserPromptSubmit"].append(ups("jarvis-memory-recall.sh"))
    elif f == "wiki-maintenance":
        hooks["PostToolUse"].append(pt("Edit|Write", "jarvis-wiki-maintenance.sh"))
    elif f == "focus-tracker":
        hooks["PostToolUse"].append(pt("Edit|Write", "jarvis-focus-tracker.sh"))
    elif f == "security-watch":
        hooks["PostToolUse"].append(pt("Edit|Write|Bash", "jarvis-security-watch.sh"))

hooks = {k: v for k, v in hooks.items() if v}
print(json.dumps({"hooks": hooks}, indent=2, ensure_ascii=False))
PY

  if [ -f .claude/settings.json ]; then
    cp .claude/settings.json ".claude/settings.json.pre-jarvis-adopt.bak"
    jq -s '
      .[0] as $user | .[1] as $jarvis |
      $user * {
        hooks: (
          ($user.hooks // {}) as $uh |
          ($jarvis.hooks // {}) as $jh |
          ($uh | to_entries) as $ue |
          ($jh | to_entries) as $je |
          (($ue + $je) | group_by(.key) | map({
            key: .[0].key,
            value: (map(.value) | add | unique_by(
              (.matcher // "") + "::" + ((.hooks // []) | map(.command // "") | join(","))
            ))
          })) | from_entries
        )
      }
    ' .claude/settings.json "${tmpfile}" > .claude/settings.json.new
    mv .claude/settings.json.new .claude/settings.json
    rm -f "${tmpfile}"
    echo "   ✓ .claude/settings.json — JARVIS hooks merged (user config preserved, backup at .pre-jarvis-adopt.bak)"
  else
    mkdir -p .claude
    mv "${tmpfile}" .claude/settings.json
    echo "   ✓ .claude/settings.json — created with JARVIS hooks"
  fi
}

for f in "${FEATURES_TO_INSTALL[@]:-}"; do
  [ -z "${f}" ] && continue
  case "${f}" in
    task-routing)
      install_hook "task-routing" "UserPromptSubmit" "" \
        "bash \"${SKILL_PATH}/core/task-routing/prompt-analyzer.sh\" <<< \"\$INPUT\""
      ;;
    adr-detector)
      install_hook "adr-detector" "UserPromptSubmit" "" \
        "bash \"${SKILL_PATH}/core/task-routing/adr-detector.sh\" <<< \"\$INPUT\""
      ;;
    memory-recall)
      install_hook "memory-recall" "UserPromptSubmit" "" \
        "bash \"${SKILL_PATH}/core/memory-recall/topic-matcher.sh\" <<< \"\$INPUT\""
      seed_memory
      ;;
    focus-tracker)
      install_hook "focus-tracker" "PostToolUse" "Edit|Write" \
        "bash \"${SKILL_PATH}/core/focus-tracker/focus-updater.sh\" <<< \"\$INPUT\""
      ;;
    wiki-maintenance)
      install_hook "wiki-maintenance" "PostToolUse" "Edit|Write" \
        "bash \"${SKILL_PATH}/core/wiki-maintenance/hook-detector.sh\" <<< \"\$INPUT\""
      ;;
    security-watch)
      install_hook "security-watch" "PostToolUse" "Edit|Write|Bash" "$(cat <<'BODY'
bash "{{SKILL_PATH}}/core/security-watch/secret-scanner.sh" <<< "$INPUT"
bash "{{SKILL_PATH}}/core/security-watch/gitignore-check.sh" <<< "$INPUT"
BODY
)"
      sed -i '' "s|{{SKILL_PATH}}|${SKILL_PATH}|g" .claude/hooks/jarvis-security-watch.sh 2>/dev/null || \
        sed -i "s|{{SKILL_PATH}}|${SKILL_PATH}|g" .claude/hooks/jarvis-security-watch.sh
      ;;
  esac
done

install_hooks_registration

# ─── Phase E — Record ─────────────────────────────────────────────
{
  echo ""
  echo "## $(date +%Y-%m-%d) — Adopt"
  echo "Installed: ${FEATURES_TO_INSTALL[*]:-(none)}"
  echo "Skipped: ${FEATURES_SKIPPED[*]:-(none)}"
  [ "${WIKI_CREATED}" = "1" ] && echo "Created minimal wiki/"
} >> .jarvis/timeline.md

{
  echo "# Enabled features"
  for f in "${FEATURES_TO_INSTALL[@]:-}"; do
    [ -z "${f}" ] && continue
    echo "- ${f}"
  done
  echo ""
  echo "# Skipped"
  for f in "${FEATURES_SKIPPED[@]:-}"; do
    [ -z "${f}" ] && continue
    echo "- ${f} — $(skip_reason_for "${f}")"
  done
} > .jarvis/enabled-features.md

HOOK_COUNT=$(jq -r '[.hooks | to_entries[] | .value[] | .hooks[]?] | length' .claude/settings.json 2>/dev/null || echo "0")
echo ""
echo "✅ Adopt complete."
echo "   Hooks in settings.json: ${HOOK_COUNT}"
echo "   State: .jarvis/state.md, enabled-features.md, timeline.md"
echo ""
echo "⚠️  Claude Code quirk: the permission system may strip settings.json hooks mid-session."
echo "   Mitigation: restart your Claude Code session OR run this installer from outside Claude Code."
