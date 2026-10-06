# Setup — macOS, zero to running

Follow this on a bare Mac. Total time ~30–40 min, mostly downloads. Everything ends up inside **VS Code**; the terminal appears twice, both times with copy-paste commands.

## Step 0 — Access

Make sure you can load the repo in a browser while signed in to the GitHub account you will use. A 404 means you are on the wrong account, or (for a private repo) that an invite is still unaccepted.

## Step 1 — Install the tools (Terminal: Cmd+Space → "Terminal")

```bash
# Homebrew (the Mac package manager) — one command, follow its prompts:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

When it finishes it prints two "Next steps" commands (adding brew to your PATH) — **paste those two lines too**. First-time Macs may also pop an "Install Command Line Developer Tools?" dialog — click Install and wait. Then:

```bash
brew install git gh node uv
brew install --cask visual-studio-code
curl -fsSL https://claude.ai/install.sh | bash
```

Verify in a **new** Terminal window: `git --version`, `node --version` (v22+), `uv --version`, `code --version`, `claude --version` all answer. (If `claude` doesn't: the installer prints the PATH line to add to `~/.zshrc` — add it, open a new window.)

## Step 2 — Get the repo

```bash
gh auth login        # GitHub.com → HTTPS → Login with a web browser
gh repo clone YOUR-ORG/agenticos ~/Documents/agenticos
```

## Step 3 — Open in VS Code (home from here on)

1. VS Code → **File → Open Folder** → `Documents/agenticos` → "Yes, I trust the authors".
2. Popup bottom-right: **"Install the recommended extensions?" → Install** — that's the Claude extension plus helpers. (No popup? `Cmd+Shift+X`, search "Claude Code" by Anthropic, Install.)
3. Click the **Claude spark icon** (top-right) → **Sign in** → finish in the browser with your Claude account (Pro/Max/Team).

## Step 4 — One command to finish setup

VS Code menu **Terminal → New Terminal**, paste:

```bash
bash scripts/setup.sh
```

Answer Y to prompts (the ~150MB test-browser download is one-time). Success = **ALL SUITES PASSED**. Fails? Run it once more, then screenshot the summary for your coach.

## Step 5 — First workflow run (in the Claude panel)

Open the Claude panel (spark icon) and type, one at a time, reading between each: `/backlog show`, then `/spec AOS-002` → `/plan-item AOS-002` → `/implement AOS-002` (watch: failing test first, then code, diffs to accept) → `/verify AOS-002` (a second AI tries to refute the work) → `/done AOS-002` → `/wrap-up`. Once you've driven one item through, you've learned the system.

## Troubleshooting quick hits

- `xcrun: error: invalid active developer path` → the Command Line Tools dialog was dismissed; run `xcode-select --install`.
- `brew: command not found` after install → the two "Next steps" lines from the installer weren't pasted; re-run the installer, paste them, new window.
- `claude: command not found` in a new window → add `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshrc`, new window.
- Apple Silicon vs Intel: nothing to do — every tool here ships both builds.
- Company-managed Mac blocks Homebrew → use the direct installers (git-scm.com, nodejs.org, code.visualstudio.com, claude.com/claude-code, docs.astral.sh/uv) — same steps from Step 2 onward.
