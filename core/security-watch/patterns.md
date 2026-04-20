# Security Detection Patterns

Regex patterns for `secret-scanner.sh`. Full list (extensible).

## API Keys / Tokens

| Pattern | What it catches |
|---------|-----------------|
| `['"][0-9]{8,10}:[A-Za-z0-9_-]{35,}['"]` | Telegram bot token |
| `sk-ant-[A-Za-z0-9_-]{20,}` | Anthropic API key |
| `sk-[A-Za-z0-9]{20,}` | OpenAI API key (generic sk-) |
| `xox[bpoa]-[A-Za-z0-9-]{20,}` | Slack token (bot/user/app/admin) |
| `AKIA[0-9A-Z]{16}` | AWS Access Key ID |
| `aws_secret_access_key\s*=\s*['\"][A-Za-z0-9+/=]{40}['\"]` | AWS Secret Key |
| `gh[pousr]_[A-Za-z0-9]{36,}` | GitHub Personal Access Token |
| `ghp_[A-Za-z0-9]{36,}` | GitHub fine-grained token |
| `glpat-[A-Za-z0-9_-]{20}` | GitLab PAT |
| `sq0[a-z]{3}-[A-Za-z0-9_-]{22,43}` | Square token |
| `EAA[A-Za-z0-9]{100,}` | Facebook access token |
| `AIza[0-9A-Za-z_-]{35}` | Google API key |

## Database / Connection Strings

| Pattern | What it catches |
|---------|-----------------|
| `(postgres\|mysql\|mongodb)://[^:]+:[^@]+@` | DB URL with credentials inline |
| `redis://[^:]+:[^@]+@` | Redis URL with password |
| `amqp://[^:]+:[^@]+@` | RabbitMQ URL |

## Generic credentials in code

| Pattern | What it catches |
|---------|-----------------|
| `(BOT_TOKEN\|API_KEY\|SECRET)\s*=\s*['\"][A-Za-z0-9_.+/=-]{16,}['\"]` | Hardcoded in code |
| `jwtSecret\s*[:=]\s*['\"][A-Za-z0-9]{12,}['\"]` | JWT secret |
| `password\s*[:=]\s*['\"][^'\"]{8,}['\"]` | Hardcoded password |

## Private Keys

| Pattern | What it catches |
|---------|-----------------|
| `BEGIN (RSA \|DSA \|EC )?PRIVATE KEY` | Private key |
| `BEGIN OPENSSH PRIVATE KEY` | SSH private key |

## False positive mitigation

- Don't trigger if value is an ENV reference: `process.env.API_KEY`, `${process.env.X}`, `os.getenv("Y")`
- Don't trigger in `.env.example` — that's intentionally examples
- Don't trigger in test files that explicitly contain `mock`/`fake`/`example`/`test-key-`
- Don't trigger if the file is in `.gitignore` (exists locally but not committed)

## Extending

To add a new pattern — update `secret-scanner.sh` and this table. Keep:
- Short name of what the pattern catches
- Minimum length to reduce false positives
- Pre/post specifics — where to search (whole file, only inside quotes, etc.)

## References

- [truffleHog patterns](https://github.com/trufflesecurity/trufflehog) — reference for similar scanners
- [gitleaks rules](https://github.com/gitleaks/gitleaks) — another source