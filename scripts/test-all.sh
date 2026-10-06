#!/usr/bin/env bash
# Run every test suite. Used by /verify and CI. Fails fast per suite, reports all.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

echo "== backend (pytest) =="
if [ -f "$ROOT/backend/pyproject.toml" ]; then
  (cd "$ROOT/backend" && uv run pytest -q) || FAIL=1
fi

echo "== frontend (vitest + tsc) =="
if [ -f "$ROOT/frontend/package.json" ] && [ -d "$ROOT/frontend/node_modules" ]; then
  (cd "$ROOT/frontend" && npm test -- --run && npx tsc --noEmit) || FAIL=1
else
  echo "skipped (run: cd frontend && npm install)"
fi

echo "== e2e (playwright) =="
if [ -d "$ROOT/e2e/node_modules" ]; then
  (cd "$ROOT/e2e" && npx playwright test --reporter=line) || FAIL=1
else
  echo "skipped (run: cd e2e && npm install && npx playwright install chromium)"
fi

[ "$FAIL" -eq 0 ] && echo "ALL SUITES PASSED" || echo "FAILURES ABOVE"
exit $FAIL
