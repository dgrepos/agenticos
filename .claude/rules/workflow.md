# Delivery workflow

Every unit of work follows this pipeline. No stage may be skipped.

```
backlog → spec → plan → implement (TDD) → verify → done
```

1. **Backlog** (`/backlog`): every idea/bug/task becomes a row in `backlog/backlog.md` with an ID (`AOS-###`), status, and one-line value statement.
2. **Spec** (`/spec AOS-###`): before any code, write `backlog/specs/AOS-###-<slug>.md` from the template — problem, acceptance criteria (testable), out-of-scope. Get user sign-off.
3. **Plan** (`/plan-item AOS-###`): write `backlog/plans/AOS-###-<slug>.md` — files to touch, test plan, risks. Use plan mode for exploration. Get user sign-off for large items.
4. **Implement** (`/implement AOS-###`): TDD — write failing tests from the acceptance criteria first, then code until green. Small commits referencing the ID.
5. **Verify** (`/verify AOS-###`): run `scripts/test-all.sh`; then have the `verifier` subagent adversarially review the diff against the spec in a fresh context.
6. **Done** (`/done AOS-###`): mark backlog row done, update `memory/features.md`, record learnings/gotchas, refresh code map if structure changed.

Statuses in backlog.md: `todo | spec | planned | in-progress | verify | done | dropped`.
