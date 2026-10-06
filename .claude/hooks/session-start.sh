#!/usr/bin/env bash
# SessionStart hook: stamp session start into the session log and surface open work.
# Exit 0 always — this hook must never block a session.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="$ROOT/memory/sessions"
mkdir -p "$LOG_DIR"
echo "$(date '+%Y-%m-%d %H:%M:%S') session started" >> "$LOG_DIR/sessions.log"

# Surface in-flight backlog items to Claude's context (stdout of SessionStart is added as context).
if [ -f "$ROOT/backlog/backlog.md" ]; then
  OPEN=$(grep -E '\| *(in-progress|verify|planned|spec) *\|' "$ROOT/backlog/backlog.md" 2>/dev/null | head -5)
  if [ -n "$OPEN" ]; then
    echo "In-flight backlog items:"
    echo "$OPEN"
  fi
fi
exit 0
