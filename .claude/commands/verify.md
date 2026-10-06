---
description: Auto-test and adversarially verify an implemented item
argument-hint: "AOS-###"
---

Verify backlog item $ARGUMENTS. Set backlog status to `verify`.

1. Run `bash scripts/test-all.sh`. All suites must pass — fix failures before continuing.
2. If the item has user-visible UI, run the relevant Playwright specs in `e2e/` (add a smoke spec for the new flow if none exists — that's part of the item, not extra).
3. Launch the `verifier` subagent with: the spec file path, `git diff main...HEAD` (or the item's commits), and instructions to try to refute that each acceptance criterion is met.
4. Fix anything the verifier confirms; re-run step 1.
5. Report a checklist: each acceptance criterion → the test/evidence that proves it. Then tell the user the item is ready for `/done`.
