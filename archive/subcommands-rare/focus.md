# jarvis focus — what's in focus now

## Usage
```
> jarvis focus
```

## Workflow

Read `.jarvis/focus.md` (auto-updated by `core/focus-tracker/focus-updater.sh`).

Group by area (modules/features) and count touches:

```
💠 JARVIS: current focus (last 20 edits):

1. module:auth — 8 edits (latest 3 hours ago)
   • server/src/modules/auth/auth.service.ts
   • server/src/modules/auth/auth.guard.ts
   • ...

2. feature:dashboard — 5 edits (latest 1 day ago)
   • client/src/features/dashboard/Dashboard.tsx
   • ...

3. wiki — 3 edits
4. prisma — 2 edits
```

## Why

- Quickly recall what you've been touching
- Memory-recall uses focus as a relevance filter
- Before switching to something else — assess pending work in the current focus
