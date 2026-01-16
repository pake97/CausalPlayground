# Causal Runtime (Neo4j + DuckDB + Plugins)

Monorepo skeleton for a CIDR-style systems prototype:
- A minimal causal DSL/IR compiled to two backends:
  - Neo4j (Cypher)
  - DuckDB (SQL/PGQ)
- A plugin runtime for causal estimators + ML models
- A Python API (FastAPI) and Next.js UI

## Quickstart (dev)
1) Install prerequisites: Docker + Docker Compose, Python 3.11+, Node 18+
2) Start services:
   - `docker compose up --build`
3) API:
   - http://localhost:8000
4) UI:
   - http://localhost:3000

## Repo structure
- `compiler/` DSL/IR + compilation to backend queries
- `backends/` Neo4j + DuckDB adapters
- `runtime/` orchestration, planning, provenance
- `plugins/` plugin API + reference plugins
- `api/` FastAPI service
- `ui/` Next.js frontend
- `docs/` paper-facing design docs + semantics + workflows
