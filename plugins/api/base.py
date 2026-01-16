from __future__ import annotations
from dataclasses import dataclass
from typing import Protocol, Any

@dataclass(frozen=True)
class PluginContext:
  run_id: str
  seed: int = 0

class Plugin(Protocol):
  name: str
  version: str

  def run(self, dataset: Any, ctx: PluginContext) -> dict:
    ...
