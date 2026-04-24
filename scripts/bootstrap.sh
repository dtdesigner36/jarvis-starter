#!/bin/bash
# JARVIS bootstrap helper — for power-users who want to roll out without dialogue
# Normally bootstrap goes via Claude Code dialogue (see SKILL.md)
#
# Includes CONFLICT DETECTION: does not overwrite existing files, merges instead

set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: bash bootstrap.sh <archetype> [second-archetype]"
  echo "Archetypes: telegram-bot web-app web-api landing game parser mobile-app desktop library llm-agent"
  exit 1
fi

ARCHETYPE="$1"
SECONDARY="${2:-}"

SKILL_PATH=$(dirname "$(realpath "$0")")/..

# Check archetype exists
if [ ! -d "${SKILL_PATH}/archive/archetypes/tier1/${ARCHETYPE}" ] && [ ! -f "${SKILL_PATH}/archive/archetypes/tier2/${ARCHETYPE}.md" ]; then
  echo "❌ Archetype '${ARCHETYPE}' not found in tier1 or tier2"
  exit 1
fi

echo "💠 JARVIS Bootstrap: ${ARCHETYPE}${SECONDARY:+ + $SECONDARY}"
echo ""

# ─── CONFLICT DETECTION ───────────────────────────────────────────
CONFLICTS=()

if [ -d .jarvis ]; then
  CONFLICTS+=(".jarvis/ already exists")
fi

if [ -f CLAUDE.md ]; then
  CONFLICTS+=("CLAUDE.md already exists — will merge")
fi

if [ -f .claude/settings.json ]; then
  CONFLICTS+=(".claude/settings.json already exists — will merge hooks")
fi

if [ -d .claude/hooks ]; then
  for hook in post-edit.sh post-bash.sh pre-prompt.sh; do
    if [ -f ".claude/hooks/$hook" ]; then
      CONFLICTS+=(".claude/hooks/$hook already exists — will merge (source old + JARVIS logic)")
    fi
  done
fi

if [ -d .claude/commands ]; then
  for cmd in devlog.md new-system.md obsidian-canvas.md; do
    if [ -f ".claude/commands/$cmd" ]; then
      CONFLICTS+=(".claude/commands/$cmd already exists — will warn, not overwrite")
    fi
  done
fi

if [ -d wiki ]; then
  CONFLICTS+=("wiki/ already exists — JARVIS will not touch existing files, only add missing ones")
fi

if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo "⚠️ Conflicts detected with existing project content:"
  printf '  • %s\n' "${CONFLICTS[@]}"
  echo ""
  read -p "Continue bootstrap with merge strategy? (y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

# ─── 1. Create .jarvis/ (safe merge) ──────────────────────────────
mkdir -p .jarvis

# bootstrap is the greenfield installer (`jarvis start`) — it always creates
# wiki/{Systems,Architecture,Devlog,Canvas} below. No namespace matrix here:
# that lives in adopt.sh, which handles existing projects with a pre-existing
# docs/ or wiki/ tree. State must not claim a .jarvis location that bootstrap
# does not honor.

if [ ! -f .jarvis/state.md ]; then
  cat > .jarvis/state.md <<EOF
# JARVIS State
mode: bootstrap
bootstrap-date: $(date +%Y-%m-%d)
project-root: $(pwd)
skill-path: ${SKILL_PATH}
archetypes: ${ARCHETYPE}${SECONDARY:+ + $SECONDARY}
wiki-ownership: active
wiki-location: wiki
owned-files:
EOF
fi

touch .jarvis/memory.md .jarvis/focus.md .jarvis/timeline.md

# Copy preferences template if not exists
if [ ! -f .jarvis/preferences.md ] && [ -f "${SKILL_PATH}/core/state/preferences.md.template" ]; then
  cp "${SKILL_PATH}/core/state/preferences.md.template" .jarvis/preferences.md
fi

# ─── 2. Create wiki/ (merge, don't overwrite) ─────────────────────
mkdir -p wiki/{Systems,Architecture,Devlog,Canvas}

UNIVERSAL="${SKILL_PATH}/archive/templates/universal"

# ─── 2b. .gitignore — idempotent merge of JARVIS artifact rules (v0.2.4) ──
# `npx skills add` drops the entire skill at .agents/ in the project root.
# If we don't pre-ignore it, `git init && git add -A` sweeps hundreds of
# template files into the user's first commit. Real user hit this on v0.2.3.
JARVIS_GITIGNORE_MARK="# JARVIS-starter installed skill payload"
JARVIS_GITIGNORE_TMPL="${UNIVERSAL}/gitignore.template"
if [ ! -f "${JARVIS_GITIGNORE_TMPL}" ]; then
  echo "  ⚠️ .gitignore: template missing in package (${JARVIS_GITIGNORE_TMPL}) — skipped."
  echo "     You may want to add .agents/ and skills-lock.json manually."
elif [ ! -f .gitignore ] || ! grep -qF "$JARVIS_GITIGNORE_MARK" .gitignore; then
  [ -f .gitignore ] && echo "" >> .gitignore
  cat "${JARVIS_GITIGNORE_TMPL}" >> .gitignore
  echo "  ✅ .gitignore: added JARVIS artifacts (.agents/, skills-lock.json, backups)"
fi

# Wiki HOME — only if missing
if [ ! -f wiki/HOME.md ]; then
  cp "${UNIVERSAL}/wiki/HOME.md.template" wiki/HOME.md

  # Substitute known values in HOME.md
  PROJECT_NAME=$(basename "$(pwd)")
  ARCHETYPES_STR="${ARCHETYPE}${SECONDARY:+ + $SECONDARY}"
  sed -i '' "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" wiki/HOME.md 2>/dev/null || sed -i "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" wiki/HOME.md
  sed -i '' "s|{{ARCHETYPES}}|${ARCHETYPES_STR}|g" wiki/HOME.md 2>/dev/null || sed -i "s|{{ARCHETYPES}}|${ARCHETYPES_STR}|g" wiki/HOME.md
  # What bootstrap doesn't know — mark as TODO so Claude sees it and fills in
  sed -i '' "s|{{PROJECT_DESCRIPTION}}|<!-- TODO: short project description -->|g" wiki/HOME.md 2>/dev/null || sed -i "s|{{PROJECT_DESCRIPTION}}|<!-- TODO: short project description -->|g" wiki/HOME.md
  sed -i '' "s|{{STACK}}|<!-- TODO: stack from Phase 1 classification -->|g" wiki/HOME.md 2>/dev/null || sed -i "s|{{STACK}}|<!-- TODO: stack from Phase 1 classification -->|g" wiki/HOME.md
  # List placeholders — clear (dataview picks up files as they appear)
  sed -i '' "s|{{ARCHETYPE_CANVASES}}||g" wiki/HOME.md 2>/dev/null || sed -i "s|{{ARCHETYPE_CANVASES}}||g" wiki/HOME.md
  sed -i '' "s|{{SYSTEMS_LIST}}||g" wiki/HOME.md 2>/dev/null || sed -i "s|{{SYSTEMS_LIST}}||g" wiki/HOME.md
  sed -i '' "s|{{ARCHITECTURE_LIST}}||g" wiki/HOME.md 2>/dev/null || sed -i "s|{{ARCHITECTURE_LIST}}||g" wiki/HOME.md
fi

if [ ! -f wiki/Devlog/README.md ]; then
  cp "${UNIVERSAL}/wiki/Devlog/README.md" wiki/Devlog/README.md
fi

if [ ! -f wiki/Systems/_template.md ]; then
  cp "${UNIVERSAL}/wiki/Systems/_template.md" wiki/Systems/_template.md
fi

if [ ! -f wiki/Architecture/_template.md ]; then
  cp "${UNIVERSAL}/wiki/Architecture/_template.md" wiki/Architecture/_template.md
fi

# ─── 3. CLAUDE.md (merge if exists) ───────────────────────────────
# Pre-render the base template with empty placeholder-sections removed
CLAUDE_RENDERED="${UNIVERSAL}/CLAUDE.md.base.rendered.tmp"
cp "${UNIVERSAL}/CLAUDE.md.base" "${CLAUDE_RENDERED}"
python3 - "${CLAUDE_RENDERED}" <<'PY'
import re, sys
path = sys.argv[1]
content = open(path, encoding="utf-8").read()
pattern = re.compile(r"^## [^\n]* changes\n\{\{[A-Z_]+_RULES\}\}\n+", re.MULTILINE)
content = pattern.sub("", content)
open(path, "w", encoding="utf-8").write(content)
PY

# Idempotency marker — HTML comment, doesn't affect rendering
CLAUDE_MARKER="<!-- jarvis-starter-bootstrap -->"

if [ ! -f CLAUDE.md ]; then
  # Fresh install: marker + rendered base
  echo "${CLAUDE_MARKER}" > CLAUDE.md
  cat "${CLAUDE_RENDERED}" >> CLAUDE.md
  rm -f "${CLAUDE_RENDERED}"
elif grep -qF "${CLAUDE_MARKER}" CLAUDE.md; then
  # Idempotency: bootstrap already ran, skip append
  rm -f "${CLAUDE_RENDERED}"
  echo "  ℹ️ CLAUDE.md already contains the JARVIS marker — append skipped (idempotent re-run)"
else
  # Brownfield merge: append JARVIS section with marker
  {
    echo ""
    echo "${CLAUDE_MARKER}"
    echo "# JARVIS-Starter (appended by bootstrap)"
    echo ""
    cat "${CLAUDE_RENDERED}"
  } >> CLAUDE.md
  rm -f "${CLAUDE_RENDERED}"
fi

# ─── 4. Hooks (merge if exists) ───────────────────────────────────
mkdir -p .claude/hooks

for hook_name in post-edit.sh post-bash.sh pre-prompt.sh; do
  SRC="${UNIVERSAL}/hooks/${hook_name}"
  DEST=".claude/hooks/${hook_name}"

  if [ -f "$DEST" ]; then
    # Backup existing and wrap
    cp "$DEST" "${DEST}.pre-jarvis.bak"
    echo "  → backup: ${DEST}.pre-jarvis.bak"
    # Append JARVIS logic to existing
    echo "" >> "$DEST"
    echo "# === JARVIS-starter hooks (appended) ===" >> "$DEST"
    grep -v '^#!/bin/bash' "$SRC" >> "$DEST"
  else
    cp "$SRC" "$DEST"
  fi

  chmod +x "$DEST"
done

# Replace placeholders
SKILL_PATH_ABS=$(cd "${SKILL_PATH}" && pwd)
PROJECT_ROOT_ABS="$(pwd)"
sed -i '' "s|{{SKILL_PATH}}|${SKILL_PATH_ABS}|g" .claude/hooks/*.sh 2>/dev/null || sed -i "s|{{SKILL_PATH}}|${SKILL_PATH_ABS}|g" .claude/hooks/*.sh
sed -i '' "s|{{PROJECT_ROOT}}|${PROJECT_ROOT_ABS}|g" .claude/hooks/*.sh 2>/dev/null || sed -i "s|{{PROJECT_ROOT}}|${PROJECT_ROOT_ABS}|g" .claude/hooks/*.sh

# Replace archetype trigger placeholders
ADDON="${SKILL_PATH_ABS}/archive/archetypes/tier1/${ARCHETYPE}/hooks-addon.sh"
if [ -f "${ADDON}" ]; then
  TRIGGER_LINE="bash \"${ADDON}\" <<< \"\$INPUT\""
  echo "  → archetype hook triggers: ${ADDON}"
else
  TRIGGER_LINE=""
fi
TRIGGER_ESC=$(printf '%s\n' "${TRIGGER_LINE}" | sed 's:[&|\\]:\\&:g')
sed -i '' "s|{{ARCHETYPE_POST_EDIT_TRIGGERS}}|${TRIGGER_ESC}|g" .claude/hooks/post-edit.sh 2>/dev/null || sed -i "s|{{ARCHETYPE_POST_EDIT_TRIGGERS}}|${TRIGGER_ESC}|g" .claude/hooks/post-edit.sh
sed -i '' "s|{{ARCHETYPE_POST_BASH_TRIGGERS}}|${TRIGGER_ESC}|g" .claude/hooks/post-bash.sh 2>/dev/null || sed -i "s|{{ARCHETYPE_POST_BASH_TRIGGERS}}|${TRIGGER_ESC}|g" .claude/hooks/post-bash.sh

# ─── 5. Commands (skip if conflict) ──────────────────────────────
mkdir -p .claude/commands

for cmd_file in "${UNIVERSAL}/commands/"*.md; do
  cmd_name=$(basename "$cmd_file")
  dest=".claude/commands/${cmd_name}"

  if [ -f "$dest" ]; then
    echo "  ⚠️ .claude/commands/${cmd_name} already exists — skipping (to preserve yours)"
  else
    cp "$cmd_file" "$dest"
  fi
done

# ─── 6. Apply archetype overlay ──────────────────────────────────
if [ -d "${SKILL_PATH}/archive/archetypes/tier1/${ARCHETYPE}" ]; then
  ARCHETYPE_DIR="${SKILL_PATH}/archive/archetypes/tier1/${ARCHETYPE}"

  if [ -f "${ARCHETYPE_DIR}/CLAUDE.md.addon" ]; then
    echo "" >> CLAUDE.md
    cat "${ARCHETYPE_DIR}/CLAUDE.md.addon" >> CLAUDE.md
  fi

  if [ -d "${ARCHETYPE_DIR}/commands" ]; then
    for cmd_file in "${ARCHETYPE_DIR}/commands/"*.md; do
      [ ! -e "$cmd_file" ] && continue
      cmd_name=$(basename "$cmd_file")
      dest=".claude/commands/${cmd_name}"
      if [ ! -f "$dest" ]; then
        cp "$cmd_file" "$dest"
      fi
    done
  fi

  if [ -d "${ARCHETYPE_DIR}/wiki-extra" ]; then
    cp -rn "${ARCHETYPE_DIR}/wiki-extra/"* wiki/ 2>/dev/null || true
  fi
fi

# ─── 7. settings.json (real merge) ───────────────────────────────
SETTINGS_TMPL="${UNIVERSAL}/settings.json.rendered.tmp"
cp "${UNIVERSAL}/settings.json" "${SETTINGS_TMPL}"
# Render {{PROJECT_ROOT}} and shell-quote the command path so project dirs with
# spaces or shell metacharacters don't break hook execution.
python3 - "${SETTINGS_TMPL}" "$(pwd)" <<'PY'
import json, shlex, sys
tmpl, project_root = sys.argv[1], sys.argv[2]
with open(tmpl, encoding="utf-8") as f:
    data = json.load(f)
for event in (data.get("hooks") or {}).values():
    for group in event:
        for hook in group.get("hooks", []):
            cmd = (hook.get("command") or "").replace("{{PROJECT_ROOT}}", project_root)
            if cmd.startswith("bash "):
                hook["command"] = "bash " + shlex.quote(cmd[5:])
            else:
                hook["command"] = cmd
with open(tmpl, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PY

if [ ! -f .claude/settings.json ]; then
  # Fresh install — just move the rendered template
  mv "${SETTINGS_TMPL}" .claude/settings.json
  echo "  ✅ .claude/settings.json created with all JARVIS hooks"
else
  # Merge: keep user config, add missing JARVIS hooks
  if command -v jq >/dev/null 2>&1; then
    cp .claude/settings.json .claude/settings.json.pre-jarvis.bak
    echo "  → backup: .claude/settings.json.pre-jarvis.bak"

    # Merge hooks via jq: user hooks stay, JARVIS hooks added if missing.
    # Defensive: each `//` nullable-coalesce handles missing/null .hooks, null
    # event values, null inner `hooks` arrays. `add // []` guards the empty-$ue
    # case (to_entries of {} plus to_entries of jarvis always produces jarvis).
    jq -s '
      .[0] as $user | .[1] as $jarvis |
      $user * {
        hooks: (
          (($user.hooks // {}) | to_entries) as $ue |
          (($jarvis.hooks // {}) | to_entries) as $je |
          (($ue + $je)
            | map(select(.value | type == "array"))
            | group_by(.key)
            | map({
                key: .[0].key,
                value: (map(.value) | add // [] | unique_by(
                  (.matcher // "") + "::" + ((.hooks // []) | map(.command // "") | join(","))
                ))
              }))
          | from_entries
        )
      }
    ' .claude/settings.json "${SETTINGS_TMPL}" > .claude/settings.json.new

    if [ -s .claude/settings.json.new ]; then
      mv .claude/settings.json.new .claude/settings.json
      rm -f "${SETTINGS_TMPL}"
      echo "  ✅ .claude/settings.json — JARVIS hooks merged (user config preserved)"
    else
      rm -f .claude/settings.json.new "${SETTINGS_TMPL}"
      echo "  ❌ jq merge failed — settings.json unchanged, backup at .pre-jarvis.bak"
      echo "      Manual merge: template at ${UNIVERSAL}/settings.json"
      exit 1
    fi
  else
    echo "  ⚠️ jq not found — automatic merge not possible"
    echo "      Manual merge: add hooks from ${SETTINGS_TMPL} to .claude/settings.json"
    echo "      (or install jq: brew install jq / apt install jq)"
  fi
fi

# ─── Final-state validation (reads the file on disk, not intermediate state) ──
# Before v0.2.4 the `HOOKS_COUNT` counter read the file right after merge and
# announced success. A real user on v0.2.3 saw "3 hooks installed" while the
# final on-disk file had .hooks == null because the IDE layer wiped the block
# between the merge and the counter read. We now assert both expected event
# keys are populated, fail loudly otherwise, and flag the known IDE quirk.
if command -v jq >/dev/null 2>&1; then
  PT_COUNT=$(jq -r '(.hooks.PostToolUse // []) | length' .claude/settings.json 2>/dev/null || echo 0)
  UP_COUNT=$(jq -r '(.hooks.UserPromptSubmit // []) | length' .claude/settings.json 2>/dev/null || echo 0)
  if [ "${PT_COUNT}" -lt 1 ] || [ "${UP_COUNT}" -lt 1 ]; then
    echo ""
    echo "  ❌ JARVIS verification FAILED — .claude/settings.json is missing hooks on disk."
    echo "     PostToolUse=${PT_COUNT}  UserPromptSubmit=${UP_COUNT} (expected ≥1 each)"
    echo ""
    echo "     Likely cause:"
    echo "       (a) a known Claude Code / VSCode extension quirk that strips the"
    echo "           .hooks block from settings.json on permission-grants, OR"
    echo "       (b) a settings.json shape our merge didn't anticipate."
    echo ""
    echo "     Recovery:"
    echo "       1. Restore from backup: cp .claude/settings.json.pre-jarvis.bak .claude/settings.json"
    echo "       2. Close the Claude Code / VSCode session and re-run bootstrap from a"
    echo "          standalone terminal."
    echo "       3. If the problem persists, file an issue with a redacted settings.json:"
    echo "          https://github.com/dtdesigner36/jarvis-starter/issues"
    exit 1
  fi
  echo "  ✅ JARVIS hooks verified on disk: PostToolUse=${PT_COUNT}  UserPromptSubmit=${UP_COUNT}"
  echo "     ⚠  Note: Claude Code / VSCode may rewrite settings.json on permission"
  echo "        prompts and drop this block mid-session. If that happens, re-run"
  echo "        'bash \$SKILL_PATH/scripts/bootstrap.sh <archetype>' from an external shell."
else
  echo "  ⚠️ jq not installed — unable to verify hook installation on disk."
fi

# ─── 8. Record bootstrap in timeline ─────────────────────────────
cat >> .jarvis/timeline.md << EOF

## $(date +%Y-%m-%d) — Bootstrap
Installed archetype: ${ARCHETYPE}${SECONDARY:+ + $SECONDARY}
Stack: (see state.md)
EOF

# ─── Done ────────────────────────────────────────────────────────
echo ""
echo "✅ Bootstrap complete!"
echo ""
echo "Created/updated:"
echo "  .jarvis/        — state, memory, focus, preferences"
echo "  .claude/        — hooks, commands, settings"
echo "  wiki/           — HOME, Systems/, Architecture/, Devlog/, Canvas/"
echo "  CLAUDE.md       — JARVIS rules + archetype"
echo ""
echo "NOT created:"
echo "  school-wiki/    — school-mode plugin is off (jarvis school on to activate)"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in this folder"
echo "  2. jarvis status — see current state"
echo "  3. jarvis suggest — get improvement suggestions"
echo "  4. If you want to learn the stack: jarvis school on (optional)"
