#!/bin/bash
# Pre-prompt hook (UserPromptSubmit) — JARVIS task-routing + memory-recall

# Task routing — prompt classification, model/plan advice
bash {{SKILL_PATH}}/core/task-routing/prompt-analyzer.sh <<< "$(cat)"

# Memory recall — surface existing solutions
bash {{SKILL_PATH}}/core/memory-recall/topic-matcher.sh <<< "$(cat)"

exit 0
