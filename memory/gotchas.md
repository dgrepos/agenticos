# Gotchas (long-term)

Traps, env quirks, footguns. Write the moment one is hit. Format: `- YYYY-MM-DD — <gotcha>`.

The entries below ship with the template and are deliberately undated: they are
accumulated traps, not events in your project's timeline. Date everything you add.

- `memory/system-reference.md` is generated; hand edits are lost on the next `graphify` run.
- Windows: clicking inside a PowerShell window activates QuickEdit selection and PAUSES the running program, which looks identical to a hung installer. Press Esc to resume. Never diagnose a "freeze" without trying Esc first.
- Never install via a silent `irm | iex` in user-facing scripts without a warning: zero progress output reads as frozen.
- Windows: tools installed by a package manager are not on PATH in already-open terminals. Every "command not found" right after an install just needs a NEW terminal window.
- Windows PATH asymmetry: `$env:Path += ...` fixes ONLY the current window (instantly); `[Environment]::SetEnvironmentVariable(...,'User')` fixes ONLY future windows (never the current one). Testing in the wrong window makes a working fix look broken.
- A long-uptime Windows box (weeks or months) cannot activate newly enabled OS features. Reboot before debugging further.
- GitHub personal-account repos have NO read-only collaborator role (invitees get write). Read-only sharing requires an organization repo. Also: `gh repo create org/name` fails with a GraphQL permissions error if you are not an org member or owner.
- Windows: do NOT install Claude Code via npm on npm v11+. The allow-scripts gate silently blocks the postinstall, leaving a stub executable that fails with a misleading "not compatible with your version of Windows" error, and `npm approve-scripts` does not work for global installs (EGLOBAL). Use the official installer.
- Package-manager sources can fail transiently ("Failed in attempting to update the source"). Do not debug the package manager; fall back to the tool's official installer or a direct download.
- Memory files can silently revert if the working tree is reset (`git checkout .`) before memory edits are committed. Commit memory updates promptly; git is the memory system's real safety net.
- Windows ships a DECOY `python`/`python3` (an App Execution Alias that opens the Microsoft Store). `command -v python` finds it and lies. Always verify interpreters by EXECUTION (`python -c "import sys"`), and use `uv run --no-project python` as the guaranteed fallback, since uv downloads a real Python itself.
- Windows Python defaults file I/O to cp1252, not UTF-8: any `write_text`/`read_text`/`open` without `encoding="utf-8"` crashes on non-ASCII (arrows, dashes). Always pass encoding explicitly in cross-platform scripts.
- The cp1252 trap has a SECOND half: even with `encoding="utf-8"` on every file read and write, `print()` of non-ASCII still dies, because the Windows console's stdout is cp1252. It killed `graphify.py` on an arrow AFTER the map file was already written, so it looked like a generation failure. Fix once per script with `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`, or keep console output ASCII-only. `PYTHONIOENCODING=utf-8` works for one-off invocations.
- Vite's proxy does NOT strip path prefixes by default: `proxy: {'/api': target}` forwards /api/health as /api/health, a 404 on a backend serving /health. Always set `rewrite`. Found by the e2e smoke test on the first machine that actually ran it, after environment noise had masked a real app bug on every earlier run.
- Pre-existing tools pass "is it installed?" checks while being too OLD to work: an outdated VS Code will refuse the Claude Code extension outright. Setup checks must verify versions, not existence (the same lesson as the decoy python, in a different costume).
- `backend/tests/__init__.py` (empty, shipped by this template) is load-bearing: with it, pytest puts `backend/` on `sys.path`; without it, `backend/tests/`, and every test dies on `ModuleNotFoundError: No module named 'app'`. Nothing in the repo hints that an empty file is doing this. Any tool that copies tests into another repo must check it exists.
- If a store or cache layer restamps a timestamp (`fetched_at`, `updated_at`) on EVERY write, a "did anything change?" check must compare the payload, not the file bytes, and a no-op run should skip the write entirely rather than churn the file.
