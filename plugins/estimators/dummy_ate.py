from __future__ import annotations
from dataclasses import dataclass
from plugins.api.base import PluginContext
from plugins.registry import register

@dataclass
class DummyATE:
  name: str = "dummy_ate"
  version: str = "0.0.1"

  def run(self, dataset, ctx: PluginContext) -> dict:
    _ = dataset
    return {"estimator": self.name, "version": self.version, "ate": 0.0, "seed": ctx.seed}

def _factory():
  return DummyATE()

register("dummy_ate", _factory)
