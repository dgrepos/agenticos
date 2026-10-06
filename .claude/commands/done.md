---
description: Close out a verified item and update memory
argument-hint: "AOS-###"
---

Close backlog item $ARGUMENTS. Refuse if `/verify` hasn't passed this session.

1. Set the backlog row to `done` with today's date.
2. Append one line to `memory/features.md` (newest first): `- AOS-### <name> — <what shipped> (YYYY-MM-DD)`.
3. Add durable insights to `memory/learnings.md` / `memory/gotchas.md` (read first; no duplicates; skip if nothing durable).
4. If files/modules were added, moved, or deleted: run `bash scripts/graphify.sh` to refresh the code map.
5. Suggest `/compact` if the session continues with new work.
