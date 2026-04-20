# Tier 2: ml-model

**Stack:** Python + pytorch/transformers/scikit-learn + W&B/MLflow (tracking)
**Key files:** train.py, eval.py, data/, models/
**Skills:** `/new-system`, `/devlog` (very important for experiment tracking)
**Wiki folders:** Experiments/, Datasets/, Metrics/, Evals/
**Triggers:**
- train.py changed → model version changes
- New dataset → wiki/Datasets/<Name>.md
**Pitfalls:**
- Data leakage (test in train)
- Reproducibility (seed not fixed)
- No eval suite — overfitting not caught
- Checkpoints large and not gitignored
- No model card (description, limits, biases)
