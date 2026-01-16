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
