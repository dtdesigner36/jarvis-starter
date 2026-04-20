# Tier 2: slack-bot

**Stack:** Node + @slack/bolt, or Python + slack-bolt
**Key files:** listeners/, commands/, events.ts
**Skills:** `/new-system`, `/devlog`
**Wiki folders:** Commands/, Events/, Integrations/
**Triggers:**
- New slash command → wiki/Commands/
- OAuth scopes changed → verify minimum necessary
**Pitfalls:**
- No error handling → silently fails
- Tokens stored outside env
- Signing secret not validated
