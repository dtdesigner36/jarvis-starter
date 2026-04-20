# Bootstrap — Brownfield Adopt Mode

Soft integration of JARVIS into a **project already under development**. Does NOT replace `jarvis start` — it's a separate, non-destructive path.

**Core principle:** observe first → gap analysis → install only what's missing, in `.jarvis/` namespace.

---

## 1. Auto-trigger: when to enter Adopt mode instead of Start

If **any 2 of these signals** hit, JARVIS default is Adopt (not Start):

| Signal | Check |
|---|---|
| Active git history | `git log --oneline` returns ≥10 commits |
| Mature lockfile | `package-lock.json` / `pnpm-lock.yaml` / `poetry.lock` / `Cargo.lock` older than 7 days (mtime) |
| Real source code | `src/`, `app/`, `lib/`, `pkg/` contains non-boilerplate files (>10 files, or >500 LOC total) |
| Existing Claude setup | `CLAUDE.md` or `.claude/` directory exists |
| Existing docs | `docs/`, `wiki/`, `README.md` > 100 lines, or `CHANGELOG.md` exists |
| Running CI | `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/` exists |

When user types `jarvis start: <description>` in such a folder — JARVIS responds:

```
💠 JARVIS: I see this project is already in development
   (signals: {{N}} git commits, existing CLAUDE.md, mature lockfile).

   I recommend Adopt mode instead of Start — it will only add what
   you're missing, and won't touch existing configuration.

   Proceed with Adopt? (y) or force Start anyway? (start)
```

User can still force `jarvis start` — but default is Adopt.

Explicit entry: `jarvis adopt` (no description needed — JARVIS reads the project).

---

## 2. Phase A — Observe (read-only, zero writes)

JARVIS scans **without modifying anything**:

- Stack (from `brownfield-scan.md`)
- Existing `CLAUDE.md` — what rules are already there
- Existing `.claude/hooks/*` — what hooks are wired
- Existing `.claude/settings.json` — hook registrations
- Existing docs structure (`docs/`, `wiki/`, `README.md`, ADRs)
- Existing scripts in `package.json` / `Makefile` / `justfile` (test, lint, build)
- Secret-scanning tooling (`.gitleaks.toml`, `husky`, `trufflehog`, `.pre-commit-config.yaml`)
- Issue/TODO tracking (`TODO.md`, linear-sync config, `.github/ISSUE_TEMPLATE`)

Output: a **project fingerprint** shown to user. Still no writes.

---

## 3. Phase B — Gap Analysis

For each JARVIS core feature, check if the project already solves that problem. If yes → skip. If no → offer.

### Gap matrix

| JARVIS feature | "Already have it" signal (skip if true) | Why skip matters |
|---|---|---|
| **task-routing** | `CLAUDE.md` contains model-selection rules / plan-mode guidance / complexity tiers | User already tuned model picks |
| **memory-recall** | Living `docs/` or `wiki/` updated in last 30 days; OR ADR folder; OR `CLAUDE.md` has a "past decisions" section | User has their own recall system |
| **wiki-maintenance** | `docs/` or `wiki/` updated in last 30 days (git log on folder) | User maintains docs their way |
| **security-watch** | `.gitleaks.toml` / `husky` pre-commit with secret scan / `trufflehog` config / `.pre-commit-config.yaml` with `detect-secrets` | Existing scanner is probably better-tuned |
| **focus-tracker** | `TODO.md` maintained; OR linear/jira integration; OR active `CHANGELOG.md` | User tracks focus elsewhere |
| **skill-discovery** (on-demand) | Never skip — it's on-demand only, zero cost | — |
| **school-mode** (plugin) | Never auto-offer — user-invoked only | — |

### Detection rules (implementation hints)

- "CLAUDE.md contains X" — grep case-insensitive for keywords: model-selection → `opus|sonnet|haiku|model.*pick`, plan-mode → `plan.?mode|ExitPlanMode`, complexity → `trivial|simple|medium|complex|architectural`
- "docs updated in last 30 days" — `git log --since="30 days ago" -- docs/ wiki/ | head -1` returns non-empty
- "pre-commit with secret scan" — read `.pre-commit-config.yaml` and look for `detect-secrets`, `gitleaks`, `trufflehog`
- "linear/jira integration" — look for `linear.app` / `atlassian` in `package.json` deps or `.github/workflows/*.yml`

---

## 4. Phase C — Proposal

Show user the gap matrix as a single interactive block:

```
💠 JARVIS Adopt — analysis complete.

  Stack:        Next.js 15 + Prisma + PostgreSQL + Tailwind
  Archetype:    web-app (+ web-api signals)
  Existing:     CLAUDE.md (120 lines), .claude/hooks/post-edit.sh,
                docs/ (updated 3d ago), husky pre-commit

  Gap analysis:

  ☐ task-routing      — your CLAUDE.md has no model-pick rules     [offer]
  ☒ memory-recall     — you have docs/ updated recently             [skip]
  ☒ wiki-maintenance  — you already maintain docs/                  [skip]
  ☒ security-watch    — husky pre-commit handles secrets            [skip]
  ☐ focus-tracker     — no TODO.md or issue tracker detected        [offer]

  Will install (if you approve):
    .jarvis/           — state, memory, focus (namespace, no conflicts)
    .claude/hooks/jarvis-task-routing.sh  — NEW file, separate hook
    .claude/hooks/jarvis-focus-tracker.sh — NEW file, separate hook
    .claude/settings.json — will add 2 hook entries (merge, not replace)

  Will NOT touch:
    CLAUDE.md, docs/, existing hooks, existing settings.json entries

  Proceed? (y / pick-features / no)
```

`pick-features` lets user override — e.g. enable `security-watch` anyway.

---

## 5. Phase D — Soft Install

Rules, hard-coded, no exceptions:

1. **Namespace `.jarvis/` is the only new directory** JARVIS creates at project root.
2. **Hooks go into new files** named `.claude/hooks/jarvis-<feature>.sh`. Never append to existing hook files.
3. **`CLAUDE.md` gets ONE line** max: `<!-- JARVIS context: see .jarvis/state.md -->`. No feature rules, no archetype overlay, no merge dump.
4. **`settings.json`** — add only the JARVIS hook entries, preserve everything else. Use `jq` or structured merge, not append.
5. **`wiki/` is NOT created** in adopt mode. JARVIS records location of existing docs in `.jarvis/state.md` (e.g., `docs_location: docs/`).
6. **No archetype overlay** in adopt mode — user can run `jarvis evolve <archetype>` later if they want.

### Install per feature

Only features user checked in Phase C are installed. Each one:

- Adds its hook file to `.claude/hooks/jarvis-<feature>.sh` (copy from `core/<feature>/`)
- Registers hook in `.claude/settings.json` (merge, structured)
- Writes entry to `.jarvis/enabled-features.md`

### `.jarvis/state.md` after adopt

```markdown
# JARVIS State
mode: adopt
adopt-date: 2026-04-21
stack: next.js-15, prisma, postgres, tailwind
archetype-detected: web-app
archetype-applied: none (adopt mode — no overlay)
docs-location: docs/
enabled-features: task-routing, focus-tracker
skipped-features:
  - memory-recall (reason: docs/ updated recently)
  - wiki-maintenance (reason: user maintains docs/)
  - security-watch (reason: husky pre-commit detected)
existing-infra-respected:
  - CLAUDE.md
  - .claude/hooks/post-edit.sh
  - docs/
  - .husky/
```

---

## 6. Phase E — Record & hand off

- Append adopt event to `.jarvis/timeline.md`
- Show user a short summary: what was installed, what was skipped, why
- Remind: `jarvis status` to see state, `jarvis evolve` to add archetype if needed later

**Do NOT auto-run `jarvis suggest` or `jarvis audit` after adopt** — user asked for minimal intervention.

---

## 7. Edge cases

- **User says `pick-features` and enables a skipped one**: warn about potential overlap, still install if confirmed. Record in `state.md` as `forced: true`.
- **Project has existing `.jarvis/` from prior run**: adopt becomes a diff — show what's new in gap matrix vs. current `enabled-features.md`, only propose the delta.
- **Monorepo**: run gap analysis per workspace (`apps/*`, `packages/*`). Ask user whether to adopt at root or per-workspace.
- **Conflict: user approved a feature but its hook name collides with existing file**: stop, show error, ask for rename or skip. Never overwrite.

---

## 8. Relationship to `jarvis start`

| | `jarvis start` | `jarvis adopt` |
|---|---|---|
| Triggers on | empty / greenfield | existing project (auto-detected) |
| Asks for description | yes | no (reads project) |
| Installs archetype overlay | yes | no |
| Creates `wiki/` | yes | no (respects existing docs) |
| Touches `CLAUDE.md` | full merge | one-line reference |
| Touches existing hooks | appends with backup | never — new files only |
| Core features | all | only gaps |

If user is in brownfield and really wants full bootstrap — `jarvis start --force` overrides auto-trigger.