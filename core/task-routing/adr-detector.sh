#!/bin/bash
# JARVIS ADR-detector — UserPromptSubmit hook
# Detects "choice between alternatives" moments in the prompt and reminds about `jarvis decide`.
# By SKILL.md rule #8 — the model MUST run the decide flow before implementation in such cases.
#
# Bilingual: patterns cover both English and Russian prompts. The skill is authored in English
# but its primary user base is Russian-speaking — missing half the ADR moments by language is
# the single most impactful bug we can avoid here.

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null)

if [ -z "$PROMPT" ]; then
  exit 0
fi

if [ ! -d ".jarvis" ]; then
  exit 0
fi

# Disable switch
if [ -f ".jarvis/plugins.md" ] && grep -q "adr-detector: off" ".jarvis/plugins.md"; then
  exit 0
fi

# Anti-spam: don't remind on the same prompt twice a day
HASH=$(echo "$PROMPT" | shasum | cut -c1-12 2>/dev/null || echo "$PROMPT" | md5sum | cut -c1-12 2>/dev/null || echo "$PROMPT" | cksum | awk '{print $1}')
TODAY_FILE=".jarvis/adr-reminded-$(date +%Y%m%d).txt"
if [ -f "$TODAY_FILE" ] && grep -qF "${HASH}" "$TODAY_FILE"; then
  exit 0
fi

# ADR-moment triggers. Conservative — prefer silence to false-positives.
# Each regex is case-insensitive (grep -i) and anchors either on a connective ("vs", "или")
# or on a decision verb ("decide", "should I", "стоит ли", "какой лучше").
PATTERNS=(
  # English — X vs Y
  ' vs\.? [a-zA-Z]'
  # English — use/choose/pick X or Y
  '(use|take|install|choose|pick|select)[^.?]{0,40} or [^.?]{1,40}[a-zA-Z]'
  # English — should I/we use/choose/switch
  'should (i|we).*(use|take|install|choose|pick|switch to)'
  # English — which/what is better / to pick
  '(which|what).{0,30}(to (pick|use|choose)|is better|should i)'
  # English — explicit decision words
  'choice between'
  'decide (on|between)'
  # English — common tech-stack pairs
  'monorepo .*(or|vs) .*polyrepo'
  'rest .*(vs|or) .*(graphql|grpc)'
  '(webhook|polling)[ -]vs[ -](webhook|polling)'
  '(redis|in-memory).*(vs|or).*(db|postgres|sqlite)'
  '(sqlite|postgres(ql)?) .*(vs|or) .*(postgres|sqlite|mysql|redis)'

  # Russian — X против Y
  ' против [a-zA-Zа-яА-Я]'
  # Russian — (использовать/взять/выбрать/поставить/ставить/брать ...) X или Y (flexion-tolerant)
  '(использ|выбр|выбир|взя|возьм|берё|бер[её]м|установ|постав|ставим)[а-я]* [^.?]{0,40} или [^.?]{1,40}[a-zA-Zа-яА-Я]'
  # Russian — стоит ли + decision verb
  'стоит ли .*(использ|взя|установ|выбр|выбир|переключ|переход|брать|постав|мен(ять|ем)|заменять)'
  # Russian — стоит ли X или Y (verb-elided ADR — "стоит ли Recharts или Chart.js")
  'стоит ли [^.?]{1,40} (или|vs) [^.?]{1,40}[a-zA-Zа-яА-Я]'
  # Russian — нужен/нужна/нужно ли X или Y ("нужен ли RLS или auth middleware")
  'нуж(ен|на|но|ны) ли [^.?]{1,40} (или|vs) [^.?]{1,40}[a-zA-Zа-яА-Я]'
  # Russian — какой/какую лучше/выбрать (без "что" чтобы не ловить "что лучше написать")
  '(какой|какую|какое) .*(лучше|выбрать|использовать|взять|подходит)'
  # Russian — "что лучше" только с decision verb или альтернативами (иначе false-positive)
  'что лучше .*(использ|выбр|выбир|взя|возьм|постав|подход| — | или | vs )'
  # Russian — "что выбрать/использовать" (без "лучше")
  'что (выбр|выбир|использ|взя|возьм|постав)[а-я]+'
  # Russian — X или Y (лучше|вместо)
  ' или .*(лучше|вместо|правильнее)'
  # Russian — переехать/мигрировать с X на Y
  '(переехать|переходить|мигрировать|перевести) (с|со|из) .* на '
  # Russian — explicit decision
  'выбор между'
  'принять решение'
  # Russian — common tech-stack pairs (ASCII tech names usable in RU)
  'монолит .*(или|vs) .*микросервис'
  '(redis|sqlite|postgres|mysql) .*(vs|или) [a-z]'
)

MATCHED=0
for p in "${PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qiE "$p"; then
    MATCHED=1
    break
  fi
done

if [ "$MATCHED" -eq 0 ]; then
  exit 0
fi

# Remember hash so we don't spam the same prompt
mkdir -p .jarvis
echo "$HASH" >> "$TODAY_FILE"

# usage-log — for jarvis self-audit
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/../usage-log.sh" adr-detector FIRED "hash=${HASH}" 2>/dev/null || true

cat <<'EOF'

💠 JARVIS: looks like an ADR moment (choice between alternatives).
   Похоже на ADR-момент — выбор между альтернативами.
   Per SKILL.md rule #8: first run `jarvis decide "<question>"`, record the
   result in `wiki/Decisions/` or `wiki/Architecture/`, then implement.
   See `on-demand/decide.md`.
EOF

exit 0
