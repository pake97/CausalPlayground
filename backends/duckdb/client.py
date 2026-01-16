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
