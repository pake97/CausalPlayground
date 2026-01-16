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
