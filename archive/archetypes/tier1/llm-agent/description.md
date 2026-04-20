# Archetype: llm-agent

## Default stack
- Claude Agent SDK + TypeScript (official)
- LangChain / LangGraph for more complex flows
- Python + anthropic / openai clients

## Recommended skills
- `anthropics/skills#claude-api`
- `/new-system` for new agents
- `/devlog` — AI behavior changes fast, record everything

## Wiki structure
```
wiki/
├── Agents/         # description of each agent / tool
├── Prompts/        # prompt library and versions
├── Tools/          # tool definitions
└── Evals/          # evaluation results
```

## Triggers
- Prompt changed → warn about regression, suggest eval
- New tool → add to wiki/Tools/
- Model version in code → warn about version pinning

## Pitfalls
- Hardcoded prompts without templating → hard to change
- No prompt caching → expensive
- Model not pinned → unpredictable behavior
- Tool descriptions unclear → agent picks wrong one
- No tracing/logging → impossible to debug
- No evals — regressions slip through

## Evolve paths
- + web-api → expose as REST
- + web-app → chat UI
- + data-dashboard → monitoring

## Security essentials

- **Prompt injection protection** — don't trust user input in prompts, filter/sanitize
- **Don't leak secrets into LLM** — don't pass API keys, DB credentials, PII in messages
- **Rate limiting** — cost control + abuse prevention
- **PII filtering** — mask emails, phones, IDs before sending user data to the LLM
- **Output validation** — an LLM may generate harmful code; validate before execution (for tool use)
- **Model version pinning** — not `claude-3-*-latest`, pin specific versions (security predictability)
- **Logs** — redact user prompts in logs if they may contain PII
- **Access to tools** — an LLM agent with file-system / shell access is a security concern; scope narrowly

## Community skill (new, to add)

**Needed:** `prompt-eval-runner` — automated eval suite for prompts (regression detection, A/B prompts, LLM-as-judge).

**Not yet in registry** — JARVIS searches for `"prompt eval skill"` or `"llm evaluation runner"`. Candidates: promptfoo-integration, langsmith-runner.
