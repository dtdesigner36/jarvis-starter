# Tier 2: data-dashboard

**Stack:** Next.js + TanStack Table + Recharts/Plotly + ClickHouse/Postgres
**Key files:** charts/, queries/, filters/
**Skills:** `/api-contract`, `/frontend-design`, `/responsive-check`
**Wiki folders:** Metrics/, Queries/, Charts/, Filters/
**Triggers:**
- Query changed → check performance (EXPLAIN)
- New chart type → document in wiki/Charts/
**Pitfalls:**
- N+1 queries kill performance
- No caching → every refresh = full query
- Frontend renders 10000+ rows without virtualization
- Time zone bugs in date filters
- No export (CSV/PDF)
