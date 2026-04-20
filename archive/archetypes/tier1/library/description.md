# Archetype: library

## Default stack
- TypeScript + tsup for npm package
- Python + setuptools/poetry for PyPI
- Vite library mode for bundled JS libs

## Recommended skills
- `/new-system` (if the library is modular)
- `/devlog`

## Wiki structure (minimal)
```
wiki/
├── API/            # public API docs
├── Examples/       # usage examples
└── Changelog/      # versions and breaking changes
```

## Triggers
- `index.ts` / `__init__.py` changed → reminder about semver
- `package.json` version → remind about CHANGELOG

## Pitfalls
- Breaking changes without a major version bump
- Dependencies not in peerDependencies when they should be
- No types export (TS declarations)
- Wrong exports in package.json
- Monorepo without proper workspaces config

## Evolve paths
- + cli-tool if a CLI wrapper is needed
- Or just stays a library

## Security essentials

- **No secrets in git** — no test credentials or example tokens in commit history
- **Supply chain** — `npm audit` / `pip-audit` before every release
- **Lockfile** — committed (`package-lock.json`, `pnpm-lock.yaml`, `poetry.lock`)
- **Dependency pinning** — not `^x.x.x` for critical deps, exact versions
- **Review transitive deps** — especially for popular libraries
- **2FA for publish** — npm publish only with 2FA enabled
- **Provenance** — npm provenance to verify the package really comes from your repo
- **Signed releases** — GPG-signed tags and commits for open-source

## Community skill (new, to add)

**Needed:** `semver-check` — checks whether a change breaks the current major version (detects breaking changes in exported types/signatures).

**Not yet in registry** — JARVIS searches for `"semver breaking change skill"` or `"api surface check"`. Candidates: api-extractor-skill, breaking-changes-detector.
