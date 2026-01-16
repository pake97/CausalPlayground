# Design brief

## Thesis
We argue that causal analysis workflows require a systems boundary that spans (1) graph navigation, (2) relational processing, and (3) learning/estimation. We propose a causal runtime with a small IR/DSL compiled to heterogeneous backends and a pluggable algorithm interface.

## Research questions
1) What are the stable primitives of causal graph analysis that should be backend-independent?
2) How can we compile those primitives to different graph query substrates (Cypher, SQL/PGQ) while keeping semantics predictable?
3) How should causal/ML algorithms plug into a data system with reproducible, efficient data access?

## Contributions
1) A minimal causal DSL/IR that captures core causal-graph operations and compiles to Cypher and SQL/PGQ.
2) A runtime architecture with explicit contracts: query plane (planning/compilation) + learning plane (plugins).
3) A prototype + evaluation on representative workflows demonstrating portability, overhead bounds, and extensibility.

## Non-goals
- Full Cypher or full SQL/PGQ compatibility
- A complete causal inference library (we focus on the systems boundary + plugin interface)
