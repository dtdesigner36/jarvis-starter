# Tier 2: cli-tool

**Stack:** Node + Commander/Yargs + oclif, or Python + Click/Typer, or Rust + Clap, or Go + Cobra
**Key files:** cli/, commands/, main entry
**Skills:** `/new-system` for commands, `/devlog`
**Wiki folders:** Commands/, Flags/, Examples/
**Triggers:**
- New command → wiki/Commands/
- Breaking CLI arg change → major version bump
**Pitfalls:**
- No `--help` on each subcommand
- Inconsistent flag conventions (`-v` vs `--version`)
- No completion scripts (bash/zsh/fish)
- Exit codes not semantic
- Synchronous IO blocks output
- No progress indicator on long operations
