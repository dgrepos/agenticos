# Token efficiency

Context is the constraint; performance degrades as it fills.

- **Search before read**: Grep/Glob to locate, then read only the relevant range. Never cat a whole file to find one function.
- **Delegate exploration**: for "how does X work across the repo" questions, use the `scout` subagent so raw file contents stay out of the main context.
- **Consult the code map first**: `memory/system-reference.md` answers most "where is…" questions without reading any source.
- **Run tools, don't paste**: run commands and read their output; never ask the user to paste logs.
- **Compact proactively**: suggest `/compact` at natural boundaries (after `/done`) instead of waiting for auto-compaction.
- **Keep outputs terse**: no restating file contents back to the user; link paths instead.
