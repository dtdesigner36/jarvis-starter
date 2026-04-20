# Archetype: landing

## Default stack
- Next.js 15 (SSG/SSR) + Tailwind / Astro / plain HTML
- Minimum JS, maximum static, SEO-first

## Recommended skills
- `/responsive-check` — landings must look perfect on mobile
- `/theme-token`, `/screenshot-diff`
- `/frontend-design`, `/ui-polish`

**Agent skills:**
- `pbakaus/impeccable` — full pack is important for landings
- `leonxlnx/taste-skill` — high-end-visual-design is critical

## Wiki structure
```
wiki/
├── Sections/       # hero, features, pricing, testimonials
├── Copy/           # copy, A/B variations
├── SEO/            # meta, OG, JSON-LD
└── Assets/
```

## Triggers
- CSS changes → `/css-audit` + `/responsive-check`
- New section → wiki/Sections/<Name>.md
- SEO metadata edits → reminder to check OpenGraph preview

## Pitfalls
- Hero with `h-screen` instead of `min-h-[100dvh]` — breaks on iOS
- No lazy-loading for below-fold images
- Generic fonts (Inter, Roboto) — looks cheap on a landing
- No structured data (JSON-LD) — loses in SEO
- Too much JS on page — slow TTI

## Evolve paths
- + web-app → add app section
- + e-commerce → if selling
- + blog → content marketing

## Security essentials

- **CSP header** — strict Content-Security-Policy (especially for contact forms)
- **HTTPS only** — HSTS header, redirect HTTP→HTTPS
- **Contact forms** — reCAPTCHA / hCaptcha to block spam
- **No inline scripts** — use separate files (CSP-friendly)
- **Analytics** — GDPR consent (if EU audience), minimal tracking
- **Third-party scripts** — Subresource Integrity (SRI) hashes for CDN

## Community skill (new, to add)

**Needed:** `seo-audit` — checks OG meta, JSON-LD, structured data, Core Web Vitals, alt text, canonical URL, robots.txt.

**Not yet in registry** — JARVIS searches for `"seo audit skill"` or `"web vitals skill"`. Candidates: seo-optimizer, lighthouse-runner-skill.
