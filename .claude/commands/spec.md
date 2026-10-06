---
description: Write a spec for a backlog item (required before planning)
argument-hint: "AOS-###"
---

Write a spec for backlog item $ARGUMENTS.

1. Read the item's row in `backlog/backlog.md` and `backlog/specs/TEMPLATE.md`. Skim `memory/system-reference.md` and `memory/gotchas.md` for relevant context.
2. Ask the user only the questions the template forces you to answer and that you cannot infer (batch them; aim for ≤4).
3. Write `backlog/specs/$ARGUMENTS-<slug>.md` from the template. Acceptance criteria must each be independently testable — they become the test list in `/implement`.
4. Set the backlog row status to `spec` and ask the user to sign off.

Do not write any implementation code.
