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

# CLAUDE.md — check for existing model/plan/complexity rules
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

# ─── Stack detection (for stack-matcher in Phase C+F) ─────────────
DETECTED_STACK=""
DETECTED_ARCH=""

# nullglob + dotglob not reliable in bash 3.2 POSIX mode — explicit expansion.
PKG_FILES=""
[ -f package.json ] && PKG_FILES="package.json"
# Static subdirs with trailing slash (earlier bug: `app` without slash yielded `apppackage.json`)
for sub in app/ client/ server/ web/ api/; do
  [ -f "${sub}package.json" ] && PKG_FILES="${PKG_FILES} ${sub}package.json"
done
# Glob patterns for monorepos (apps/*, packages/*) — verify expansion succeeded
for pattern in "apps/"*"/" "packages/"*"/"; do
  [ -d "${pattern}" ] || continue  # glob didn't expand — skip
  [ -f "${pattern}package.json" ] && PKG_FILES="${PKG_FILES} ${pattern}package.json"
done

if [ -n "${PKG_FILES}" ]; then
  STACK_TAGS=$(python3 - ${PKG_FILES} <<'PY' 2>/dev/null
import json, sys
TAG_MAP = {
    "next": "nextjs", "react": "react", "vue": "vue", "svelte": "svelte",
    "@angular/core": "angular", "solid-js": "solid",
    "@remix-run/react": "remix", "nuxt": "nuxt", "@sveltejs/kit": "sveltekit", "astro": "astro",
    "tailwindcss": "tailwind", "styled-components": "styled-components", "@emotion/react": "emotion",
    "express": "express", "@nestjs/core": "nestjs", "fastify": "fastify",
    "prisma": "prisma", "drizzle-orm": "drizzle", "mongodb": "mongodb",
    "pg": "postgres", "mysql2": "mysql", "better-sqlite3": "sqlite",
    "redis": "redis", "ioredis": "redis",
    "@supabase/supabase-js": "supabase",
    "grammy": "grammy", "discord.js": "discord.js", "@slack/bolt": "slack",
    "phaser": "phaser", "three": "three", "@tauri-apps/api": "tauri",
    "expo": "expo", "react-native": "react-native",
    "playwright": "playwright", "puppeteer": "puppeteer",
    "@anthropic-ai/sdk": "anthropic", "openai": "openai", "langchain": "langchain",
    "i18next": "i18next", "next-intl": "next-intl",
    "trpc": "trpc", "@trpc/server": "trpc",
    "zod": "zod",
    "typescript": "typescript",
}
ARCH_MAP = {
    "next": "web-app", "remix": "web-app", "nuxt": "web-app", "@sveltejs/kit": "web-app", "astro": "landing",
    "express": "web-api", "@nestjs/core": "web-api", "fastify": "web-api",
    "grammy": "telegram-bot", "discord.js": "discord-bot", "@slack/bolt": "slack-bot",
    "phaser": "browser-game", "three": "browser-game",
    "expo": "mobile-app", "react-native": "mobile-app",
    "@tauri-apps/api": "desktop", "electron": "desktop",
    "@anthropic-ai/sdk": "llm-agent", "openai": "llm-agent", "langchain": "llm-agent",
}
tags = set()
arch_votes = {}
for path in sys.argv[1:]:
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        continue
    deps = {}
    for k in ("dependencies", "devDependencies"):
        deps.update(data.get(k) or {})
    for dep in deps:
        if dep in TAG_MAP:
            tags.add(TAG_MAP[dep])
        if dep in ARCH_MAP:
            arch_votes[ARCH_MAP[dep]] = arch_votes.get(ARCH_MAP[dep], 0) + 1
print(",".join(sorted(tags)))
if arch_votes:
    arch = sorted(arch_votes.items(), key=lambda x: -x[1])[0][0]
    print(arch)
PY
)
  DETECTED_STACK=$(echo "${STACK_TAGS}" | head -1)
  DETECTED_ARCH=$(echo "${STACK_TAGS}" | sed -n '2p')
fi

if [ -z "${DETECTED_STACK}" ] && ([ -f pyproject.toml ] || [ -f requirements.txt ]); then
  # Bug fix (retest v0.2.1): `set -euo pipefail` + `&& chain` used to die on the
  # first grep that didn't find a dep. Replaced with explicit `if` statements.
  PY_DEPS=$(cat pyproject.toml requirements.txt 2>/dev/null || true)
  PY_TAGS=""
  PY_ARCH=""
  if echo "${PY_DEPS}" | grep -iqE "^[[:space:]]*['\"]?aiogram"; then
    PY_TAGS="${PY_TAGS},aiogram"; PY_ARCH="${PY_ARCH:-telegram-bot}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "python-telegram-bot"; then
    PY_TAGS="${PY_TAGS},python-telegram-bot"; PY_ARCH="${PY_ARCH:-telegram-bot}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "^[[:space:]]*['\"]?fastapi"; then
    PY_TAGS="${PY_TAGS},fastapi"; PY_ARCH="${PY_ARCH:-web-api}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "^[[:space:]]*['\"]?django"; then
    PY_TAGS="${PY_TAGS},django"; PY_ARCH="${PY_ARCH:-web-app}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "^[[:space:]]*['\"]?flask"; then
    PY_TAGS="${PY_TAGS},flask"; PY_ARCH="${PY_ARCH:-web-api}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "scrapy|beautifulsoup4"; then
    PY_TAGS="${PY_TAGS},scraping"; PY_ARCH="${PY_ARCH:-parser}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "^[[:space:]]*['\"]?anthropic"; then
    PY_TAGS="${PY_TAGS},anthropic"; PY_ARCH="${PY_ARCH:-llm-agent}"
  fi
  if echo "${PY_DEPS}" | grep -iqE "langchain"; then
    PY_TAGS="${PY_TAGS},langchain"
  fi
  PY_TAGS="${PY_TAGS},python"
  DETECTED_STACK=$(echo "${PY_TAGS}" | sed 's/^,//' | tr ',' '\n' | sort -u | paste -sd ',' -)
  DETECTED_ARCH="${PY_ARCH}"
fi

echo "   ┌─ Detected stack/archetype:"
if [ -n "${DETECTED_ARCH}" ] || [ -n "${DETECTED_STACK}" ]; then
  [ -n "${DETECTED_ARCH}" ] && echo "   │  • archetype: ${DETECTED_ARCH}"
  [ -n "${DETECTED_STACK}" ] && echo "   │  • stack: ${DETECTED_STACK}"
else
  echo "   │  • stack: not detected (no package.json / pyproject.toml / requirements.txt)"
  echo "   │    Skill-matcher and archetype-overlay sections will be hidden."
fi
echo "   └─"
echo ""

# ─── Phase B — Gap analysis ───────────────────────────────────────
echo "💠 Phase B: gap analysis"
echo ""

FEATURES_TO_INSTALL=()
FEATURES_SKIPPED=()
SKIP_REASONS=()

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
echo "💠 Phase C: proposal"
echo ""
echo "   ┌─ Will install:"
HAS_ANY_INSTALL=0
for f in "${FEATURES_TO_INSTALL[@]:-}"; do
  [ -z "${f}" ] && continue
  echo "   │  ✓ ${f}"
  HAS_ANY_INSTALL=1
done
[ "${HAS_ANY_INSTALL}" = "0" ] && echo "   │  (none — use --enable <feature> to install)"
echo "   ├─ Will skip:"
HAS_ANY_SKIP=0
for f in "${FEATURES_SKIPPED[@]:-}"; do
  [ -z "${f}" ] && continue
  echo "   │  × ${f}  — $(skip_reason_for "${f}")"
  HAS_ANY_SKIP=1
done
[ "${HAS_ANY_SKIP}" = "0" ] && echo "   │  (none — all gap checks passed)"
echo "   └─"
echo ""

# Archetype overlay opt-in (only if detected)
if [ -n "${DETECTED_ARCH}" ] && [ "${DETECTED_ARCH}" != "unknown" ]; then
  ARCH_DIR="${SKILL_PATH}/archive/archetypes/tier1/${DETECTED_ARCH}"
  if [ -d "${ARCH_DIR}" ]; then
    if echo ",${ENABLE}," | grep -q ",archetype-overlay,"; then
      APPLY_ARCHETYPE=1
      echo "   ┌─ Archetype overlay (--enable archetype-overlay):"
      echo "   │  ✓ ${DETECTED_ARCH}-overlay will be applied (archetype-specific addon to CLAUDE.md + extra commands)"
      echo "   └─"
      echo ""
    else
      echo "   ┌─ Available but NOT applied (opt-in):"
      echo "   │  ☐ archetype-overlay (${DETECTED_ARCH}) — adds CLAUDE.md addon + commands"
      echo "   │     To apply: jarvis evolve ${DETECTED_ARCH}  (or --enable archetype-overlay on adopt)"
      echo "   └─"
      echo ""
    fi
  fi
fi

# Stack-match — proactive from registry (cheap, no GitHub)
if [ -n "${DETECTED_ARCH}" ] && [ "${DETECTED_ARCH}" != "unknown" ]; then
  echo "   ┌─ Recommended skills from registry (stack-match):"
  STACK_RESULTS=$(bash "${SKILL_PATH}/core/skill-discovery/stack-matcher.sh" \
      --archetype "${DETECTED_ARCH}" \
      --stack "${DETECTED_STACK}" \
      --top 5 2>/dev/null | grep -v "^$" | grep -vE "^💠|^Install via")
  if [ -n "${STACK_RESULTS}" ]; then
    echo "${STACK_RESULTS}" | sed 's/^/   │  /'
  else
    echo "   │  (no matches in registry for this archetype)"
  fi
  echo "   │"
  echo "   │  → \`jarvis find <need>\` to search externally, \`jarvis self-audit\` for inventory"
  echo "   └─"
  echo ""
fi

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
archetype-detected: ${DETECTED_ARCH:-unknown}
archetype-applied: none
stack: ${DETECTED_STACK:-unknown}
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

# Defensive: if .claude/hooks/jarvis-*.sh files exist from prior adopts
# but aren't in FEATURES_TO_INSTALL (e.g. user runs `adopt --enable
# archetype-overlay` after a full install) — implicitly re-register them
# so the settings.json merge stays additive.
ALREADY_ON_DISK=""
if [ -d .claude/hooks ]; then
  for existing in .claude/hooks/jarvis-*.sh; do
    [ ! -f "${existing}" ] && continue
    existing_name=$(basename "${existing}" .sh | sed 's/^jarvis-//')
    in_list=0
    for f in "${FEATURES_TO_INSTALL[@]:-}"; do
      [ "${f}" = "${existing_name}" ] && in_list=1 && break
    done
    [ "${in_list}" = "0" ] && ALREADY_ON_DISK="${ALREADY_ON_DISK} ${existing_name}"
  done
fi

install_hooks_registration() {
  local tmpfile="${PROJECT_ROOT}/.claude/settings.json.jarvis-adopt.tmp"
  local all_features="${FEATURES_TO_INSTALL[*]:-} ${ALREADY_ON_DISK}"

  python3 - "${PROJECT_ROOT}" "${all_features}" > "${tmpfile}" <<'PY'
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

# ─── Phase D.5 — Archetype overlay (opt-in) ────────────────────────
APPLY_ARCHETYPE=${APPLY_ARCHETYPE:-0}
if [ "${APPLY_ARCHETYPE}" = "1" ] && [ -n "${DETECTED_ARCH}" ]; then
  ARCH_DIR="${SKILL_PATH}/archive/archetypes/tier1/${DETECTED_ARCH}"
  if [ -d "${ARCH_DIR}" ]; then
    if [ -f "${ARCH_DIR}/CLAUDE.md.addon" ] && [ -f CLAUDE.md ]; then
      ARCH_MARKER="<!-- jarvis-archetype-overlay: ${DETECTED_ARCH} -->"
      if ! grep -qF "${ARCH_MARKER}" CLAUDE.md; then
        {
          echo ""
          echo "${ARCH_MARKER}"
          cat "${ARCH_DIR}/CLAUDE.md.addon"
        } >> CLAUDE.md
        echo "   ✓ archetype overlay (${DETECTED_ARCH}) — CLAUDE.md.addon appended"
      fi
    fi
    if [ -d "${ARCH_DIR}/commands" ]; then
      mkdir -p .claude/commands
      for cmd_file in "${ARCH_DIR}/commands/"*.md; do
        [ ! -e "$cmd_file" ] && continue
        cmd_name=$(basename "$cmd_file")
        [ -f ".claude/commands/${cmd_name}" ] && continue
        cp "$cmd_file" ".claude/commands/${cmd_name}"
        echo "   ✓ archetype command: .claude/commands/${cmd_name}"
      done
    fi
    if [ -f "${ARCH_DIR}/hooks-addon.sh" ]; then
      ADDON_PATH="${ARCH_DIR}/hooks-addon.sh"
      for HOOK in jarvis-wiki-maintenance.sh jarvis-focus-tracker.sh jarvis-security-watch.sh; do
        [ ! -f ".claude/hooks/${HOOK}" ] && continue
        if ! grep -qF "${ADDON_PATH}" ".claude/hooks/${HOOK}"; then
          sed -i '' "/^exit 0$/i\\
\\
# Archetype trigger (${DETECTED_ARCH})\\
bash \"${ADDON_PATH}\" <<< \"\$INPUT\"\\
" ".claude/hooks/${HOOK}" 2>/dev/null || \
            sed -i "/^exit 0$/i\\
\\
# Archetype trigger (${DETECTED_ARCH})\\
bash \"${ADDON_PATH}\" <<< \"\$INPUT\"\\
" ".claude/hooks/${HOOK}"
        fi
      done
      echo "   ✓ archetype hook-addon (${DETECTED_ARCH}) wired into existing hooks"
    fi
    sed -i '' "s|^archetype-applied:.*|archetype-applied: ${DETECTED_ARCH}|" .jarvis/state.md 2>/dev/null || \
      sed -i "s|^archetype-applied:.*|archetype-applied: ${DETECTED_ARCH}|" .jarvis/state.md
  fi
fi

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

# ─── Phase F — Post-install digest ────────────────────────────────
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  💠 JARVIS ready. Things to try next:                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "On-demand commands (call explicitly):"
[ -d "${SKILL_PATH}/on-demand" ] && for CMD_FILE in "${SKILL_PATH}/on-demand/"*.md; do
  [ ! -e "${CMD_FILE}" ] && continue
  CMD=$(basename "${CMD_FILE}" .md)
  echo "  • jarvis ${CMD}"
done
echo ""

if [ -n "${DETECTED_ARCH}" ] && [ "${DETECTED_ARCH}" != "unknown" ] && [ "${APPLY_ARCHETYPE}" != "1" ]; then
  echo "📦 Archetype overlay for ${DETECTED_ARCH} is available but NOT applied."
  echo "   Apply: jarvis evolve ${DETECTED_ARCH}  (or re-run adopt with --enable archetype-overlay)"
  echo ""
fi

echo "🔍 Further discovery (optional, may cost tokens):"
echo "  • jarvis self-audit       — what from JARVIS actually fires"
echo "  • jarvis find <need>      — search for an external skill"
echo "  • jarvis suggest          — improvement ideas for the project"
echo ""

echo "⚠️  Claude Code quirk: the permission system may strip settings.json hooks mid-session."
echo "   Recommendation: restart your Claude Code session OR run the installer from a shell outside Claude Code."
