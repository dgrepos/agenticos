#!/usr/bin/env bash
# Push long-term memory (learnings + gotchas) upstream to the AgenticOS template repo.
#
# Long-term entries are worth more in the template than in one project: every repo later
# made from the template inherits them. This project's memory/ is where they get written first;
# this script promotes the ones the template does not have yet.
#
#   bash scripts/sync-memory.sh                 show what would sync, change nothing
#   bash scripts/sync-memory.sh --apply         append + commit in the template repo
#   bash scripts/sync-memory.sh --apply --push  ...and push to its GitHub remote
#
# The template location is resolved in this order:
#   1. $AGENTICOS_TEMPLATE_REPO
#   2. .agenticos/template-path (written by the first interactive run; gitignored)
#   3. an interactive prompt, which then remembers your answer
# Deliberately not a hook: pushing to a shared repo is an outward-facing action and
# should stay a decision, not a side effect of editing a file.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/.agenticos/template-path"

resolve_template() {
  if [ -n "${AGENTICOS_TEMPLATE_REPO:-}" ]; then
    printf '%s' "$AGENTICOS_TEMPLATE_REPO"; return
  fi
  if [ -s "$CONFIG" ]; then
    head -1 "$CONFIG"; return
  fi
  # No configuration yet. Ask once and remember, rather than guessing at someone's
  # directory layout: a wrong default here writes memory into the wrong repo.
  if [ ! -t 0 ]; then
    echo "error: template repo not configured and no TTY to ask on." >&2
    echo "       set AGENTICOS_TEMPLATE_REPO=/path/to/AgenticOS and re-run." >&2
    exit 1
  fi
  echo "Where is your AgenticOS template checkout?" >&2
  echo "(the repo this project was created from. If THIS repo is the template, or you" >&2
  echo " only cloned the public one, there is nothing to promote: leave blank to cancel.)" >&2
  printf 'path: ' >&2
  read -r answer
  answer="${answer/#\~/$HOME}"
  if [ -z "$answer" ]; then
    echo "cancelled; nothing synced." >&2
    exit 0
  fi
  if [ ! -d "$answer/.git" ]; then
    echo "error: no git repo at: $answer" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$CONFIG")"
  printf '%s\n' "$answer" > "$CONFIG"
  echo "saved to .agenticos/template-path (gitignored); override with AGENTICOS_TEMPLATE_REPO." >&2
  printf '%s' "$answer"
}

TEMPLATE="$(resolve_template)"

APPLY=0
PUSH=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --push) PUSH=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

if [ ! -d "$TEMPLATE/.git" ]; then
  echo "error: template repo not found at: $TEMPLATE" >&2
  echo "       set AGENTICOS_TEMPLATE_REPO to its path, or delete" >&2
  echo "       .agenticos/template-path to be asked again." >&2
  exit 1
fi

# This script ships in the template, so every copy inherits it, including the template
# itself. Promoting the template into the template is a no-op worth naming rather than a
# confusing diff of a file against itself.
if [ "$(cd "$ROOT" && pwd -P)" = "$(cd "$TEMPLATE" && pwd -P)" ]; then
  echo "this IS the template repo ($ROOT)."
  echo "Long-term memory written here is already in the right place; nothing to promote."
  exit 0
fi

# Entries listed here are never promoted, even though they are long-term. Without it,
# anything deliberately deleted from the template would come straight back on the next
# run, since candidates are chosen by diffing against the template.
EXCLUDE="$ROOT/memory/.sync-exclude"

exclude_filter() {
  if [ -s "$EXCLUDE" ] && grep -qv '^\s*\(#.*\)\?$' "$EXCLUDE" 2>/dev/null; then
    grep -vF -f <(grep -v '^\s*\(#.*\)\?$' "$EXCLUDE") || true
  else
    cat
  fi
}

TOTAL=0
SYNCED=0
SKIPPED=0

for file in learnings gotchas; do
  src="$ROOT/memory/$file.md"
  dst="$TEMPLATE/memory/$file.md"
  [ -f "$src" ] || continue
  if [ ! -f "$dst" ]; then
    echo "error: $dst does not exist; is $TEMPLATE really the template repo?" >&2
    exit 1
  fi

  # Entries are one line each, starting "- ". Dedup on the whole line, so a reworded
  # entry counts as new: better a near-duplicate to prune than a lost insight.
  candidates="$(grep '^- ' "$src" | grep -vxF -f <(grep '^- ' "$dst") || true)"
  missing="$(printf '%s' "$candidates" | exclude_filter)"

  before="$(printf '%s' "$candidates" | grep -c '^- ' || true)"
  count="$(printf '%s' "$missing" | grep -c '^- ' || true)"
  SKIPPED=$((SKIPPED + before - count))
  TOTAL=$((TOTAL + count))

  echo "== $file.md: $count entry(ies) not in the template =="
  if [ "$count" -eq 0 ]; then
    continue
  fi
  printf '%s\n' "$missing" | cut -c1-140 | sed 's/^/   /'

  if [ "$APPLY" -eq 1 ]; then
    printf '%s\n' "$missing" >> "$dst"
    SYNCED=$((SYNCED + count))
  fi
done

echo ""
# Never let a skip be silent: a caller should be able to see that coverage was bounded.
if [ "$SKIPPED" -gt 0 ]; then
  echo "$SKIPPED entry(ies) held back as project-specific (memory/.sync-exclude)"
fi

if [ "$TOTAL" -eq 0 ]; then
  echo "template memory is already up to date."
  exit 0
fi

if [ "$APPLY" -eq 0 ]; then
  echo "dry run: nothing written. Re-run with --apply to append and commit."
  exit 0
fi

cd "$TEMPLATE"
git add memory/learnings.md memory/gotchas.md
if git diff --cached --quiet; then
  echo "nothing staged; template already had these entries."
  exit 0
fi

git commit -q -m "memory: promote $SYNCED long-term entry(ies) from project work

Synced by scripts/sync-memory.sh. Long-term learnings and gotchas belong in the
template so every repo made from it inherits them, not just the project that hit them."
echo "committed in $TEMPLATE"
git --no-pager log --oneline -1

if [ "$PUSH" -eq 1 ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "pushing $branch to origin"
  if ! git push origin "$branch"; then
    echo "" >&2
    echo "push failed. If you received this repo as a template copy, you have read-only" >&2
    echo "access to the upstream template and this sync is not meant for you: your" >&2
    echo "memory/ belongs to your own repo. The commit above is local and can be" >&2
    echo "dropped with: git -C \"$TEMPLATE\" reset --hard HEAD~1" >&2
    exit 1
  fi
else
  echo ""
  echo "not pushed. Run with --push, or push yourself from $TEMPLATE"
fi
