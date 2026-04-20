# Tier 2: browser-game (offline/single-player)

**Stack:** Phaser 3 + TypeScript + Vite, or Three.js (3D), or HTML5 Canvas
**Key files:** scenes/, entities/, systems/
**Skills:** `phaser-gamedev` (Anthropic), `/balance`, `/animation`
**Wiki folders:** Scenes/, Entities/, Systems/, Assets/
**Triggers:**
- Balance numbers → `/balance`
- New scene → wiki/Scenes/<Name>.md
**Pitfalls:**
- Memory leaks in Phaser (forgetting destroy)
- Assets not preloaded
- Browser pinch-zoom conflicts with game
- No mobile optimization (touch controls)
- Save/load state in localStorage without validation
