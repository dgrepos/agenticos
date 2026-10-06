#!/usr/bin/env bash
# Cross-platform launcher for graphify.py.
# Resolves a REAL Python by executing candidates (Windows ships a decoy `python`
# App-Execution-Alias that exists but only opens the Microsoft Store — existence
# checks lie; execution checks don't). Final fallback: uv supplies its own Python.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
works() { "$@" -c "import sys" >/dev/null 2>&1; }

if works python3; then exec python3 "$DIR/graphify.py" "$@"
elif works python; then exec python "$DIR/graphify.py" "$@"
elif command -v py >/dev/null 2>&1 && py -3 -c "import sys" >/dev/null 2>&1; then exec py -3 "$DIR/graphify.py" "$@"
elif command -v uv >/dev/null 2>&1; then
  # uv downloads a managed Python automatically if none exists — guaranteed real interpreter.
  exec uv run --no-project --python 3.12 python "$DIR/graphify.py" "$@"
else
  echo "graphify: no working Python found and uv is missing — install uv (https://docs.astral.sh/uv)" >&2
  exit 1
fi
