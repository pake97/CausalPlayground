from compiler.parser import parse_dsl
from compiler.ir import Project, MatchPattern

def test_parse_v0():
  ir = parse_dsl("MATCH Person-[:KNOWS]->Person HOPS 2 RETURN src,dst")
  assert isinstance(ir, Project)
  assert isinstance(ir.input, MatchPattern)
  assert ir.input.max_hops == 2
  assert ir.columns == ["src", "dst"]
