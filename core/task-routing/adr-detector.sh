#!/bin/bash
# JARVIS ADR-detector — UserPromptSubmit hook
# Detects "choice between alternatives" moments in the prompt and reminds about `jarvis decide`.
# By SKILL.md rule #8 — the model MUST run the decide flow before implementation in such cases.

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

# ADR-moment triggers (conservative — prefer silence to false-positives):
#   1. "X vs Y" between tech names
#   2. "use X or Y" / "choose between X and Y"
#   3. "should I" + a choice verb
#   4. Explicit decision words: "which to pick", "decide between"
PATTERNS=(
  ' vs\.? [a-zA-Z]'
  '(use|take|install|choose|pick|select)[^.?]{0,40}(or)[^.?]{1,40}[a-zA-Z]'
  'should (i|we).*(use|take|install|choose|pick|switch to)'
  '(which|what).{0,30}(to (pick|use|choose)|is better|should i)'
  'choice between'
  'decide (on|between)'
  'monorepo .*(or|vs) .*polyrepo'
  'rest .*(vs|or) .*(graphql|grpc)'
  '(webhook|polling)[ -]vs[ -](webhook|polling)'
  '(redis|in-memory).*(vs|or).*(db|postgres|sqlite)'
  '(sqlite|postgres(ql)?) .*(vs|or) .*(postgres|sqlite|mysql|redis)'
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

cat <<'EOF'

💠 JARVIS: looks like an ADR moment (choice between alternatives).
   Per SKILL.md rule #8 — first run `jarvis decide "<question>"`,
   record the result in `wiki/Decisions/` or `wiki/Architecture/`, and
   only then start implementation. See `on-demand/decide.md`.
EOF

exit 0
