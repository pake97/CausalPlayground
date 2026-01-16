# Golden workflows (v0)

Workflow 1: Backdoor adjustment dataset extraction
- Input: node/edge tables + covariates table
- Query: identify candidate adjustment set and extract (T, Y, X) dataset
- Output: materialized table for estimator plugin; provenance record

Workflow 2: Neighborhood feature extraction + ML model
- Input: graph + labels table
- Query: extract k-hop neighborhood features for nodes
- Output: features + model training via plugin

Workflow 3: Cross-backend portability check
- Input: same graph stored in Neo4j and DuckDB
- Query: same DSL query compiled to both backends
- Output: equivalent result set (or documented divergence)
