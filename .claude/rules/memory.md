# Memory protocol (repo-local)

All durable knowledge lives in `memory/`, versioned with the code.

| File | Contains | Written when |
|---|---|---|
| `memory/learnings.md` | Long-term technical insights (what worked, patterns adopted) | `/done`, `/wrap-up` |
| `memory/gotchas.md` | Long-term traps: non-obvious failures, env quirks, footguns | the moment one is hit |
| `memory/features.md` | One-line summary per shipped feature, newest first | `/done` |
| `memory/system-reference.md` | Generated code map — never edit by hand | `bash scripts/graphify.sh` |
| `memory/sessions/` | Per-session work logs (`YYYY-MM-DD-<slug>.md`) | `/wrap-up`; start stamped by hook |

## Long-term entries can be promoted upstream

If you made this repo from the AgenticOS template, a long-term learning or gotcha is
usually worth more in the template than in the one repo that hit it: everything made
from the template afterwards inherits it.

After writing either file (so at `/done` and `/wrap-up`), promote the new entries:

```bash
bash scripts/sync-memory.sh                 # dry run, shows what the template lacks
bash scripts/sync-memory.sh --apply --push  # append, commit, push to the template
```

Point it at your template checkout with `AGENTICOS_TEMPLATE_REPO`, or let the first run
prompt you for the path and remember it. Run inside the template itself it is a no-op and
says so, since there is nowhere to promote to. If you only cloned the public template and
have no push access, skip this entirely: your `memory/` belongs to your own repo.

An entry that is genuinely long-term but scoped to ONE repo (a quirk of one upstream site
or vendor API, say) goes in that repo's `memory/.sync-exclude`, one substring per line.
Without it, deleting the entry from the template does nothing: the next sync diffs against
the template and sends it straight back.

Only `learnings.md` and `gotchas.md` are promoted. `features.md` and `sessions/` are
repo-specific and stay where they are written.

Not automated as a hook on purpose: pushing to a shared repo is outward-facing and should
stay a decision, not a side effect of editing a file.

Rules:
- **Read before write**: check the file so entries aren't duplicated; update an existing entry rather than appending a near-duplicate.
- **Entry format**: `- YYYY-MM-DD — <one or two sentences>` (learnings/gotchas), `- AOS-### <name> — <one line> (YYYY-MM-DD)` (features).
- Keep entries atomic and terse; these files are read by future sessions, so every word costs future tokens.
- A gotcha that gets hit twice should be promoted into `CLAUDE.md` or a rule.
