---
name: graphify
description: Generate or interpret the repository code map (memory/system-reference.md). Use when the code map is stale, missing, or when planning work that spans modules and you need the dependency picture.
---

# Graphify — repo code map

`scripts/graphify.py` (stdlib-only, no deps) crawls the repo and writes `memory/system-reference.md`:

- **Python** (`backend/`): parsed with `ast` — modules, classes, functions, first docstring line, intra-project imports.
- **TypeScript/TSX** (`frontend/src/`, `e2e/`): regex-parsed — exported components/functions/types and relative imports.
- Output: per-module tree + an import edge list (the "graph"), size-capped to stay cheap to load.

## Usage

```bash
bash scripts/graphify.sh            # full refresh
bash scripts/graphify.sh --check    # exit 1 if map is stale vs git HEAD file list
```

Run after any change that adds/moves/deletes files or public symbols (`/done` step 4 covers this). Never hand-edit the output file.

## Interpreting

- "Where should X live?" → find the module whose summary matches; check its import edges for layering (api → models, never the reverse).
- Fan-in (many modules import it) = high blast radius: plan + verify such changes more carefully.
- If the map disagrees with the code, the map is stale — regenerate before trusting it.

## Extending (RAG later)

If this repo outgrows grep+map, the agreed next step is a local embeddings index (sqlite-vec) behind a `scripts/ask-codebase.py` CLI — still CLI-first, no MCP server. Keep graphify as the cheap default.
