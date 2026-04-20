#!/bin/bash
# JARVIS memory-recall hook
# UserPromptSubmit — matches prompt topic against .jarvis/memory.md and wiki/Systems/*.md TL;DR
# Injects an "already solved: ..." hint to avoid reinvention

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null)

if [ -z "$PROMPT" ] || [ ! -d ".jarvis" ]; then
  exit 0
fi

# Check disabled
if [ -f ".jarvis/plugins.md" ] && grep -q "memory-recall: off" ".jarvis/plugins.md"; then
  exit 0
fi

# Minimum length — don't trigger on tiny edits
if [ ${#PROMPT} -lt 30 ]; then
  exit 0
fi

# Normalize prompt: lowercase, strip punctuation
PROMPT_NORM=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | tr -d ',.!?;:')

# ─── Search .jarvis/memory.md ─────────────────────────────────────
MEMORY_HITS=""
if [ -f ".jarvis/memory.md" ]; then
  # Extract keywords with length 4+ from prompt
  KEYWORDS=$(echo "$PROMPT_NORM" | tr ' ' '\n' | awk 'length($0) > 3' | sort -u)

  for KW in $KEYWORDS; do
    # Skip common words
    if echo "$KW" | grep -qE "^(will|would|might|need|needs|want|make|do|this|that|these|those|just|also|only|now|when|after|before|from|into|with|some|more|most|over|like|such|than|then|been|were|have|what|your|our)$"; then
      continue
    fi

    # Search memory.md
    MATCH=$(grep -i "\b${KW}\b" .jarvis/memory.md 2>/dev/null | head -1)
    if [ -n "$MATCH" ]; then
      MEMORY_HITS="$MEMORY_HITS\n  • $MATCH"
    fi
  done
fi

# ─── Search wiki/Systems/*.md by system name ──────────────────────
WIKI_HITS=""
if [ -d "wiki/Systems" ]; then
  KEYWORDS=$(echo "$PROMPT_NORM" | tr ' ' '\n' | awk 'length($0) > 4' | sort -u)

  for SYSFILE in wiki/Systems/*.md; do
    [ ! -f "$SYSFILE" ] && continue
    SYSNAME=$(basename "$SYSFILE" .md)

    for KW in $KEYWORDS; do
      if echo "$KW" | grep -qE "^(will|would|make|need|with|from|into|your|some)$"; then
        continue
      fi

      # Match by system name (authorization → auth, users → user)
      if echo "$SYSNAME" | grep -qi "${KW:0:4}"; then
        WIKI_HITS="$WIKI_HITS\n  • [[wiki/Systems/${SYSNAME}.md]] — already documented"
        break
      fi
    done
  done
fi

# ─── Output if hits exist ─────────────────────────────────────────
if [ -n "$MEMORY_HITS" ] || [ -n "$WIKI_HITS" ]; then
  echo "💠 JARVIS: found that you've already solved something similar:"

  if [ -n "$WIKI_HITS" ]; then
    echo -e "$WIKI_HITS" | head -3
  fi

  if [ -n "$MEMORY_HITS" ]; then
    echo -e "$MEMORY_HITS" | head -2
  fi

  echo "  (don't reinvent — use what exists)"
fi

exit 0
