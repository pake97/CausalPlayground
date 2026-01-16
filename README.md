# Causal Playground

Monorepo skeleton for a CIDR-style systems prototype:
- A minimal causal DSL/IR compiled to two backends:
  - Neo4j (Cypher)
  - DuckDB (SQL/PGQ)
- A plugin runtime for causal estimators + ML models
- A Python API (FastAPI) and Next.js UI

## Quickstart (dev)
1) Install prerequisites: Docker + Docker Compose, Python 3.11+, Node 18+
2) Start services:
   - `docker compose up --build`
3) API:
   - http://localhost:8000
4) UI:
   - http://localhost:3000

## Repo structure
- `compiler/` DSL/IR + compilation to backend queries
- `backends/` Neo4j + DuckDB adapters
- `runtime/` orchestration, planning, provenance
- `plugins/` plugin API + reference plugins
- `api/` FastAPI service
- `ui/` Next.js frontend
- `docs/` paper-facing design docs + semantics + workflows



## 📦 Using `make` in this repository

This repository uses a **Makefile** as the single entry point for common development and demo tasks.

The goal is:

* one canonical command per task
* no need to remember long Docker / Python / Node commands
* reproducible workflows for development, demos, and evaluation

### Prerequisites

* Docker + Docker Compose
* Python 3.11+
* GNU `make` (installed by default on Linux/macOS)

---

### 🔍 See available commands

```bash
make help
```

This prints a short description of all supported targets.

---

### ▶️ Start the full system (recommended)

```bash
make up
```

This:

* starts Neo4j
* starts the Python API (FastAPI)
* starts the Next.js UI (if initialized)

Services will be available at:

* API: [http://localhost:8000](http://localhost:8000)
* UI: [http://localhost:3000](http://localhost:3000)
* Neo4j Browser: [http://localhost:7474](http://localhost:7474)

Stop everything with:

```bash
make down
```

---

### 🧪 Run tests

```bash
make test
```

Runs all Python unit tests (DSL parsing, compilation, etc.).

This is the **minimum requirement before merging changes**.

---

### 🛠️ Local API development (without Docker)

```bash
make dev
```

Runs the FastAPI server locally using `uvicorn`.

Use this when:

* working only on the compiler/runtime
* debugging logic without Docker overhead

> Note: this requires Python dependencies to be installed locally.

---

### 🚀 Run an end-to-end demo

```bash
make demo
```

Runs a predefined “golden path” demo:

* sends a DSL query to the API
* executes it on the selected backend
* prints results

This command is expected to work **at all times** and is used for:

* sanity checks
* demos
* paper artifacts

---

### 🧠 Why we use `make`

We use `make` as a **task runner**, not as a build system.

Design principles:

* one command per task (`up`, `test`, `demo`)
* no hidden steps
* same commands for all contributors
* scripts encode “how the system should be run”

If something is not runnable via `make`, it is considered incomplete.

---

### 🧩 Adding new commands

To add a new command:

1. Edit the `Makefile`
2. Add a new target:

   ```make
   my-task:
   	<command>
   ```
3. Document it in this README

Example:

```make
bench:
	python benchmarks/run.py
```

Then run:

```bash
make bench
```

---

## ✅ Expected workflow (for contributors)

Typical development loop:

```bash
make test
make up
make demo
```

Before opening a pull request:

* `make test` must pass
* `make demo` must run successfully

