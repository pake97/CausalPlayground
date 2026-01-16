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
