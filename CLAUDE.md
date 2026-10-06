# AgenticOS

Full-stack template: FastAPI backend (`backend/`), React+Vite frontend (`frontend/`), SQLite dev DB (hosted Postgres in prod), Playwright e2e (`e2e/`).

## Commands

- Backend: `cd backend && uv run pytest` (test), `uv run ruff check --fix .` (lint), `uv run uvicorn app.main:app --reload` (dev)
- Frontend: `cd frontend && npm test` (test), `npm run dev` (dev), `npm run build` (typecheck+build)
- E2E: `cd e2e && npx playwright test`
- DB: SQLite (`backend/app.db`, zero setup). Production: hosted Postgres — set `DATABASE_URL` in `backend/.env`; same SQLAlchemy code
- Everything: `scripts/dev.sh` (run), `scripts/test-all.sh` (all suites)
- Code map: `bash scripts/graphify.sh` → refreshes `memory/system-reference.md`

## Workflow (mandatory)

Every work item flows: backlog → spec → plan → implement (TDD) → verify → done.
Use the slash commands: `/backlog`, `/spec`, `/plan-item`, `/implement`, `/verify`, `/done`.
Never implement anything not traceable to a backlog item. Details: `.claude/rules/workflow.md`.

## Memory (repo-local)

Before starting non-trivial work, skim `memory/system-reference.md` (code map) and `memory/gotchas.md`.
Record durable learnings via `/done` or `/wrap-up`. Protocol: `.claude/rules/memory.md`.
If you keep your own fork of this template, promote long-term `learnings.md`/`gotchas.md`
entries to it with `bash scripts/sync-memory.sh --apply --push`, so every later project
inherits them. Optional: skip it and your memory just stays in this repo.

## Hard rules

- Tool priority: CLI > API > MCP. Prefer a shell command or script over an API call, and an API call from a script over adding an MCP server. Rationale: `.claude/rules/tool-priority.md`.
- Minimize tokens: delegate exploration to the `scout` subagent; don't cat whole files when a grep will do; keep responses terse.
- Env convention: `.env.example` (committed schema) → `.env` (real values) → `.env.local` (personal overrides). Never read or write `.env`/`.env.local`; edit `.env.example` when adding a variable.
- All times/IDs in logs: ISO dates, kebab-case slugs.
