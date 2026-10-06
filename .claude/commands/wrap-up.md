---
description: End-of-session log + memory update
---

Wrap up this working session.

1. Write `memory/sessions/$(date +%F)-<slug>.md` (slug from the session's main topic; if the file exists, append a new section):
   - **Did**: bullet list of concrete outcomes (commits, items advanced, decisions)
   - **Open**: what's unfinished and the exact next step
   - **Items touched**: AOS IDs and their new statuses
2. Update `memory/learnings.md` / `memory/gotchas.md` with anything durable from this session (read first; no duplicates).
3. If code structure changed and the map wasn't refreshed: run `bash scripts/graphify.sh`.
4. Reply with a 3-line summary: done / open / suggested next command.
