# Tier 2: cron-scheduler

**Stack:** node-cron / BullMQ / temporal; Python: APScheduler / Celery; or cloud scheduler (AWS EventBridge, GCP Scheduler)
**Key files:** jobs/, schedule.ts, workers/
**Skills:** `/new-system`, `/devlog`
**Wiki folders:** Jobs/, Schedule/
**Triggers:**
- New job → wiki/Jobs/<Name>.md
- Schedule change → warn about timezone
**Pitfalls:**
- Timezone bugs (server UTC vs local)
- Overlapping runs → need a lock
- No retry/failure alerting
- Long job blocks the next run
- No monitoring of "last success"
