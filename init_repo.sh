#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./init_repo.sh <repo_name>
# Example:
#   ./init_repo.sh causalplayground
#
# Notes:
# - Creates a single monorepo skeleton (recommended for research prototypes).
# - Adds placeholder docs + minimal Makefile + Docker Compose + FastAPI + Next.js stubs.

REPO_NAME="${1:-}"
if [[ -z "${REPO_NAME}" ]]; then
  echo "Error: repo_name missing."
  echo "Usage: $0 <repo_name>"
  exit 1
fi

if [[ -e "${REPO_NAME}" ]]; then
  echo "Error: path already exists: ${REPO_NAME}"
  exit 1
fi

mkdir -p "${REPO_NAME}"
cd "${REPO_NAME}"

# ---- Directory layout ----
mkdir -p \
  compiler \
  runtime \
  backends/neo4j \
  backends/duckdb \
  plugins/api \
  plugins/estimators \
  plugins/models \
  plugins/features \
  api \
  ui \
  examples \
  benchmarks \
  data \
  docs \
  scripts \
  tests

# ---- Git + housekeeping ----
cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
*.pyo
.venv/
.env
.env.*
pip-wheel-metadata/
dist/
build/
*.egg-info/

# Node
node_modules/
.next/
out/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# OS / editor
.DS_Store
.idea/
.vscode/
*.swp

# Data / artifacts
*.db
*.duckdb
runs/
artifacts/
EOF

cat > README.md <<'EOF'
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
EOF

cat > Makefile <<'EOF'
SHELL := /bin/bash

.PHONY: help dev up down test lint demo

help:
	@echo "Targets:"
	@echo "  up     - docker compose up --build"
	@echo "  down   - docker compose down -v"
	@echo "  dev    - run API locally (requires venv)"
	@echo "  test   - run python tests"
	@echo "  demo   - run a simple demo request (requires services up)"

up:
	docker compose up --build

down:
	docker compose down -v

dev:
	python -m uvicorn api.main:app --reload --port 8000

test:
	python -m pytest -q

demo:
	bash scripts/demo.sh
EOF

# ---- Docs (CIDR spine) ----
cat > docs/design-brief.md <<'EOF'
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
EOF

cat > docs/semantics.md <<'EOF'
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
EOF

cat > docs/workflows.md <<'EOF'
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
EOF

cat > docs/paper-outline.md <<'EOF'
# Paper outline (draft)

1. Introduction (problem, trend, why boundary is wrong)
2. Background + motivating workflows
3. Design goals and principles
4. Causal DSL/IR and semantics
5. Compilation to Cypher and SQL/PGQ
6. Plugin runtime: contracts, provenance, reproducibility
7. Evaluation (portability, overhead, extensibility, case studies)
8. Related work
9. Conclusion
EOF

# ---- Python packaging ----
cat > pyproject.toml <<'EOF'
[project]
name = "causalplayground"
version = "0.0.1"
description = "Causal runtime prototype: DSL/IR -> Cypher + SQL/PGQ backends + plugin runtime"
requires-python = ">=3.11"
dependencies = [
  "fastapi>=0.110",
  "uvicorn[standard]>=0.27",
  "pydantic>=2.6",
  "neo4j>=5.20",
  "duckdb>=1.0.0",
]

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "ruff>=0.4",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

# ---- Core stubs ----
cat > compiler/ir.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Literal, Optional

Backend = Literal["neo4j", "duckdb"]

@dataclass(frozen=True)
class IRNode:
  """Base class for IR nodes."""

@dataclass(frozen=True)
class MatchPattern(IRNode):
  """
  A restricted graph pattern:
  - node labels/types and edge types
  - optional bounded path length
  """
  start_label: str
  edge_type: str
  end_label: str
  max_hops: int = 1

@dataclass(frozen=True)
class Filter(IRNode):
  input: IRNode
  predicate: str  # keep as string for v0; later become structured

@dataclass(frozen=True)
class Project(IRNode):
  input: IRNode
  columns: list[str]

@dataclass(frozen=True)
class ExtractDataset(IRNode):
  """
  Materialize a dataset for a plugin:
  e.g., treatment/outcome/covariates/features.
  """
  input: IRNode
  dataset_name: str
  schema_hint: Optional[dict[str, Any]] = None
EOF

cat > compiler/parser.py <<'EOF'
from __future__ import annotations
from typing import Any
from compiler.ir import MatchPattern, Project

def parse_dsl(query: str) -> Any:
  """
  Minimal placeholder parser.

  v0: accept a very small syntax:
    MATCH <StartLabel>-[:<EDGE>]-><EndLabel> HOPS <k> RETURN <col1,col2,...>

  Example:
    MATCH Person-[:KNOWS]->Person HOPS 2 RETURN src_id,dst_id
  """
  q = " ".join(query.strip().split())
  if not q.upper().startswith("MATCH "):
    raise ValueError("v0 DSL must start with MATCH")

  # Extremely naive parsing; replace with a real parser later (Lark/ANTLR/etc.)
  try:
    _, rest = q.split("MATCH ", 1)
    pat, rest = rest.split(" HOPS ", 1)
    hops_str, rest = rest.split(" RETURN ", 1)
    cols = [c.strip() for c in rest.split(",") if c.strip()]
    max_hops = int(hops_str.strip())
    start, edge_and_end = pat.split("-[:", 1)
    edge, end = edge_and_end.split("]->", 1)
    ir = MatchPattern(start_label=start.strip(), edge_type=edge.strip(), end_label=end.strip(), max_hops=max_hops)
    return Project(input=ir, columns=cols)
  except Exception as e:
    raise ValueError(f"Failed to parse v0 DSL: {e}") from e
EOF

cat > compiler/compile.py <<'EOF'
from __future__ import annotations
from compiler.ir import IRNode, MatchPattern, Project, Filter, ExtractDataset, Backend

def compile_to_backend(ir: IRNode, backend: Backend) -> str:
  if backend == "neo4j":
    return compile_to_cypher(ir)
  if backend == "duckdb":
    return compile_to_sqlpgq(ir)
  raise ValueError(f"Unknown backend: {backend}")

def compile_to_cypher(ir: IRNode) -> str:
  if isinstance(ir, Project) and isinstance(ir.input, MatchPattern):
    m = ir.input
    # Placeholder: produce a basic MATCH with bounded hops
    # Real code will need careful semantics + variable naming + return mapping.
    return (
      f"MATCH (a:{m.start_label})-[:{m.edge_type}*1..{m.max_hops}]->(b:{m.end_label}) "
      f"RETURN {', '.join(ir.columns) if ir.columns else 'a, b'}"
    )
  if isinstance(ir, Filter):
    q = compile_to_cypher(ir.input)
    return f"{q} WHERE {ir.predicate}"
  if isinstance(ir, ExtractDataset):
    # In v0 we treat dataset extraction as just executing its input query.
    return compile_to_cypher(ir.input)
  raise NotImplementedError(f"Cypher compilation not implemented for: {type(ir)}")

def compile_to_sqlpgq(ir: IRNode) -> str:
  if isinstance(ir, Project) and isinstance(ir.input, MatchPattern):
    m = ir.input
    # Placeholder SQL/PGQ-like shape. Actual DuckDB SQL/PGQ syntax may differ based on version.
    # We'll tighten this once we write the real adapter + tests.
    return f"""-- SQL/PGQ placeholder
SELECT {', '.join(ir.columns) if ir.columns else '*'}
FROM GRAPH_TABLE (
  MATCH (a IS {m.start_label}) -[e IS {m.edge_type}]-> (b IS {m.end_label})
  COLUMNS (a, b)
)"""
  if isinstance(ir, Filter):
    q = compile_to_sqlpgq(ir.input)
    return f"WITH q AS ({q}) SELECT * FROM q WHERE {ir.predicate}"
  if isinstance(ir, ExtractDataset):
    return compile_to_sqlpgq(ir.input)
  raise NotImplementedError(f"SQL/PGQ compilation not implemented for: {type(ir)}")
EOF

# ---- Backends ----
cat > backends/neo4j/client.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from neo4j import GraphDatabase

@dataclass(frozen=True)
class Neo4jConfig:
  uri: str
  user: str
  password: str

class Neo4jClient:
  def __init__(self, cfg: Neo4jConfig):
    self._driver = GraphDatabase.driver(cfg.uri, auth=(cfg.user, cfg.password))

  def close(self) -> None:
    self._driver.close()

  def run(self, cypher: str, params: dict | None = None) -> list[dict]:
    params = params or {}
    with self._driver.session() as session:
      res = session.run(cypher, params)
      return [r.data() for r in res]
EOF

cat > backends/duckdb/client.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
import duckdb

@dataclass(frozen=True)
class DuckDBConfig:
  path: str = ":memory:"

class DuckDBClient:
  def __init__(self, cfg: DuckDBConfig):
    self._con = duckdb.connect(cfg.path)

  def close(self) -> None:
    self._con.close()

  def run(self, sql: str, params: dict | None = None) -> list[dict]:
    # DuckDB python binding uses positional params typically; keep v0 simple.
    _ = params
    rel = self._con.sql(sql)
    cols = rel.columns
    rows = rel.fetchall()
    return [dict(zip(cols, row)) for row in rows]
EOF

# ---- Runtime ----
cat > runtime/planner.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from compiler.ir import IRNode, Backend

@dataclass(frozen=True)
class Plan:
  backend: Backend
  query: str

def choose_backend(ir: IRNode, preferred: Backend | None = None) -> Backend:
  # v0 policy: honor preferred, otherwise default to duckdb
  return preferred or "duckdb"
EOF

cat > runtime/engine.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from compiler.parser import parse_dsl
from compiler.compile import compile_to_backend
from runtime.planner import choose_backend, Plan
from backends.neo4j.client import Neo4jClient, Neo4jConfig
from backends.duckdb.client import DuckDBClient, DuckDBConfig

@dataclass(frozen=True)
class RunResult:
  backend: str
  compiled_query: str
  rows: list[dict]

def run_query(
  dsl: str,
  backend_preference: str | None = None,
  neo4j_cfg: Neo4jConfig | None = None,
  duckdb_cfg: DuckDBConfig | None = None,
) -> RunResult:
  ir = parse_dsl(dsl)
  backend = choose_backend(ir, backend_preference)  # type: ignore[arg-type]
  compiled = compile_to_backend(ir, backend)  # type: ignore[arg-type]

  if backend == "neo4j":
    if neo4j_cfg is None:
      raise ValueError("neo4j_cfg required when backend is neo4j")
    client = Neo4jClient(neo4j_cfg)
    try:
      rows = client.run(compiled)
    finally:
      client.close()
    return RunResult(backend="neo4j", compiled_query=compiled, rows=rows)

  if backend == "duckdb":
    client = DuckDBClient(duckdb_cfg or DuckDBConfig())
    try:
      rows = client.run(compiled)
    finally:
      client.close()
    return RunResult(backend="duckdb", compiled_query=compiled, rows=rows)

  raise ValueError(f"Unknown backend: {backend}")
EOF

# ---- Plugins ----
cat > plugins/api/base.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from typing import Protocol, Any

@dataclass(frozen=True)
class PluginContext:
  run_id: str
  seed: int = 0

class Plugin(Protocol):
  name: str
  version: str

  def run(self, dataset: Any, ctx: PluginContext) -> dict:
    ...
EOF

cat > plugins/registry.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
from plugins.api.base import Plugin

@dataclass
class RegisteredPlugin:
  factory: Callable[[], Plugin]

_REGISTRY: dict[str, RegisteredPlugin] = {}

def register(name: str, factory: Callable[[], Plugin]) -> None:
  _REGISTRY[name] = RegisteredPlugin(factory=factory)

def load(name: str) -> Plugin:
  if name not in _REGISTRY:
    raise KeyError(f"Plugin not found: {name}")
  return _REGISTRY[name].factory()
EOF

cat > plugins/estimators/dummy_ate.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from plugins.api.base import PluginContext
from plugins.registry import register

@dataclass
class DummyATE:
  name: str = "dummy_ate"
  version: str = "0.0.1"

  def run(self, dataset, ctx: PluginContext) -> dict:
    _ = dataset
    return {"estimator": self.name, "version": self.version, "ate": 0.0, "seed": ctx.seed}

def _factory():
  return DummyATE()

register("dummy_ate", _factory)
EOF

# ---- FastAPI ----
cat > api/main.py <<'EOF'
from __future__ import annotations
import os
from fastapi import FastAPI
from pydantic import BaseModel
from runtime.engine import run_query
from backends.neo4j.client import Neo4jConfig
from backends.duckdb.client import DuckDBConfig

app = FastAPI(title="Causal Runtime API", version="0.0.1")

class QueryRequest(BaseModel):
  query: str
  backend: str | None = None  # "auto" | "neo4j" | "duckdb"

class QueryResponse(BaseModel):
  backend: str
  compiled_query: str
  rows: list[dict]

@app.get("/health")
def health():
  return {"ok": True}

@app.post("/query", response_model=QueryResponse)
def query(req: QueryRequest):
  backend = None if req.backend in (None, "", "auto") else req.backend

  neo4j_cfg = Neo4jConfig(
    uri=os.getenv("NEO4J_URI", "bolt://localhost:7687"),
    user=os.getenv("NEO4J_USER", "neo4j"),
    password=os.getenv("NEO4J_PASSWORD", "password"),
  )

  duckdb_cfg = DuckDBConfig(path=os.getenv("DUCKDB_PATH", ":memory:"))

  res = run_query(req.query, backend_preference=backend, neo4j_cfg=neo4j_cfg, duckdb_cfg=duckdb_cfg)
  return QueryResponse(backend=res.backend, compiled_query=res.compiled_query, rows=res.rows)
EOF

# ---- Next.js UI placeholders ----
cat > ui/README.md <<'EOF'
# UI (Next.js)

This folder is a placeholder. Initialize Next.js here, e.g.:

- `cd ui`
- `npx create-next-app@latest . --ts`
- Then add a simple page that calls the Python API at http://localhost:8000/query
EOF

# ---- Docker Compose ----
cat > compose.yaml <<'EOF'
services:
  neo4j:
    image: neo4j:5
    environment:
      - NEO4J_AUTH=neo4j/password
    ports:
      - "7474:7474"
      - "7687:7687"

  api:
    image: python:3.11-slim
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      - NEO4J_URI=bolt://neo4j:7687
      - NEO4J_USER=neo4j
      - NEO4J_PASSWORD=password
      - DUCKDB_PATH=/app/data/demo.duckdb
    command: bash -lc "pip install -e . && uvicorn api.main:app --host 0.0.0.0 --port 8000"
    ports:
      - "8000:8000"
    depends_on:
      - neo4j

  ui:
    image: node:18-slim
    working_dir: /app/ui
    volumes:
      - ./:/app
    command: bash -lc "if [ ! -f package.json ]; then echo 'UI not initialized yet. See ui/README.md'; sleep infinity; else npm install && npm run dev -- --port 3000 --hostname 0.0.0.0; fi"
    ports:
      - "3000:3000"
    depends_on:
      - api
EOF

# ---- Demo script ----
cat > scripts/demo.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required for demo"
  exit 1
fi

echo "Calling API demo query..."
curl -sS -X POST "http://localhost:8000/query" \
  -H "Content-Type: application/json" \
  -d '{"query":"MATCH Person-[:KNOWS]->Person HOPS 1 RETURN a,b","backend":"auto"}' | sed 's/},{/},\n{/g'
echo
EOF
chmod +x scripts/demo.sh

# ---- Tests ----
cat > tests/test_parser.py <<'EOF'
from compiler.parser import parse_dsl
from compiler.ir import Project, MatchPattern

def test_parse_v0():
  ir = parse_dsl("MATCH Person-[:KNOWS]->Person HOPS 2 RETURN src,dst")
  assert isinstance(ir, Project)
  assert isinstance(ir.input, MatchPattern)
  assert ir.input.max_hops == 2
  assert ir.columns == ["src", "dst"]
EOF

cat > tests/test_compile.py <<'EOF'
from compiler.parser import parse_dsl
from compiler.compile import compile_to_backend

def test_compile_cypher():
  ir = parse_dsl("MATCH Person-[:KNOWS]->Person HOPS 2 RETURN a,b")
  q = compile_to_backend(ir, "neo4j")
  assert "MATCH" in q and "RETURN" in q

def test_compile_sqlpgq():
  ir = parse_dsl("MATCH Person-[:KNOWS]->Person HOPS 2 RETURN a,b")
  q = compile_to_backend(ir, "duckdb")
  assert "GRAPH_TABLE" in q or "SELECT" in q
EOF

# ---- Convenience: init git repo (optional) ----
if command -v git >/dev/null 2>&1; then
  git init -q
  git add .
  git commit -qm "Initialize causalplayground monorepo skeleton"
  echo "Initialized git repo and committed initial skeleton."
else
  echo "git not found; skipped git init."
fi

echo "Done. Next steps:"
echo "  cd ${REPO_NAME}"
echo "  docker compose up --build"
echo "  # In another terminal:"
echo "  make demo"

