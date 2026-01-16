SHELL := /bin/bash

.PHONY: help dev up down test lint demo

help:
	@echo "Targets:"
	@echo "  up     - docker compose up --build"
	@echo "  down   - docker compose down -v"
	@echo "  dev    - run API locally (requires venv)"
	@echo "  test   - run python tests"
	@echo "  demo   - run a simple demo request (requires services up)"

up:
	docker compose up --build

down:
	docker compose down -v

dev:
	python -m uvicorn api.main:app --reload --port 8000

test:
	python -m pytest -q

demo:
	bash scripts/demo.sh
