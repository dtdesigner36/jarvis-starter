# jarvis decide — help with an architectural decision

When the user doesn't know which approach to pick.

## Usage

```
> jarvis decide "how to store sessions — DB or Redis?"
> jarvis decide "Prisma or Drizzle?"
> jarvis decide "monorepo or separate repos?"
```

## Workflow

### 1. Understand context
Read `.jarvis/state.md` — what project, archetypes, stack.
Read `.jarvis/memory.md` — what's already decided.
Read relevant `wiki/Systems/*.md` if any.

### 2. Analyze the question
Identify:
- Which alternatives the user is considering
- If no alternatives listed — suggest 2-3 relevant ones
- What criteria matter (speed, simplicity, scalability, cost)

### 3. Give a structured answer

Vibe-coder language:

```
💠 JARVIS: unpacking "how to store sessions — DB or Redis"

For your project (<archetypes>, <scale>):

Option 1: DB (Prisma Session table)
  ➕ Simple, DB already exists, nothing extra to install
  ➕ Data persistent (survives restart)
  ➖ Read on every request — load on DB
  ➖ Slower than Redis at scale

Option 2: Redis
  ➕ Faster (in-memory)
  ➕ Built-in expiration (TTL)
  ➖ Extra service (docker, config, deploy)
  ➖ Data lost on restart unless persistence is configured

Recommendation for your case: **DB** — you have <1000 users now, Redis is overkill. You can switch later when you actually see a bottleneck.

Record this decision? `jarvis remember "sessions via Prisma Session"`
```

### 4. Remember the decision (optional)
If the user confirms — automatically `jarvis remember` the decision.

## Principles

1. **Vibe-coder language** — no jargon. "load" instead of "throughput overhead".
2. **Pros/cons as lists** — not prose blocks.
3. **Concrete recommendation** — not "depends on you".
4. **Scale-aware** — don't suggest enterprise for a pet project.
5. **YAGNI** — prefer the simple solution until there's pain.
6. **Remember** — so the next question on the same topic doesn't contradict itself.