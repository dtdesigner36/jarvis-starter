# Archetype: web-app

## Default stack
- **Next.js 15 + App Router + TypeScript + Tailwind** (recommended for vibe-coders)
- Alternatives: Vite + React, Astro (if content-heavy), Nuxt 3 (Vue)

## Recommended skills

**Slash commands:**
- `/i18n-sync`, `/css-audit`, `/responsive-check`, `/theme-token`, `/screenshot-diff`
- `/frontend-design`, `/ui-polish`

**Agent skills (via npx skills add):**
- `emilkowalski/skill` — emil-design-eng
- `pbakaus/impeccable` — impeccable, shape, polish, typeset, colorize, animate, audit
- `leonxlnx/taste-skill` — high-end-visual-design, design-taste-frontend

## Wiki structure
```
wiki/
├── Components/
├── Design/
├── Pages/
├── Theming/
```

## Triggers

- `*.tsx` with `t()`/`ts()` → `/i18n-sync`
- CSS in `styles/` or `*.module.css` → `/css-audit` + `/responsive-check`
- New component in `src/components/` → `new-system` if it's a feature
- Hardcoded colors 3+ times → `/theme-token`

## Pitfalls
- `'use client'` in an RSC component without need — kills performance
- `h-screen` instead of `min-h-[100dvh]` — breaks on iOS Safari
- Client-side state in a server component — runtime error
- Inter / Roboto — generic fonts, won't cut it for a premium look
- Hardcoded hex instead of CSS variables/tokens

## Evolve paths
- + web-api → full-stack (or keep separate)
- + real-time-app → WebSocket layer
- + e-commerce → if selling
- + landing → if you need a marketing page next to the app

## Security essentials

- **XSS** — avoid `dangerouslySetInnerHTML`; if you use it, sanitize via DOMPurify
- **CSP headers** — add Content-Security-Policy in Next.js middleware/headers
- **Cookies** — `httpOnly: true`, `secure: true`, `sameSite: 'strict'` for session cookies
- **Auth tokens** — in httpOnly cookies, NOT localStorage (XSS risk)
- **CORS** — not `*` in production, only allowed origins
- **Environment variables** — `NEXT_PUBLIC_*` only for public data, secrets without the prefix
- **Dependencies** — `npm audit` regularly (see `jarvis security deps`)

## Community skill (new, to add)

**Needed:** `component-extractor` — a skill that takes a JSX component and refactors it into something reusable (props, types, stories, tests).

**Not yet in registry** — JARVIS searches for `"react component extractor"` or `"component refactor skill"` via `jarvis find` at bootstrap. Candidates: compound-components-skill, react-sdk-builder.
