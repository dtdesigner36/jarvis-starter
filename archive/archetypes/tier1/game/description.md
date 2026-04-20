# Archetype: game

## Default stack
- Phaser 3 / Three.js / HTML5 Canvas + Next.js/Vite front + Node/NestJS back (for online games)

## Recommended skills
- `/playtest` — e2e game scenario walkthrough
- `/balance` — tuning numbers (HP, damage, XP)
- `/obsidian-canvas` — visual system schemas
- `/animation`, `/frontend-design`

**Agent skills:**
- `anthropics/skills#phaser-gamedev`
- `pbakaus/impeccable` if there's a lot of UI

## Wiki structure
```
wiki/
├── Systems/          # combat, skills, inventory, ...
├── GameDesign/       # progression, balance, equipment
├── Canvas/           # system diagrams
└── Balance/          # tables of numbers
```

## Triggers
- `src/scenes/*` changed → check lifecycle (preload, create, update)
- Numbers in `balance.ts`, `stats.ts` → `/balance`
- New system in `server/src/modules/` → `/new-system` + maybe canvas

## Pitfalls
- Logic on client for multiplayer (cheating surface)
- Clock sync — always serverNow(), not Date.now()
- Ownership check on server for all actions
- Blocking asset loading — preload everything in advance
- Memory leaks in Phaser (forgotten emitters, sprites)

## Evolve paths
- + web-api if not already a component
- + real-time-app → multiplayer
- + e-commerce → monetization

## Security essentials

- **Server-authoritative** — for multiplayer: all business logic on server, client is display-only
- **Anti-cheat baseline** — validate actions (position, speed, inventory) on server
- **Ownership check** — user can only act as their character
- **Rate limiting** — on action input (prevent spam)
- **Clock sync** — server time, not client (defense against speed hacks)
- **Game state validation** — hash/sign state on save (defense against save editing offline)

## Community skill (new, to add)

**Needed:** `game-state-debugger` — Phaser scene state inspector (entities, physics, timers) with step-through.

**Not yet in registry** — JARVIS searches for `"phaser debugger skill"` or `"game state inspector"`. Candidates: phaser-devtools, game-inspector.
