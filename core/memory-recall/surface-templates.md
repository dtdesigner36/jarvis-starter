# Surface Templates

Output formats for different cases.

## One wiki match

```
💠 JARVIS: [[wiki/Systems/Auth.md]] already covers this area. Read it before making changes.
```

## Multiple wiki matches

```
💠 JARVIS: related systems are already documented:
  • [[wiki/Systems/Auth.md]]
  • [[wiki/Systems/Users.md]]
  Worth reading before implementing.
```

## Memory match

```
💠 JARVIS: in project memory:
  • API uses bearer token, not sessions (recorded 2 weeks ago)
  Use the existing solution.
```

## Combined

```
💠 JARVIS: already exists:
  • [[wiki/Systems/Auth.md]] — system documented
  • JWT with refresh rotation (memory)
  Don't reinvent.
```

## Brief (for short prompts)

```
💠 JARVIS: see [[wiki/Systems/Auth.md]] — already solved.
```

## Format rules

- `💠 JARVIS:` emoji prefix — consistent across all JARVIS output
- Wiki links in `[[...]]` format — works in Obsidian and other vault tools
- Max 5-7 lines
- No lectures, just facts