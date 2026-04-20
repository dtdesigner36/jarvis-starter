#!/bin/bash
# Post-Edit/Write hook — runs JARVIS core + archetype-specific triggers

# JARVIS wiki-maintenance (always)
bash {{SKILL_PATH}}/core/wiki-maintenance/hook-detector.sh <<< "$(cat)"

# JARVIS focus-tracker (always, passive, 0 tokens)
bash {{SKILL_PATH}}/core/focus-tracker/focus-updater.sh <<< "$(cat)"

# JARVIS security-watch (always)
bash {{SKILL_PATH}}/core/security-watch/secret-scanner.sh <<< "$(cat)"
bash {{SKILL_PATH}}/core/security-watch/gitignore-check.sh <<< "$(cat)"

# Archetype-specific triggers (populated at bootstrap)
{{ARCHETYPE_POST_EDIT_TRIGGERS}}

exit 0
