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
