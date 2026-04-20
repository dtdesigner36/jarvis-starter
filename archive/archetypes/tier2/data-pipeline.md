# Tier 2: data-pipeline

**Stack:** Python + Airflow/Prefect/Dagster + pandas/polars, or Node + Apache Beam
**Key files:** dags/, tasks/, transformations/
**Skills:** `/new-system`, `/devlog`
**Wiki folders:** Pipelines/, Sources/, Destinations/, DataSchema/
**Triggers:**
- Schema changed → compatibility check
- New pipeline → wiki/Pipelines/<Name>.md
**Pitfalls:**
- No checkpointing — restart = redo everything
- Memory blowups on large files (use streaming)
- Partial failures not handled
- Schema drift not detected
- No lineage tracking (which data comes from where)
