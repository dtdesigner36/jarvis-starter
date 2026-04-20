# Archetype: mobile-app

## Default stack
- React Native + Expo (recommended for vibe-coders)
- Alternatives: Flutter, Swift/Kotlin native

## Recommended skills
- `/i18n-sync` — translations are critical for mobile
- `/responsive-check` — different screens

**Agent skills:**
- `pbakaus/impeccable` — design quality

## Wiki structure
```
wiki/
├── Screens/
├── Gestures/
├── Performance/
└── Assets/
```

## Triggers
- Touch targets smaller than 44x44 → warn
- No safe area handling → propose SafeAreaView
- New screen → `/new-system`

## Pitfalls
- Touch targets < 44x44 — not tappable
- Hardcoded dimensions — not adaptive
- Large bundles → slow startup
- Orientation change not handled
- No offline handling

## Evolve paths
- + web-api for backend
- + web-app for web version (React Native Web)

## Security essentials

- **Secure storage** — auth tokens via `expo-secure-store` / `react-native-keychain`, not AsyncStorage
- **Certificate pinning** — for critical API endpoints (banking, health)
- **Don't log tokens** — logs may surface in crashlytics; no credentials there
- **Jailbreak/root detection** — if the app handles sensitive data
- **Biometric auth** — for app unlock, via OS API, not custom
- **Deep links** — validate parameters (open door for attacks)
- **Code obfuscation** — for production builds

## Community skill (new, to add)

**Needed:** `mobile-a11y-audit` — checks mobile accessibility (touch targets ≥44×44, screen reader support, color contrast on AMOLED), safe areas, dynamic type.

**Not yet in registry** — JARVIS searches for `"mobile accessibility skill"` or `"react native a11y"`. Candidates: rn-a11y-checker, mobile-axe.
