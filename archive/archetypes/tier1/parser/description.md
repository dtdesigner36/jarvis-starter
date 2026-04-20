# Archetype: parser

## Default stack
- Python: Playwright + BeautifulSoup4 + Pandas (ETL)
- Node: Playwright + Cheerio

## Recommended skills
- `anthropics/skills#playwright-skill` — browser automation
- `/new-system` — new sources

## Wiki structure
```
wiki/
├── Sources/          # description of each data source
├── Pipelines/        # ETL steps
├── RateLimits/       # policies per site
└── DataSchema/       # resulting data schema
```

## Triggers
- New CSS selector → warn about fragility, recommend stable attributes
- Rate limit config changed → check against robots.txt / terms

## Pitfalls
- No retry logic on flaky requests
- No User-Agent → gets blocked
- Selectors break on site redesign — abstract them
- No checkpoints in long pipelines
- Rate limit not respected → ban
- Sensitive data (API keys) in code

## Evolve paths
- + data-dashboard → data visualization
- + web-api → API over the scraped data
- + cron-scheduler → regular scraping

## Security essentials

- **Respect robots.txt** — legally and ethically
- **Rate limits** — aggressive scraping = IP ban, can also be basis for legal claims
- **User-Agent** — real, not default library UA (gets blocked faster)
- **Don't log PII** — if scraper touches personal data, don't log it
- **Credentials** — rotate API keys for target services, store only in env
- **Proxy safety** — if using proxy service, verify TLS (MITM risk with untrusted proxies)
- **Data at rest** — if storing scraped data, encrypt sensitive fields

## Community skill (new, to add)

**Needed:** `selector-resilience` — checks CSS/XPath selector fragility, proposes more stable ones (via data-* attributes, text content, semantic HTML).

**Not yet in registry** — JARVIS searches for `"selector hardening skill"` or `"xpath resilience"`. Candidates: scraper-health, selector-healer.
