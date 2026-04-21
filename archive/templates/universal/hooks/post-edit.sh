#!/bin/bash
# Post-Edit/Write hook — JARVIS core + archetype triggers

INPUT=$(cat)

# JARVIS wiki-maintenance (always on)
bash "{{SKILL_PATH}}/core/wiki-maintenance/hook-detector.sh" <<< "$INPUT"

# JARVIS focus-tracker (always on, passive, 0 tokens)
bash "{{SKILL_PATH}}/core/focus-tracker/focus-updater.sh" <<< "$INPUT"

# JARVIS security-watch (always on)
bash "{{SKILL_PATH}}/core/security-watch/secret-scanner.sh" <<< "$INPUT"
bash "{{SKILL_PATH}}/core/security-watch/gitignore-check.sh" <<< "$INPUT"

# Archetype-specific triggers (substituted by bootstrap.sh)
{{ARCHETYPE_POST_EDIT_TRIGGERS}}

exit 0
