# Tool priority: CLI > API > MCP

When you need a capability, choose in this order:

1. **CLI / local script** — `gh`, `psql`, `npx playwright`, `scripts/*.py`. Zero standing token cost; deterministic; auditable in git.
2. **Direct API call from a script** — if no CLI exists, write a small script under `scripts/` that calls the HTTP API (secrets from env vars), and invoke it via Bash. The script becomes reusable team infrastructure.
3. **MCP server** — last resort, only when the integration needs interactive auth or stateful sessions a script can't handle. Every connected MCP server's tool schemas consume context in every session, even when unused.

Corollaries: never add an MCP server for something `gh`/`psql`/one curl-equivalent script can do; if a script is used twice, document it in `memory/system-reference.md`.
