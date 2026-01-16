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
