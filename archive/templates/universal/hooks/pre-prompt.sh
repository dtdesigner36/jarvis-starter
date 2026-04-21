#!/bin/bash
# Pre-prompt hook (UserPromptSubmit) — JARVIS task-routing + memory-recall

INPUT=$(cat)

# Task routing — prompt classification, model/plan advice
bash "{{SKILL_PATH}}/core/task-routing/prompt-analyzer.sh" <<< "$INPUT"

# Memory recall — surface existing solutions
bash "{{SKILL_PATH}}/core/memory-recall/topic-matcher.sh" <<< "$INPUT"

exit 0
