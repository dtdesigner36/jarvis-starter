---
name: jarvis-school-mode
description: Optional JARVIS plugin for users who want to learn, not just build. Creates a school-wiki/ with a topic index for the project's stack. Deep topic exploration happens only on explicit request. NOT proactively offered — activated via jarvis school on.
user-invocable: true
---

# JARVIS School Mode

Learning plugin. **Off by default**. Activated manually if the user wants it.

## Philosophy

JARVIS builds the project, but the user may not just want the result — they want to **understand** how their stack works. School mode helps systematically learn key concepts of the stack without bloating normal work.

**Does NOT add inline explanations** to regular answers — that clutters the context.
**Instead:** creates a separate `school-wiki/` with a topic index and runs lessons on request.

## Commands

| Command | Action |
|---------|--------|
| `jarvis school on` | Create school-wiki/ with topic stubs for the project's stack |
| `jarvis school off` | Turn off the plugin (school-wiki/ stays as files) |
| `jarvis school list` | Show INDEX.md |
| `jarvis school topic <area>` | Start a topic dialogue |
| `jarvis school progress` | What's covered, what's ahead |
| `jarvis school refresh` | Update topics if the stack changed |

## Activation workflow

### `jarvis school on`

1. Read `.jarvis/state.md` — get the project stack
2. For each tech in the stack — look for `stub-templates/<tech>.md`:
   - If it exists — copy to `school-wiki/<tech>.md`
   - If not — generate a minimal stub (3-4 lines)
3. Create `school-wiki/INDEX.md` with the topic list
4. Create `school-wiki/progress.md` (empty)
5. Add to `.jarvis/plugins.md`: `school-mode: on`
6. Confirm to the user:
```
💠 JARVIS: school-mode enabled. Created school-wiki/ with 12 topics.
   Commands:
   - jarvis school list — see what's available
   - jarvis school topic <topic> — walk through a topic
```

### `jarvis school topic <area>`

This is the plugin's main value. The user says "I want to understand <topic>" — JARVIS starts a lesson dialogue.

Workflow:
1. Read `school-wiki/<area>.md` (the stub — what it is and where in the project)
2. Read real project files tied to that topic
3. Read `school-wiki/progress.md` — what the user already knows on related topics
4. Start a Socratic dialogue:
   - Ask about the user's level
   - Explain concepts using examples from **their** project (not abstract)
   - Ask questions to check understanding
   - Recommend resources (official docs, videos)
   - Propose a safe exercise
5. After the session, update `school-wiki/progress.md`

## Token cost

- **Off:** 0 tokens
- **On (regular work):** 0 tokens (stubs aren't read unless called)
- **Topic session:** 3-10K tokens for a full topic walkthrough
- **Refresh:** 1-2K tokens

## School extensions

In the future:
- `jarvis school quiz` — verify understanding
- `jarvis school path` — curated order of topics
- `jarvis school compare <A> <B>` — compare two technologies