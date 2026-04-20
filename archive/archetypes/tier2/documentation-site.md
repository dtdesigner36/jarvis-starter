# Tier 2: documentation-site

**Stack:** Docusaurus, Vitepress, MkDocs Material, Nextra
**Key files:** docs/, sidebars.js, config.ts
**Skills:** `/new-system` (for new sections), `/devlog`
**Wiki folders:** Structure/, Search/ (for algolia etc)
**Triggers:**
- New section → update sidebar/nav
- API doc changes → check consistency
**Pitfalls:**
- No search (algolia, local)
- No doc versioning (for libraries with breaking changes)
- No interactive examples (live code)
- Broken links not checked in CI
