# Tier 2: saas-app

**Stack:** Next.js + NestJS + Prisma + PostgreSQL + Stripe + Clerk/Auth0
**Key files:** billing/, auth/, multi-tenant/
**Skills:** `/api-contract`, `/db-migrate`, impeccable, `/new-system`
**Wiki folders:** Billing/, Auth/, Tenancy/, Onboarding/, Endpoints/
**Triggers:**
- Billing logic changed → `/devlog` critical (money!)
- Auth changes → security review
- Multi-tenant boundary violated → ❌
**Pitfalls:**
- No multi-tenant isolation
- Stripe webhook without signature verification
- Auth race conditions (double-billing)
- Billing events not logged
- Password reset vulnerabilities
- No audit log for admin actions
