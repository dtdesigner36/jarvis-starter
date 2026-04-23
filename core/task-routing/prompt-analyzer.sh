#!/bin/bash
# JARVIS task-routing hook
# UserPromptSubmit hook — analyzes prompt, classifies, recommends model + mode
# Honors .jarvis/preferences.md (model-strategy: single/smart/auto-smart)

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null)

if [ -z "$PROMPT" ]; then
  exit 0
fi

if [ ! -d ".jarvis" ]; then
  exit 0
fi

# Check disabled
if [ -f ".jarvis/plugins.md" ] && grep -q "task-routing: off" ".jarvis/plugins.md"; then
  exit 0
fi

# Portable file mtime — BSD (macOS) first, GNU (Linux) fallback
_mtime() { stat -f "%m" "$1" 2>/dev/null || stat -c "%Y" "$1" 2>/dev/null || echo 0; }

# ─── Read preferences ─────────────────────────────────────────────
STRATEGY="single"
LONG_TASK_THRESHOLD=60

if [ -f ".jarvis/preferences.md" ]; then
  PREF_STRATEGY=$(grep -E "^model-strategy:\s*" ".jarvis/preferences.md" 2>/dev/null | head -1 | sed 's/.*:\s*//' | tr -d ' ')
  if [ -n "$PREF_STRATEGY" ]; then
    STRATEGY="$PREF_STRATEGY"
  fi

  PREF_THRESHOLD=$(grep -E "^long-task-threshold:" ".jarvis/preferences.md" 2>/dev/null | head -1 | sed 's/.*:\s*//' | sed 's/\s*#.*//' | tr -d ' ')
  if [ -n "$PREF_THRESHOLD" ] && [ "$PREF_THRESHOLD" -gt 0 ] 2>/dev/null; then
    LONG_TASK_THRESHOLD="$PREF_THRESHOLD"
  fi
fi

# ─── Detect current mode (best-effort) ────────────────────────────
MODE="unknown"

PAYLOAD_MODE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session',{}).get('mode','') or d.get('mode',''))" 2>/dev/null)
if [ -n "$PAYLOAD_MODE" ]; then
  MODE="$PAYLOAD_MODE"
fi

if [ "$MODE" = "unknown" ] && [ -f ".claude/settings.json" ]; then
  SETTINGS_MODE=$(python3 -c "import json; d=json.load(open('.claude/settings.json')); print(d.get('permissions',{}).get('defaultMode',''))" 2>/dev/null)
  if [ -n "$SETTINGS_MODE" ]; then
    MODE="$SETTINGS_MODE"
  fi
fi

if [ -f ".claude/settings.local.json" ]; then
  LOCAL_MODE=$(python3 -c "import json; d=json.load(open('.claude/settings.local.json')); print(d.get('permissions',{}).get('defaultMode',''))" 2>/dev/null)
  if [ -n "$LOCAL_MODE" ]; then
    MODE="$LOCAL_MODE"
  fi
fi

# ─── Classification ───────────────────────────────────────────────
PROMPT_LEN=${#PROMPT}
CLASS="Trivial"

if [ "$PROMPT_LEN" -gt 50 ]; then
  CLASS="Simple"
fi

if [ "$PROMPT_LEN" -gt 150 ]; then
  CLASS="Medium"
fi

# Bilingual (RU + EN) — classification must be prompt-language invariant
ARCH_KEYWORDS="новая систем|новую систему|новая фича|новую фичу|добавь систему|реализуй полностью|сделай полностью|перепиши|миграц|архитектур|с нуля|new system|new feature|add system|implement fully|build fully|rewrite|refactor|migration|architecture|from scratch"
if echo "$PROMPT" | grep -qiE "$ARCH_KEYWORDS"; then
  if [ "$PROMPT_LEN" -gt 100 ]; then
    CLASS="Complex"
  else
    CLASS="Medium"
  fi
fi

if echo "$PROMPT" | grep -qiE "реализуй все|создай проект|разработай систему|полная реализация|end-to-end|e2e|implement everything|create project|build a system|full implementation"; then
  CLASS="Complex"
fi

if echo "$PROMPT" | grep -qiE "рефакторинг|смена стека|миграция на|переписать архитектуру|refactoring|stack change|migration to|rewrite architecture"; then
  CLASS="Architectural"
fi

# Estimate task "size" (approx minutes) — for smart strategy
ESTIMATE_MIN=15
if [ "$CLASS" = "Medium" ]; then ESTIMATE_MIN=30; fi
if [ "$CLASS" = "Complex" ]; then ESTIMATE_MIN=90; fi
if [ "$CLASS" = "Architectural" ]; then ESTIMATE_MIN=180; fi

# ─── Determine plan_model and impl_model based on strategy ────────
PLAN_MODEL=""
IMPL_MODEL=""
REVIEW_MODEL=""

case "$CLASS" in
  "Trivial")
    PLAN_MODEL="Haiku"; IMPL_MODEL="Haiku"
    ;;
  "Simple")
    PLAN_MODEL="Sonnet"; IMPL_MODEL="Sonnet"
    ;;
  "Medium")
    PLAN_MODEL="Sonnet"; IMPL_MODEL="Sonnet"
    ;;
  "Complex")
    case "$STRATEGY" in
      "single")
        PLAN_MODEL="Opus"; IMPL_MODEL="Opus"
        ;;
      "smart")
        PLAN_MODEL="Opus"
        if [ "$ESTIMATE_MIN" -gt "$LONG_TASK_THRESHOLD" ]; then
          IMPL_MODEL="Sonnet"
        else
          IMPL_MODEL="Opus"
        fi
        ;;
      "auto-smart")
        PLAN_MODEL="Opus"; IMPL_MODEL="Sonnet"
        ;;
    esac
    ;;
  "Architectural")
    case "$STRATEGY" in
      "single")
        PLAN_MODEL="Opus"; IMPL_MODEL="Opus"
        ;;
      "smart")
        PLAN_MODEL="Opus"
        if [ "$ESTIMATE_MIN" -gt "$LONG_TASK_THRESHOLD" ]; then
          IMPL_MODEL="Sonnet"; REVIEW_MODEL="Opus"
        else
          IMPL_MODEL="Opus"
        fi
        ;;
      "auto-smart")
        PLAN_MODEL="Opus"; IMPL_MODEL="Sonnet"; REVIEW_MODEL="Opus"
        ;;
    esac
    ;;
esac

# ─── Surface `jarvis find` on search-like prompts (before the trivial exit) ──
# Anti-spam: once every 5 days.
if echo "$PROMPT" | grep -qiE "(как (реализ|сделать|настроить)|library for|какая библиотека|чем сделать|инструмент для|какой инструмент|how to (implement|set up)|what library)"; then
  LAST_FIND_HINT=".jarvis/last-find-hint"
  NOW_TS=$(date +%s)
  LAST_TS=$(_mtime "${LAST_FIND_HINT}")
  if [ $(( (NOW_TS - LAST_TS) / 86400 )) -gt 5 ]; then
    echo ""
    echo "💡 JARVIS: looks like you're searching for a solution. Try \`jarvis find <need>\` to search the registry / GitHub."
    touch "${LAST_FIND_HINT}"
  fi
fi

# ─── Trivial/Simple — silent (except plan→auto hint) ─────────────
case "$CLASS" in
  "Trivial"|"Simple")
    if [ "$MODE" = "plan" ] && [ "$PROMPT_LEN" -lt 80 ]; then
      TODAY=$(date +%Y%m%d)
      if [ ! -f ".jarvis/auto-mode-hint-$TODAY" ]; then
        echo "💠 JARVIS: simple task in plan mode — if this happens often, auto mode is faster. ⌥+\ to switch."
        touch ".jarvis/auto-mode-hint-$TODAY"
      fi
    fi
    exit 0
    ;;
esac

# Check anti-spam
if [ -f ".jarvis/memory.md" ] && grep -q "ignore-routing-${CLASS}" ".jarvis/memory.md"; then
  exit 0
fi

# ─── Helpers ──────────────────────────────────────────────────────
is_auto_mode() {
  case "$MODE" in
    "auto"|"acceptAll"|"bypassPermissions") return 0 ;;
    *) return 1 ;;
  esac
}

# ─── Generate advice ──────────────────────────────────────────────

if [ "$PLAN_MODEL" = "$IMPL_MODEL" ] && [ -z "$REVIEW_MODEL" ]; then
  # Same model throughout
  if is_auto_mode; then
    case "$CLASS" in
      "Medium")
        cat << EOF

💠 JARVIS: Medium task, you're in auto mode.
  Recommend: $PLAN_MODEL for the whole task + plan mode (⌥+p).
  Without a plan — risk of rework.
EOF
        ;;
      "Complex"|"Architectural")
        cat << EOF

💠 JARVIS: $CLASS task in auto mode — risky.
  Recommend: $PLAN_MODEL + plan mode (⌥+p).
  Plan mode is MANDATORY for this kind of task — protects against wrong decisions.
EOF
        ;;
    esac
  else
    case "$CLASS" in
      "Medium")
        cat << EOF

💠 JARVIS: Medium task (multiple files).
  Model: $PLAN_MODEL for the whole task. Plan mode recommended (⌥+p).
EOF
        ;;
      "Complex")
        cat << EOF

💠 JARVIS: Complex task.
  Model: $PLAN_MODEL for the whole task (single strategy).
  Plan mode mandatory (⌥+p) — break into stages.
EOF
        ;;
      "Architectural")
        cat << EOF

💠 JARVIS: Architectural task.
  Model: $PLAN_MODEL for the whole task.
  Plan mode mandatory + several confirmation checkpoints.
EOF
        ;;
    esac
  fi
else
  # Split models — need switching
  if [ -n "$REVIEW_MODEL" ]; then
    # 3-split (Architectural with auto-smart)
    cat << EOF

💠 JARVIS: $CLASS task — smart strategy with 3-split:
  1. $PLAN_MODEL for the plan (current) — /model $(echo "$PLAN_MODEL" | tr A-Z a-z)
  2. After the plan: /model $(echo "$IMPL_MODEL" | tr A-Z a-z) → implementation (cheaper)
  3. Final review: /model $(echo "$REVIEW_MODEL" | tr A-Z a-z)

  Plan mode mandatory (⌥+p). Press now.
EOF
  else
    # 2-split (Complex with smart/auto-smart)
    cat << EOF

💠 JARVIS: $CLASS task — smart strategy proposes a split:
  1. $PLAN_MODEL for the plan (current)
  2. After the plan: /model $(echo "$IMPL_MODEL" | tr A-Z a-z) → implementation (saves 5-10x)

  Plan mode (⌥+p) → approve the plan → switch model → implement.
EOF
  fi

  if is_auto_mode; then
    echo ""
    echo "  ⚠️ You're in auto mode. Switch to plan mode — it protects against premature implementation."
  fi
fi

# usage-log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/../usage-log.sh" task-routing FIRED "class=${CLASS}" 2>/dev/null || true

exit 0
