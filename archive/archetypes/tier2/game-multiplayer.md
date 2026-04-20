# Tier 2: game-multiplayer

**Stack:** Phaser 3/Three.js + Node server + Colyseus/Socket.io + Redis
**Key files:** rooms/, scenes/, server-state/, client-prediction/
**Skills:** `/api-contract`, `/balance`, `/playtest`, `phaser-gamedev`
**Wiki folders:** Rooms/, Scenes/, Protocol/, Anti-cheat/
**Triggers:**
- Protocol message changed → sync client/server types
- Client-side authoritative logic → ❌ anti-cheat
**Pitfalls:**
- Client authoritative → cheating
- No reconciliation (client prediction vs server truth)
- No lag compensation
- Heavy messages block real-time
- No matchmaking / room cleanup
