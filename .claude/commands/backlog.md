---
description: Add, groom, or review backlog items
argument-hint: "[new item description | groom | show]"
---

Manage `backlog/backlog.md`. Input: $ARGUMENTS

- If the input describes work: add a row with the next `AOS-###` ID, status `todo`, today's date, and a one-line value statement ("so that …"). Confirm the ID back to the user in one line.
- If input is `groom`: review all `todo` items, propose priority order and flag stale/duplicate items. Change nothing without confirmation.
- If input is `show` or empty: print a compact table of non-done items only.

Never delete rows — set status `dropped` with a reason.
