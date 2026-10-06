#!/usr/bin/env bash
# Start the dev stack: backend + frontend (SQLite needs nothing). Ctrl-C stops everything.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
trap 'kill 0' EXIT

(cd "$ROOT/backend" && uv run uvicorn app.main:app --reload --port 8000) &
(cd "$ROOT/frontend" && npm run dev) &
wait
