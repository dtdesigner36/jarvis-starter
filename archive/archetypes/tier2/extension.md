# Tier 2: extension (browser/VSCode/Obsidian)

**Stack:**
- Browser: Manifest V3 + TypeScript + Vite/webpack
- VSCode: yo code + TypeScript
- Obsidian: plugin-template + TypeScript

**Key files:** manifest.json, background/, content/, popup/
**Skills:** `/frontend-design` for UI, `/new-system`
**Wiki folders:** Permissions/, MessagePassing/, Storage/, UI/
**Triggers:**
- manifest.json changed → warn about permissions
- New content-script → security review
**Pitfalls:**
- Too broad permissions
- Content-script injects into sensitive pages
- No CSP
- Message passing without validation
- Storage in localStorage instead of chrome.storage
