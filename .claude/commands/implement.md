---
description: Implement a planned item using TDD
argument-hint: "AOS-###"
---

Implement backlog item $ARGUMENTS strictly by TDD.

1. Read the plan in `backlog/plans/` (stop if missing → `/plan-item`). Set backlog status to `in-progress`.
2. For each acceptance criterion, in plan order:
   a. Write the failing test first; run it; confirm it fails for the right reason.
   b. Write the minimum code to pass; run the test until green.
   c. Refactor if needed; re-run.
3. Commit in small units with messages like `AOS-###: <what>`; never batch unrelated changes.
4. After all criteria pass, run the touched suite(s) fully, then say: "ready for /verify".

If you hit a non-obvious failure (env quirk, library trap), append it to `memory/gotchas.md` immediately.
