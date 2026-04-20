# Archetype: desktop

## Default stack
- Electron + React/Vue/Svelte (classic, larger ecosystem)
- Tauri + Rust backend + any frontend (lighter, faster, safer)

## Recommended skills
- `/api-contract` — for main↔renderer IPC
- `/frontend-design` — UI
- `/new-system`

## Wiki structure
```
wiki/
├── Windows/        # description of each app window
├── IPC/            # main-renderer communication
├── NativeAPIs/     # file system, notifications, tray
└── Packaging/      # build/distribute settings
```

## Triggers
- Main process file changed → warn about restart
- IPC channel added → add to wiki/IPC/
- Auto-updater config → verify signing

## Pitfalls (Electron-specific)
- Node integration enabled in renderer → security hole
- Context isolation off → preload leaks
- Bundle size huge → optimize (Electron Forge)
- Memory leaks if renderers aren't destroyed

## Pitfalls (Tauri)
- Permissions in tauri.conf.json not tight
- IPC via commands, don't scatter logic

## Evolve paths
- + web-api if backend is external
- + mobile-app if a mobile client is needed

## Security essentials

**Electron-specific (CRITICAL):**
- `nodeIntegration: false` in renderer
- `contextIsolation: true` (default from v12+)
- Minimal `preload` scripts — only what's needed
- `webSecurity: true` (don't disable)
- Content Security Policy in main process
- Disable remote loading of untrusted URLs

**Tauri-specific:**
- `allowlist` in tauri.conf.json — only needed API calls
- `fs.scope` strictly scoped paths (not `**`)
- Disable inspector in production

**Both:**
- **Auto-updater** — signed updates are mandatory (code signing certificate)
- **IPC validation** — main process must not trust the renderer unconditionally
- **Protocol handlers** — if the app registers a custom protocol, validate parameters

## Community skill (new, to add)

**Needed:** `electron-security-audit` (for Electron) or `tauri-permissions-audit` — checks secure defaults: context isolation, node integration off, preload minimal, permissions scoped.

**Not yet in registry** — JARVIS searches for `"electron security skill"` or `"tauri permissions skill"`. Candidates: electronegativity-runner, tauri-safe.
