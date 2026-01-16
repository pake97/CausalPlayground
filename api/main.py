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
