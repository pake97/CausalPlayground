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
