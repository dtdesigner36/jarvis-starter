# Tier 2: webhook-handler

**Stack:** Express/Hono/Fastify + minimal. Often serverless (Vercel/Cloudflare Workers)
**Key files:** handlers/, verifiers/, queue/
**Skills:** `/api-contract`, `/devlog`
**Wiki folders:** Webhooks/, Integrations/, Retries/
**Triggers:**
- New webhook handler → wiki/Webhooks/<Source>.md
- Signature verification missing → ❌
**Pitfalls:**
- Signature not verified → anyone can spam
- Synchronous processing on long tasks → timeout from sender
- Not idempotent → duplicate processing
- No retry / DLQ
- No alerting on failures
