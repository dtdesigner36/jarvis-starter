# Tier 2: ml-api

**Stack:** FastAPI + Pydantic + transformers/torch, or Flask + serving
**Key files:** models/, inference/, preprocessing/
**Skills:** `/api-contract`, `/new-system`, `/devlog`
**Wiki folders:** Models/, Inference/, Preprocessing/, Metrics/
**Triggers:**
- Model changed → re-eval before deploy
- Latency regression → check batching
**Pitfalls:**
- Model loads on every request → should be in memory on startup
- No input validation → crash on malformed data
- GPU memory leaks
- No model versioning
- Batching missing → poor throughput
