---
description: Write an implementation plan from a signed-off spec
argument-hint: "AOS-###"
---

Plan backlog item $ARGUMENTS.

1. Read the spec in `backlog/specs/`. If none exists or it lacks sign-off, stop and run `/spec` first.
2. Explore the codebase for the touched areas — use the `scout` subagent for anything beyond a couple of files; consult `memory/system-reference.md` before opening source.
3. Write `backlog/plans/$ARGUMENTS-<slug>.md` from `backlog/plans/TEMPLATE.md`: ordered steps, exact files to create/modify, test plan mapping each acceptance criterion to a test, risks/rollback.
4. Set backlog status to `planned`. For items touching >3 files or any schema change, ask the user to sign off before `/implement`.
