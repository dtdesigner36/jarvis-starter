---
name: obsidian-canvas
description: Design and generate Obsidian Canvas (.canvas) files with clean layouts
---

# Obsidian Canvas Designer

Creates/redesigns `.canvas` files. Works in Obsidian (visual render) and any JSON editor (raw).

## Usage

- `/obsidian-canvas architecture` — architecture diagram
- `/obsidian-canvas flow <topic>` — flow diagram
- `/obsidian-canvas journey <topic>` — user journey
- `/obsidian-canvas <path/to/file.canvas>` — redesign an existing one

## JSON Canvas 1.0 spec (abridged)

### Node
```json
{
  "id": "unique", "type": "text|group|file|link",
  "x": 0, "y": 0, "width": 280, "height": 160,
  "color": "1-6"
}
```
Type-specific: `text: {"text": "..."}`, `group: {"label": "..."}`, `file: {"file": "..."}`, `link: {"url": "..."}`.

### Edge
```json
{
  "id": "unique", "fromNode": "...", "toNode": "...",
  "fromSide": "top|right|bottom|left", "toSide": "...",
  "toEnd": "arrow", "label": "..."
}
```

## Colors (semantic)

| Code | Use for |
|------|---------|
| 1 | Errors, death, warnings |
| 2 | Server/backend, primary flow |
| 3 | Notes, tips, neutral info |
| 4 | Data, database, success |
| 5 | Client/realtime, results |
| 6 | UI, browser, client-facing |

## Spacing

- Horizontal gap (center-to-center): 320px
- Vertical gap: 200px
- Node height: 2-line=120px, 3-line=160px, 4-line=180px, 5-line=200px
- Node width: 240-300px standard
- Group padding: 40px around children

## Layout strategies

1. **Linear pipeline** (→ no crossings) — all nodes same Y, errors below
2. **Hierarchical columns** (minimal crossings) — by layer, left-to-right
3. **Branching tree** (zero crossings) — main → up-right for win, down-right for lose
4. **Radial** — central node + branches

## Anti-crossing rules

1. No fan-in from different rows
2. Match Y levels for adjacent columns
3. Errors strictly below via bottom→top
4. Loop-back via top→top arcs
5. Groups as visual separators

## Node text

`### 🔑 Title\nLine 2\nLine 3` — use ### heading + emoji + 3 lines max.

## Save

`wiki/Canvas/<Name>.canvas` — and a link in `wiki/HOME.md` with the `.canvas` extension.
