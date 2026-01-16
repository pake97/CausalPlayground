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
