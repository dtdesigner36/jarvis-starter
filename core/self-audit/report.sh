#!/bin/bash
# JARVIS self-audit — shows what from JARVIS actually fires, what stays silent,
# which on-demand commands haven't been tried, and which archetype overlays are available.

set -e

PROJECT_ROOT="$(pwd)"

if [ ! -d .jarvis ]; then
  echo "❌ Not a JARVIS project (no .jarvis/). Run jarvis start or jarvis adopt."
  exit 1
fi

SKILL_PATH="${1:-}"
if [ -z "${SKILL_PATH}" ]; then
  SKILL_PATH=$(grep -E '^skill-path:' .jarvis/state.md 2>/dev/null | sed 's/^skill-path:[[:space:]]*//' | head -1)
fi

# Helper: count matching lines clean (no trailing whitespace)
count_log() {
  local pattern="$1"
  if [ -f .jarvis/usage-log.md ]; then
    grep -c "${pattern}" .jarvis/usage-log.md 2>/dev/null | head -1 | tr -d '[:space:]' || echo 0
  else
    echo 0
  fi
}

echo "💠 JARVIS Self-Audit"
echo ""

# ─── Hook health (v0.2.4) ────────────────────────────────────────
# IDE layers (VSCode Claude Code extension) have a known quirk: they rewrite
# .claude/settings.json on permission-grants and drop the .hooks block. If
# that happens after bootstrap, every hook-backed feature goes silent and the
# user has no signal. Surface it up-front so self-audit is an honest health check.
if command -v jq >/dev/null 2>&1 && [ -f .claude/settings.json ]; then
  PT_COUNT=$(jq -r '(.hooks.PostToolUse // []) | length' .claude/settings.json 2>/dev/null || echo 0)
  UP_COUNT=$(jq -r '(.hooks.UserPromptSubmit // []) | length' .claude/settings.json 2>/dev/null || echo 0)
  if [ "${PT_COUNT}" -lt 1 ] || [ "${UP_COUNT}" -lt 1 ]; then
    echo "❌ Hook health: DEGRADED"
    echo "   .claude/settings.json has PostToolUse=${PT_COUNT}, UserPromptSubmit=${UP_COUNT}"
    echo "   (expected ≥1 each). Hook-backed features are silent."
    echo ""
    echo "   Likely cause: the IDE (Claude Code / VSCode extension) rewrote"
    echo "   settings.json on a permission-grant and dropped the .hooks block."
    echo ""
    echo "   Recovery:"
    if [ -f .claude/settings.json.pre-jarvis.bak ]; then
      echo "     cp .claude/settings.json.pre-jarvis.bak .claude/settings.json   # restore backup"
      echo "     bash \"${SKILL_PATH}/scripts/bootstrap.sh\" <archetype>            # or re-bootstrap from an external shell"
    else
      echo "     bash \"${SKILL_PATH}/scripts/bootstrap.sh\" <archetype>            # re-run bootstrap from an external shell"
    fi
    echo ""
  else
    echo "✅ Hook health: PostToolUse=${PT_COUNT}, UserPromptSubmit=${UP_COUNT} (installed)"
    echo ""
  fi
fi

# ─── Hooks activity ──────────────────────────────────────────────
echo "Hooks (core):"

HOOKS="adr-detector task-routing memory-recall wiki-maintenance focus-tracker security-watch"
for H in $HOOKS; do
  COUNT=$(count_log "^[0-9T:Z-]* ${H} ")
  LAST=""
  if [ -f .jarvis/usage-log.md ] && [ "${COUNT}" -gt 0 ]; then
    LAST=$(grep "^[0-9T:Z-]* ${H} " .jarvis/usage-log.md 2>/dev/null | tail -1 | awk '{print $1}')
  fi

  HOOK_FILE=".claude/hooks/jarvis-${H}.sh"
  if [ ! -f "${HOOK_FILE}" ] && [ ! -f ".claude/hooks/post-edit.sh" ] && [ ! -f ".claude/hooks/pre-prompt.sh" ]; then
    INSTALLED="not installed"
  else
    INSTALLED="installed"
  fi

  if [ "${INSTALLED}" = "not installed" ]; then
    SYM="—"
  elif [ "${COUNT}" -gt 0 ]; then
    SYM="✓"
  else
    SYM="×"
  fi

  if [ -n "${LAST}" ]; then
    echo "  ${SYM} ${H}: ${COUNT}x fired (last: ${LAST})"
  else
    echo "  ${SYM} ${H}: ${COUNT}x (${INSTALLED})"
  fi
done
echo ""

# ─── On-demand commands ───────────────────────────────────────────
echo "On-demand commands:"
if [ -n "${SKILL_PATH}" ] && [ -d "${SKILL_PATH}/on-demand" ]; then
  for CMD_FILE in "${SKILL_PATH}/on-demand/"*.md; do
    [ ! -e "${CMD_FILE}" ] && continue
    CMD=$(basename "${CMD_FILE}" .md)
    echo "  ? jarvis ${CMD}  — try: \`jarvis ${CMD}\`"
  done
  [ -d "${SKILL_PATH}/on-demand/skill-discovery" ] && echo "  ? jarvis find  — search for a skill"
else
  echo "  (skill path unknown — pass as arg: bash report.sh /path/to/skill)"
fi
echo ""

# ─── Archetype overlays ──────────────────────────────────────────
echo "Archetype overlays:"
MODE=$(grep -E '^mode:' .jarvis/state.md 2>/dev/null | sed 's/^mode:[[:space:]]*//' | head -1)
ARCH_DETECTED=$(grep -E '^archetype-detected:' .jarvis/state.md 2>/dev/null | sed 's/^archetype-detected:[[:space:]]*//' | head -1)
ARCH_APPLIED=$(grep -E '^archetype-applied:' .jarvis/state.md 2>/dev/null | sed 's/^archetype-applied:[[:space:]]*//' | head -1)

echo "  mode: ${MODE:-unknown}"
echo "  detected: ${ARCH_DETECTED:-unknown}"
echo "  applied: ${ARCH_APPLIED:-none}"
if [ "${MODE}" = "adopt" ] && [ "${ARCH_APPLIED}" = "none" ]; then
  CLEAN_ARCH=$(echo "${ARCH_DETECTED}" | grep -oE '^[a-z-]+' | head -1)
  if [ -n "${CLEAN_ARCH}" ]; then
    echo "  💡 tip: \`jarvis evolve ${CLEAN_ARCH}\` will apply the overlay"
  fi
fi
echo ""

# ─── Recommendations ──────────────────────────────────────────────
echo "Recommendations:"

if [ -f .jarvis/usage-log.md ]; then
  ADR_COUNT=$(count_log "^[0-9T:Z-]* adr-detector FIRED")
  WM_FIRED=$(count_log "^[0-9T:Z-]* wiki-maintenance FIRED")
  WM_CHECKED=$(count_log "^[0-9T:Z-]* wiki-maintenance CHECKED")
  MR_HIT=$(count_log "^[0-9T:Z-]* memory-recall HIT")
  MR_NO=$(count_log "^[0-9T:Z-]* memory-recall NO-MATCH")

  HINTS=0
  if [ "${ADR_COUNT:-0}" -gt 2 ]; then
    echo "  • adr-detector fired ${ADR_COUNT}x — you probably skipped \`jarvis decide\`. Try it on the next fork."
    HINTS=$((HINTS+1))
  fi
  if [ "${WM_CHECKED:-0}" -gt 10 ] && [ "${WM_FIRED:-0}" -eq 0 ]; then
    echo "  • wiki-maintenance checked ${WM_CHECKED}x but never fired — patterns may not match. Try \`jarvis docs\` manually."
    HINTS=$((HINTS+1))
  fi
  if [ "${MR_NO:-0}" -gt 5 ] && [ "${MR_HIT:-0}" -eq 0 ]; then
    echo "  • memory-recall checked ${MR_NO}x, hit=0. .jarvis/memory.md may be empty or stale."
    HINTS=$((HINTS+1))
  fi
  if [ "${HINTS}" -eq 0 ]; then
    echo "  (all normal — hooks firing, no patterns warrant a recommendation)"
  fi
else
  echo "  • usage-log is empty — no hook has fired yet. Verify install: jq '.hooks' .claude/settings.json"
fi

echo ""
echo "Full log: tail -50 .jarvis/usage-log.md"
