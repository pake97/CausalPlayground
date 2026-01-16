# Semantics and supported subset

## Supported constructs (v0)
- Graph representation: nodes + edges with labels/types and properties
- Pattern match (restricted): single-hop and bounded-length paths
- k-hop neighborhood extraction
- Projection, filtering, grouping, aggregation (basic)
- Join with relational tables (covariates/outcomes)
- "Extract dataset" operator for plugins (materialize features/labels)

## Explicitly unsupported (v0)
- Variable-length paths with complex uniqueness semantics
- Arbitrary Cypher OPTIONAL MATCH / path distinctness corner cases
- Full SQL/PGQ features (we implement a subset sufficient for workflows)
- Cross-backend transaction semantics guarantees
