from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
from plugins.api.base import Plugin

@dataclass
class RegisteredPlugin:
  factory: Callable[[], Plugin]

_REGISTRY: dict[str, RegisteredPlugin] = {}

def register(name: str, factory: Callable[[], Plugin]) -> None:
  _REGISTRY[name] = RegisteredPlugin(factory=factory)

def load(name: str) -> Plugin:
  if name not in _REGISTRY:
    raise KeyError(f"Plugin not found: {name}")
  return _REGISTRY[name].factory()
