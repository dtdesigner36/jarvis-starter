#!/bin/bash
# Pre-prompt hook (UserPromptSubmit) — JARVIS task-routing + memory-recall + ADR-detector

INPUT=$(cat)

# ADR-detector — catches "choice between alternatives" prompts and reminds about jarvis decide
bash "{{SKILL_PATH}}/core/task-routing/adr-detector.sh" <<< "$INPUT"

# Task routing — prompt classification, model/plan advice
bash "{{SKILL_PATH}}/core/task-routing/prompt-analyzer.sh" <<< "$INPUT"

# Memory recall — surface existing solutions
bash "{{SKILL_PATH}}/core/memory-recall/topic-matcher.sh" <<< "$INPUT"

exit 0
