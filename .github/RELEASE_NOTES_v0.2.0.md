## The "starts paying for itself" release

v0.2.0 is the first version where **JARVIS brings measurable value from day one** — not just infrastructure. Across six real-project retests (Next.js SaaS + aiogram bot), the useful-share climbed from ~20–25% at v0.1 to ~88% here.

Four architectural shifts define the release:

### 1. The installer actually installs
v0.1 shipped hooks that didn't install themselves. `scripts/bootstrap.sh` now does a real `jq` merge into `.claude/settings.json`; `scripts/adopt.sh` exists for brownfield with a full gap-analysis flow. Hook templates quote paths correctly, substitute archetype-specific triggers, and keep `INPUT=$(cat)` once at the top (a series of small fixes that together turned the skill from "decoration" into "runs").

### 2. JARVIS sees itself — `jarvis self-audit`
Every hook now writes one line to `.jarvis/usage-log.md` on fire. `jarvis self-audit` reads the log + on-demand catalog + state and emits a table: which hooks fire, which stay silent, which on-demand commands you haven't tried, which archetype overlays are available. Clear separation from `jarvis audit` (project audit).

### 3. Full Discovery Layer
`core/skill-discovery/stack-matcher.sh` reads `.jarvis/state.md` (archetype + stack), walks `known-registry.md` (extended with Stack-tags), and outputs a top-N ranked list with rationale:
```
★★★★★ @pbakaus/impeccable
        match: archetype=web-app  stack-overlap=[nextjs,react,tailwind]
```
Runs automatically in `adopt.sh` Phase C — no more "skill discovery just doesn't happen" complaints.

### 4. Wiki ownership: active, not passive
When a new module shows up in `src/{modules,features}/<X>/`, `scaffold.sh` auto-creates `wiki/Systems/<X>.md` with YAML frontmatter, a TL;DR stub, auto-filled Files list, Decisions placeholder, and a maintained Last-edit timestamp. On subsequent edits, `live-update.sh` keeps Files and timestamps current. An empty wiki is no longer possible.

---

### Other highlights

- **Bilingual ADR detector** (EN + RU): 24 regex patterns with verb-flexion. Russian ADR moments that previously stayed silent now fire at ~100% hit rate.
- **Auto-apply archetype overlay on confident detection** (≥3 stack-tags) — with escape hatches (`--no-archetype`, interactive Y/n/never, `archetype-overlay: never` in preferences). The web-app / telegram-bot / llm-agent overlays ship themselves instead of waiting for `--enable`.
- **Context-triggered on-demand command surfacing** in hooks: wiki-stale → `jarvis docs`; 100 edits without audit → `jarvis suggest` / `jarvis audit`; auth/supabase/service-role file edits → `jarvis security`; search-like prompts ("how to implement X", "какая библиотека") → `jarvis find <need>`; ADR moments → `jarvis decide`.
- **`scripts/safe-uninstall.sh`** with full `.jarvis/` backup, visible backup dir name, Python guard against accidental CLAUDE.md wipe, explicit `find` listing of backed-up files.
- **Namespace matrix for wiki**: `docs/` + `wiki/` → JARVIS owns `wiki/`; only `docs/` → JARVIS writes to `.jarvis/systems/` (no parallel wiki); neither → `wiki/` with full ownership.
- **Claude Code settings.json-wipe quirk** documented in `archive/bootstrap/brownfield-adopt.md` §8 with three mitigations.

### Install

```bash
npx skills add dtdesigner36/jarvis-starter --yes
```

Then in Claude Code:
```
> jarvis start: <project description>
# or for an existing project:
> jarvis adopt
```

### Full changelog

See [CHANGELOG.md](https://github.com/dtdesigner36/jarvis-starter/blob/main/CHANGELOG.md).

### What's next (v0.3 roadmap)

- Skill inventory (Layer A) — walking `.agents/skills/`, `tools/` for user-installed skills
- Skill diff (Layer D) — compare installed vs registry-recommended → upgrade paths
- GitHub research (Layer C) — `gh api` search for skills beyond the registry
- `jarvis doctor` — self-check settings.json on session start, re-apply if the harness stripped hooks
- Bootstrap stack auto-detect (currently only adopt.sh detects automatically)
- Registry expansion for telegram-bot / web-api archetypes (currently sparse)
