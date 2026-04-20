# Tier 2: e-commerce

**Stack:** Next.js + Commerce.js/Medusa/Shopify headless, or fully custom (Next + NestJS + Stripe)
**Key files:** products/, cart/, checkout/, orders/
**Skills:** `/api-contract`, `/db-migrate`, impeccable, `/balance` (prices)
**Wiki folders:** Products/, Cart/, Checkout/, Orders/, Payments/
**Triggers:**
- Payment flow changed → security review mandatory
- Price logic changes → audit
- Inventory tracking → order idempotency
**Pitfalls:**
- Race conditions in inventory (double-sell)
- Payment webhook not idempotent
- Taxes/shipping not accounted
- Cart in localStorage + no server sync
- No fraud detection
- PCI compliance ignored (if custom payment)
