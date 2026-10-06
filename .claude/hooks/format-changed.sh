#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): auto-format the file Claude just changed.
# Reads the tool payload from stdin, formats by extension. Never blocks (exit 0).
set -u
PAYLOAD=$(cat)
PYBIN=$(command -v python3 || command -v python) || exit 0
FILE=$(printf '%s' "$PAYLOAD" | "$PYBIN" -c "import sys,json;d=json.load(sys.stdin);print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

case "$FILE" in
  *.py)
    if command -v uv >/dev/null 2>&1 && [ -f "$ROOT/backend/pyproject.toml" ]; then
      (cd "$ROOT/backend" && uv run ruff format "$FILE" >/dev/null 2>&1; uv run ruff check --fix "$FILE" >/dev/null 2>&1)
    fi
    ;;
  *.ts|*.tsx|*.css|*.json)
    case "$FILE" in
      */node_modules/*|*.claude/*) exit 0 ;;
    esac
    if [ -x "$ROOT/frontend/node_modules/.bin/prettier" ]; then
      "$ROOT/frontend/node_modules/.bin/prettier" --write "$FILE" >/dev/null 2>&1
    fi
    ;;
esac
exit 0
