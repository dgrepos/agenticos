# Windows setup

The template's tools (uv, Node, Playwright, Python) are all cross-platform. The glue (bash hooks, `.sh` scripts) needs one of the two setups below. **WSL 2 is the recommended path** — it eliminates every Windows-specific friction point at once.

## Option A — WSL 2 (recommended)

1. In PowerShell (admin): `wsl --install` (installs WSL 2 + Ubuntu; reboot if asked).
2. Open the Ubuntu terminal and work **inside the WSL filesystem** (e.g. `~/code/`, NOT `/mnt/c/...` — the Windows-mount path is dramatically slower).
4. Inside Ubuntu: install uv (`curl -LsSf https://astral.sh/uv/install.sh | sh`), Node 22 (via nvm), and Claude Code (`npm install -g @anthropic-ai/claude-code`).
5. Clone the repo there and follow the standard README quick start. Everything — hooks, scripts, line endings — behaves exactly as on Mac/Linux.

## Option B — Native Windows (works, more friction)

1. **Install Git for Windows** (git-scm.com) — this provides Git Bash. Claude Code uses it for the Bash tool and for running the template's hooks/scripts. Without it, Claude Code falls back to PowerShell and every `.sh` in this template fails. If auto-detection fails, set in `.claude/settings.local.json`:
   ```json
   { "env": { "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe" } }
   ```
2. **Python**: install from python.org and check "Add to PATH". Native Windows usually exposes `python`/`py`, not `python3` — that's why all template entry points go through `bash scripts/graphify.sh`, which resolves whichever exists. Don't call `python3` directly in new commands; follow the same pattern.
3. **Line endings**: the repo's `.gitattributes` forces LF, which protects fresh clones. If the files were copied without git (zip, USB), verify with `git ls-files --eol` after `git init`; a bash script that errors with `\r: command not found` was CRLF-mangled — run `git checkout -- .` after committing `.gitattributes`.
4. **Long paths** (node_modules can exceed Windows' 260-char limit) — PowerShell as admin:
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```
   Also: `git config --global core.longpaths true`.
5. Executable bits don't exist on NTFS — irrelevant here because the template always invokes scripts as `bash scripts/foo.sh`, never `./scripts/foo.sh`. Keep that convention.

## Demo note for coaches

Decide which option you want **before** you need the machine, and pre-install: both take longer than you expect on a fresh box. Option A behaves identically to macOS and Linux. If your organisation forbids WSL, do a full dry run of Option B on a native Windows box first; everything in this template works either way.
