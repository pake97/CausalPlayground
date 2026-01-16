#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required for demo"
  exit 1
fi

echo "Calling API demo query..."
curl -sS -X POST "http://localhost:8000/query" \
  -H "Content-Type: application/json" \
  -d '{"query":"MATCH Person-[:KNOWS]->Person HOPS 1 RETURN a,b","backend":"auto"}' | sed 's/},{/},\n{/g'
echo
