# Tier 2: trading-bot

**Stack:** Python + ccxt + pandas / TypeScript + ccxt-ts
**Key files:** strategies/, exchanges/, backtesting/
**Skills:** `/balance`, `/new-system`, `/devlog` (⚠️ very important for audit trail)
**Wiki folders:** Strategies/, Exchanges/, Risk/, Backtests/
**Triggers:**
- Risk parameters changed → `/balance`
- API keys — always in env, never in code
- New strategy → wiki/Strategies/<Name>.md
**Pitfalls:**
- NO backtesting → trading blindly
- No stop-loss → can lose everything
- Race conditions in concurrent orders
- Floating-point for prices → use Decimal
- Testnet vs mainnet — swapping keys
- No per-trade logging → audit impossible
