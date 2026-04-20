# Notices and Attributions

JARVIS-Starter intentionally builds on patterns established by the Claude Code skills community. This file provides formal attribution for inspirations used in the design and architecture.

## Inspirations and Patterns

This project does **NOT** fork, copy, or redistribute source code from the projects below. It draws architectural patterns, design principles, and UX ideas — all of which are typically not copyrightable. Where similar patterns are used, credit is given here.

### 1. Claude Bootstrap by @alinaqi
- **Project:** https://github.com/alinaqi/claude-bootstrap
- **Patterns adapted:**
  - Orchestration workflow (bootstrap → persistent)
  - Stop Hooks usage for automated validation
  - Memory-persistence across sessions (Mnemos inspiration → adapted as `.jarvis/state.md` + `memory.md`)
  - iCPG-like intent tracking (simplified in JARVIS as focus tracker)

### 2. Impeccable by @pbakaus
- **Project:** https://github.com/pbakaus/impeccable
- **License:** Apache 2.0
- **Patterns adapted:**
  - Context Gathering Protocol (check loaded → persistent file → ask)
  - Persistent context file pattern (`.impeccable.md` → analogous `.jarvis/state.md`)
  - Progressive disclosure in SKILL.md (frontmatter → body → reference/)
  - Design skill subcommand structure (craft/teach/extract → informed JARVIS evolve/audit/etc.)
- **Design skills in `on-demand/` leverage impeccable when target archetype is web-app, landing, or mobile-app** — JARVIS recommends installing `pbakaus/impeccable` but does not bundle its files.

### 3. Emil's Design Skill by @emilkowalski
- **Project:** https://github.com/emilkowalski/skill
- **Patterns adapted:**
  - UI polish philosophy ("invisible details compound")
  - Design engineering mindset for vibe-coder audience
- **When applicable (web-app, landing archetypes)**, JARVIS recommends installing this skill directly.

### 4. Taste Skill by @leonxlnx
- **Project:** https://github.com/leonxlnx/taste-skill
- **Patterns adapted:**
  - Agency-tier design direction (high-end-visual-design approach)
  - Anti-AI-slop visual framework (Variance Engine)
- **Recommended for web-app and landing archetypes.**

### 5. Anthropic Skills (official) by Anthropic
- **Project:** https://github.com/anthropics/skills
- **Patterns adapted:**
  - Skill-creator iterative loop (draft → test → refine)
  - Description optimization with trigger/non-trigger evals
  - Progressive disclosure (frontmatter metadata → body → bundled resources)
- **Recommended skills from this repo** (phaser-gamedev, playwright-skill, claude-api) are referenced in `on-demand/skill-discovery/known-registry.md` for appropriate archetypes.

### 6. Spec-Kit Brownfield Extensions by @wcpaxx
- **Project:** https://github.com/wcpaxx/spec-kit-brownfield-extensions
- **Patterns adapted:**
  - Brownfield detection via config file scanning (package.json, pyproject.toml, etc.)
  - "Analyze before asking" approach — reduce user-facing questions via detection

### 7. awesome-claude-skills registry by @travisvn
- **Project:** https://github.com/travisvn/awesome-claude-skills
- **Patterns adapted:**
  - Community registry format as reference for `on-demand/skill-discovery/known-registry.md`
  - Filtering heuristics for community skills

## Dependencies

JARVIS-Starter has no runtime dependencies itself. It uses:
- **bash** (macOS / Linux shell)
- **python3** (for JSON parsing in hooks — stdlib only, no pip installs)
- **git** (optional — for conflict detection)

## License

MIT License

Copyright (c) 2025 dtdesigner36

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## License compatibility

- MIT (our license) is compatible with all referenced projects
- No code is copied from Apache-licensed pbakaus/impeccable — only architectural patterns
- Users who install `pbakaus/impeccable` separately via `npx skills add` get the original Apache 2.0 licensed code
