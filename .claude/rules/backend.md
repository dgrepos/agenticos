---
paths:
  - "backend/**"
---

# Backend rules (FastAPI + Postgres)

- Python 3.12+, managed with `uv`. Add deps via `uv add`, never edit the lockfile by hand.
- Layout: routes in `app/api/`, settings in `app/core/config.py` (pydantic-settings, env-driven), SQLAlchemy models in `app/models/`.
- Every endpoint: pydantic request/response models, no bare dicts. Raise `HTTPException` with explicit status codes.
- DB access through SQLAlchemy 2.0 style (`select()`, sessions from dependency injection). Migrations via Alembic; never mutate schema ad hoc.
- Tests mirror `app/` structure under `tests/`; use `httpx.AsyncClient` + pytest-asyncio against the app, not a live server.
- Lint/format is ruff (config in `pyproject.toml`); it runs automatically via hook on edit.
