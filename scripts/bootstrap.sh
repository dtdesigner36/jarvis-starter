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

if [ ! -f .jarvis/state.md ]; then
  echo "# JARVIS State" > .jarvis/state.md
  echo "bootstrap-date: $(date +%Y-%m-%d)" >> .jarvis/state.md
  echo "archetypes: ${ARCHETYPE}${SECONDARY:+ + $SECONDARY}" >> .jarvis/state.md
fi

touch .jarvis/memory.md .jarvis/focus.md .jarvis/timeline.md

# Copy preferences template if not exists
if [ ! -f .jarvis/preferences.md ] && [ -f "${SKILL_PATH}/core/state/preferences.md.template" ]; then
  cp "${SKILL_PATH}/core/state/preferences.md.template" .jarvis/preferences.md
fi

# ─── 2. Create wiki/ (merge, don't overwrite) ─────────────────────
mkdir -p wiki/{Systems,Architecture,Devlog,Canvas}

UNIVERSAL="${SKILL_PATH}/archive/templates/universal"

# Wiki HOME — only if missing
if [ ! -f wiki/HOME.md ]; then
  cp "${UNIVERSAL}/wiki/HOME.md.template" wiki/HOME.md
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
if [ ! -f CLAUDE.md ]; then
  cp "${UNIVERSAL}/CLAUDE.md.base" CLAUDE.md
else
  echo "" >> CLAUDE.md
  echo "# JARVIS-Starter (appended by bootstrap)" >> CLAUDE.md
  echo "" >> CLAUDE.md
  cat "${UNIVERSAL}/CLAUDE.md.base" >> CLAUDE.md
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
sed -i '' "s|{{SKILL_PATH}}|${SKILL_PATH}|g" .claude/hooks/*.sh 2>/dev/null || sed -i "s|{{SKILL_PATH}}|${SKILL_PATH}|g" .claude/hooks/*.sh
sed -i '' "s|{{PROJECT_ROOT}}|$(pwd)|g" .claude/hooks/*.sh 2>/dev/null || sed -i "s|{{PROJECT_ROOT}}|$(pwd)|g" .claude/hooks/*.sh

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
sed -i '' "s|{{PROJECT_ROOT}}|$(pwd)|g" "${SETTINGS_TMPL}" 2>/dev/null || sed -i "s|{{PROJECT_ROOT}}|$(pwd)|g" "${SETTINGS_TMPL}"

if [ ! -f .claude/settings.json ]; then
  # Fresh install — just move the rendered template
  mv "${SETTINGS_TMPL}" .claude/settings.json
  echo "  ✅ .claude/settings.json created with all JARVIS hooks"
else
  # Merge: keep user config, add missing JARVIS hooks
  if command -v jq >/dev/null 2>&1; then
    cp .claude/settings.json .claude/settings.json.pre-jarvis.bak
    echo "  → backup: .claude/settings.json.pre-jarvis.bak"

    # Merge hooks via jq: user hooks stay, JARVIS hooks added if missing
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
    ' .claude/settings.json "${SETTINGS_TMPL}" > .claude/settings.json.new

    if [ -s .claude/settings.json.new ]; then
      mv .claude/settings.json.new .claude/settings.json
      rm -f "${SETTINGS_TMPL}"
      echo "  ✅ .claude/settings.json — JARVIS hooks merged (user config preserved)"
    else
      rm -f .claude/settings.json.new "${SETTINGS_TMPL}"
      echo "  ❌ jq merge failed — settings.json unchanged, backup at .pre-jarvis.bak"
      echo "      Manual merge: template at ${UNIVERSAL}/settings.json"
    fi
  else
    echo "  ⚠️ jq not found — automatic merge not possible"
    echo "      Manual merge: add hooks from ${SETTINGS_TMPL} to .claude/settings.json"
    echo "      (or install jq: brew install jq / apt install jq)"
  fi
fi

# Verification: what actually got installed
HOOKS_COUNT=$(jq -r '[.hooks | to_entries[] | .value[] | .hooks[]?] | length' .claude/settings.json 2>/dev/null || echo "0")
echo "  ℹ️ JARVIS hooks in settings.json: ${HOOKS_COUNT}"

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
