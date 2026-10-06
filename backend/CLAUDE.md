# backend/

FastAPI + SQLAlchemy 2.0 + Postgres. Run everything through `uv` from this directory.

- Test: `uv run pytest -q` · Lint: `uv run ruff check --fix .` · Dev: `uv run uvicorn app.main:app --reload`
- Layering: `app/api/` (routes) → `app/core/` (config/services) → `app/models/` (SQLAlchemy). Lower layers never import upward.
- Full conventions: `.claude/rules/backend.md` (auto-loads when editing files here).
