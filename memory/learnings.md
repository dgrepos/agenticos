# Learnings (long-term)

Durable technical insights. Format: `- YYYY-MM-DD — <insight>`. Read before appending; consolidate duplicates.

The entries below ship with the template and are deliberately undated: they are
accumulated findings, not events in your project's timeline. Date everything you add.

- Template initialized. Tool priority is CLI > API > MCP; grep + a generated code map beats embeddings until the repo is large.
- Code-intel decision (see `docs/code-intelligence-options.md`): stay with grep + graphify until the repo is large or `scout` needs 3+ search rounds; then trial a structural index in CLI mode on a branch, measuring tokens on 10 real questions before adopting. Never cloud vector DBs or MCP retrieval while a CLI works.
- Watching a first-time user set up the repo without helping them is the fastest doc-debugging method available: every question they ask is a doc bug. Budget one real session before trusting any onboarding doc.
- SQLite is the dev default (`sqlite:///./app.db`); Postgres is a one-env-var switch for production parity. Rule of thumb: SQLite until first deployment. Setup must never gate on container runtimes or BIOS-level virtualization.
- Removed Docker from the template entirely. Dev = SQLite; production = hosted Postgres via `DATABASE_URL`. Rationale: Docker was the single biggest onboarding failure surface (virtualization/BIOS/WSL2) for a dependency no dev flow actually used.
- Scraper/integration architecture that survives upstream DOM or schema rot: split selectors (one file of ordered cascades) / a pure `input -> dict` parser / the driver that fetches. The parser gets its unit tests from captured fixtures with no network and no account, and an upstream reskin only ever touches the cascade file. Pair it with a `doctor` command that prints per-selector match counts, which is the difference between "extraction returned nothing" and "one cascade is stale".
- `uv` dependency-groups keep heavy optional deps (Playwright, ~500 MB with browser) out of the runtime install. Verify the base path really still works with `uv run --exact pytest`, which prunes extras from the env; guard optional-dep tests with `pytest.importorskip` so they skip instead of erroring at collection.
- Unit tests over a synthetic repo cannot prove an installer or scaffolder works; only an end-to-end run into a fresh tree can. Defects routinely survive a fully green unit suite and die on the first real run: a load-bearing empty `__init__.py`, `__pycache__` keeping a "removed" directory alive, a lockfile rewritten by the tool's own verify step. Budget one full install/upgrade/uninstall cycle against a git baseline (`git status --porcelain` is the assertion) before believing any of it.
- When a "leaves no trace" claim has an exception, state the exception in the product and the spec rather than quietly narrowing the claim. A documented exception beats a silent overclaim.
