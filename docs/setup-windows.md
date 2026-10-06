# Setup — Windows, zero to running

Follow this checklist on a bare Windows machine. Order matters. Everything uses official installers; total time ~30–45 min. All PowerShell commands run in a **regular** PowerShell window unless marked *(admin)*.

## Fast path (guided scripts — try this first)

```powershell
# 1. In PowerShell: get Git, then the repo
winget install Git.Git
# open a NEW PowerShell window so git is on PATH, then:
git clone https://github.com/YOUR-ORG/agenticos.git agenticos
cd agenticos
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\setup.ps1        # installs VS Code, Node, Python, uv, Claude Code — asks before each
```

Then: open **Git Bash** (Start menu), `cd` to the folder, and run `bash scripts/setup.sh` — it finishes dependencies and tests and tells you what to do next. Add the VS Code extension (Step 5 below), and you're done. The manual steps below are the fallback and the explanation of what the scripts do.

## Step 1 — Install VS Code

```powershell
winget install Microsoft.VisualStudioCode
```

(Alternative: download from https://code.visualstudio.com and run the installer — accept defaults, but tick "Add to PATH" and "Open with Code" options.)

Verify: open a new terminal → `code --version` prints a version.

## Step 2 — Install Git for Windows (required, not optional here)

```powershell
winget install Git.Git
```

Claude Code itself only *recommends* Git — but **this template requires it**: without Git Bash, Claude Code falls back to PowerShell and every `.sh` script and hook in AgenticOS fails. Accept installer defaults (they include Git Bash and LF-safe settings).

Verify in a **new** terminal: `git --version` and `bash --version` both answer.

## Step 3 — Install the runtimes

```powershell
winget install OpenJS.NodeJS.LTS          # Node 22+ (frontend, e2e)
winget install Python.Python.3.12         # Python 3.12 (backend)
winget install astral-sh.uv               # uv (Python package manager)
```

Enable long paths *(admin PowerShell)* — node_modules can exceed Windows' 260-char limit:

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
git config --global core.longpaths true
```

Verify in a new terminal: `node --version` (v22+), `python --version` (3.12+), `uv --version`.

## Step 4 — Install Claude Code

Use the native installer — it auto-updates and needs no dependencies:

```powershell
irm https://claude.ai/install.ps1 | iex
```

First run: type `claude` in a new terminal — a browser opens; sign in with your Claude subscription (Pro/Max/Team) or Console account. If the browser doesn't open, press `c` to copy the login URL.

Verify: `claude --version`, then `claude doctor` (full diagnostics — should show a healthy install and detect Git Bash; if it doesn't, add to `~/.claude/settings.json`: `{"env": {"CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"}}`).

## Step 5 — Install the Claude Code extension in VS Code

1. Open VS Code → `Ctrl+Shift+X` (Extensions) → search **"Claude Code"** (publisher: **Anthropic**) → Install. (Direct link: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code)
2. Open any file → click the spark icon (top-right editor toolbar) → **Sign in** → complete the browser authorization.
3. The Claude panel opens on the right: chat, side-by-side diff review, @-file mentions, plan-mode switching.

Notes: the extension bundles its own CLI copy, but keep the Step 4 install too — the terminal `claude` and the panel are separate and both are used in the demo. Running `/ide` inside a terminal `claude` session connects it to VS Code for diff viewing.

## Step 6 — Get the template and prove it works

```bash
# in Git Bash (Start menu → Git Bash), or VS Code terminal with a Git Bash profile
git clone https://github.com/YOUR-ORG/agenticos.git agenticos && cd agenticos
(cd backend && uv sync)
(cd frontend && npm install)
(cd e2e && npm install && npx playwright install chromium)
bash scripts/test-all.sh        # must end with: ALL SUITES PASSED
bash scripts/graphify.sh        # generates the code map
claude                          # SessionStart hook fires → the repo introduces itself
```

**Clone with git — never hand over a zip/USB copy.** The repo's `.gitattributes` line-ending protection only applies through git; a zip-copied repo on Windows risks CRLF-corrupted scripts.

## Step 7 — First workflow run (the actual onboarding — do this in VS Code)

Open the repo in VS Code (**File → Open Folder**); accept the "install recommended extensions" popup (that's the Claude extension); sign in at the spark icon. Then, **in the Claude panel** (easiest for non-developers) or the integrated terminal running `claude` + `/ide` (developers): `/backlog show`, then the seeded item through the full pipeline — `/spec AOS-002` → `/plan-item AOS-002` → `/implement AOS-002` → `/verify AOS-002` → `/done AOS-002` → `/wrap-up`. Driving one item through end to end is how the whole system clicks. The panel and the terminal run the same commands — pick per audience, panel by default.

## Troubleshooting quick hits

- `\r: command not found` running a script → CRLF corruption (repo was copied, not cloned). Fix: re-clone with git.
- `bash: command not found` inside Claude Code → Git for Windows missing or undetected → Step 4's `CLAUDE_CODE_GIT_BASH_PATH` fix.
- `python3: command not found` → expected on Windows; the template's scripts already route through `scripts/graphify.sh`, which resolves `python`/`py`. Follow that pattern for new scripts.
- npm install path errors → long paths not enabled (Step 3 admin commands).
- Claude Code refuses to install by every scripted route (winget outage + npm blocks postinstall with a stub that errors "not compatible with your version of Windows")? Download the installer manually from https://claude.com/claude-code and run it — the proven last resort. Never use npm for Claude Code on npm v11+.
- Corporate machine, WSL allowed? Prefer the WSL 2 route in `docs/windows-setup.md` — everything behaves exactly like Mac/Linux.
