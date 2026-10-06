#!/usr/bin/env bash
# AgenticOS guided setup — Mac, Linux, WSL, and Windows Git Bash.
# Interactive: checks each prerequisite, asks before installing or downloading anything,
# safe to re-run any time (every step is skipped if already done).
# Non-interactive mode: bash scripts/setup.sh --yes
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
YES=0; [ "${1:-}" = "--yes" ] && YES=1
OK=(); WARN=(); FAILED=()

say()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
pass() { printf '  \033[32m[OK]\033[0m %s\n' "$1"; OK+=("$1"); }
warn() { printf '  \033[33m[!!]\033[0m %s\n' "$1"; WARN+=("$1"); }
fail() { printf '  \033[31m[XX]\033[0m %s\n' "$1"; FAILED+=("$1"); }
ask()  { # ask "question" -> 0=yes
  [ "$YES" = 1 ] && return 0
  printf '  %s [Y/n] ' "$1"; read -r a; [ -z "$a" ] || [ "$a" = y ] || [ "$a" = Y ]
}

OS="other"
case "$(uname -s)" in
  Darwin) OS=mac ;;
  Linux)  grep -qi microsoft /proc/version 2>/dev/null && OS=wsl || OS=linux ;;
  MINGW*|MSYS*) OS=winbash ;;
esac
say "AgenticOS setup — detected: $OS"
[ "$OS" = winbash ] && printf '  (Windows: run scripts/setup.ps1 in PowerShell FIRST if tools below are missing)\n'

# ---- 1. Prerequisite checks (never auto-installs without asking) ----
say "1/4 Checking prerequisites"

need() { # need <cmd> <name> <mac-install> <other-hint>
  local cmd=$1 name=$2 mac=$3 hint=$4
  if command -v "$cmd" >/dev/null 2>&1; then pass "$name ($(command -v "$cmd"))"; return 0; fi
  if [ "$OS" = mac ] && [ -n "$mac" ] && command -v brew >/dev/null 2>&1 && ask "$name missing — install with brew ($mac)?"; then
    brew install $mac && pass "$name installed" && return 0
  fi
  fail "$name missing — $hint"; return 1
}

if [ "$OS" = mac ] && ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found — installs will be manual (or get it at https://brew.sh)"
fi
need git  "git"    "git"  "install Git: https://git-scm.com"
need node "Node.js" "node" "install Node 22+: https://nodejs.org (Windows: winget install OpenJS.NodeJS.LTS)"
if command -v node >/dev/null 2>&1; then
  NODEV=$(node -e 'console.log(process.versions.node.split(".")[0])' 2>/dev/null || echo 0)
  [ "$NODEV" -ge 20 ] && pass "Node version v$NODEV" || warn "Node v$NODEV is old — v22+ recommended"
fi
need uv "uv" "uv" "install uv: https://docs.astral.sh/uv (curl -LsSf https://astral.sh/uv/install.sh | sh)"
if python3 -c "import sys" >/dev/null 2>&1 || python -c "import sys" >/dev/null 2>&1; then pass "Python (verified by execution)"
elif command -v uv >/dev/null 2>&1; then
  warn "No directly runnable Python (Windows Store decoy?) — OK: scripts fall back to uv-managed Python automatically"
else
  fail "Python missing — https://python.org (Windows: winget install Python.Python.3.12; disable Store aliases in Settings > Apps > Advanced app settings > App execution aliases)"; fi
if command -v claude >/dev/null 2>&1; then pass "Claude Code ($(claude --version 2>/dev/null | head -1))"
elif [ -x "$HOME/.local/bin/claude" ] || [ -x "$HOME/.local/bin/claude.exe" ] || ls "${LOCALAPPDATA:-/nonexistent}/Microsoft/WinGet/Links/claude"* >/dev/null 2>&1; then
  warn "Claude Code IS installed but not on PATH in THIS terminal — close and reopen Git Bash (fresh windows pick up the new PATH)"
else warn "Claude Code missing — install: npm install -g @anthropic-ai/claude-code (or see docs/setup-windows.md)"; fi

if [ "${#FAILED[@]}" -gt 0 ]; then
  say "Fix the [XX] items above, then re-run: bash scripts/setup.sh"
  exit 1
fi

# ---- 2. Database ----
# ---- 2. Dependencies ---- (DB is SQLite: nothing to install or start)
say "2/4 Installing project dependencies (safe to re-run)"
( cd backend && uv sync ) && pass "backend (uv sync)" || fail "backend deps"
( cd frontend && npm install --no-audit --no-fund ) && pass "frontend (npm install)" || fail "frontend deps"
( cd e2e && npm install --no-audit --no-fund ) && pass "e2e (npm install)" || fail "e2e deps"
if [ -d "$HOME/.cache/ms-playwright" ] || { [ -n "${LOCALAPPDATA:-}" ] && [ -d "${LOCALAPPDATA:-}/ms-playwright" ]; }; then
  ( cd e2e && npx playwright install chromium >/dev/null 2>&1 ) && pass "Playwright chromium (cached)"
elif ask "Download the Playwright Chromium browser (~150MB, one-time)?"; then
  ( cd e2e && npx playwright install chromium ) && pass "Playwright chromium" || fail "playwright browser download"
else
  warn "Playwright browser skipped — e2e tests won't run until: cd e2e && npx playwright install chromium"
fi

# ---- 4. Verify ----
say "3/4 Running all test suites"
if bash scripts/test-all.sh; then pass "ALL SUITES PASSED"; else fail "tests failed — read the output above"; fi
bash scripts/graphify.sh && pass "code map generated (memory/system-reference.md)"

# ---- 5. Summary ----
say "4/4 Summary"
printf '  OK: %d   Warnings: %d   Failed: %d\n' "${#OK[@]}" "${#WARN[@]}" "${#FAILED[@]}"
for w in ${WARN[@]+"${WARN[@]}"}; do printf '  [!!] %s\n' "$w"; done
for f in ${FAILED[@]+"${FAILED[@]}"}; do printf '  [XX] %s\n' "$f"; done
if [ "${#FAILED[@]}" -eq 0 ]; then
  cat <<'EOF'

  Setup complete. Next:
    1. Run:  claude
    2. Then: /backlog show     (see the work)
    3. Then: /spec AOS-002     (drive your first item through the pipeline)
  How it all fits together: README.md
EOF
else
  echo "  Fix the [XX] items and re-run: bash scripts/setup.sh"
  exit 1
fi
