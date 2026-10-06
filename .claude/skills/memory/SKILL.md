---
name: memory
description: How to use this repo's local memory system (learnings, gotchas, features, system reference, session logs). Use when reading or writing anything under memory/, or when the user asks what the project "knows" or what happened in past sessions.
---

# Repo memory system

Layout (all under `memory/`, versioned in git):

- `learnings.md` — durable technical insights. Append-only in spirit; consolidate duplicates.
- `gotchas.md` — traps and env quirks. Write the moment one is hit, not at wrap-up.
- `features.md` — one line per shipped feature, newest first, keyed by AOS ID.
- `system-reference.md` — GENERATED code map. Never hand-edit; refresh with `bash scripts/graphify.sh`.
- `sessions/YYYY-MM-DD-<slug>.md` — session work logs written by `/wrap-up`. The SessionStart hook stamps session starts into `sessions/sessions.log`.

## Reading (when to consult)

- "Where is / how does" → `system-reference.md` first, grep second.
- Before touching an unfamiliar area → scan `gotchas.md` for that area's name.
- "What happened last time / status" → newest files in `sessions/`, then `features.md`.

## Writing (format contract)

- learnings/gotchas entry: `- YYYY-MM-DD — <1–2 sentences, concrete, no narrative>`
- features entry: `- AOS-### <name> — <what shipped> (YYYY-MM-DD)`
- Always read the target file before appending; merge with an existing entry rather than duplicating.
- These files are loaded by future sessions: brevity is a feature. If a file exceeds ~150 lines, consolidate oldest entries.
