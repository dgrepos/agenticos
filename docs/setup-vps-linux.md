# Setup — Linux VPS, zero to running

For running AgenticOS on a rented server (Hetzner, DigitalOcean, EC2, Lightsail…). Assumes Ubuntu 22.04/24.04 (Debian works the same). Two modes — pick one:

- **Mode A — VS Code Remote-SSH (recommended):** you keep the full VS Code + Claude panel experience on your laptop; the code and tools live on the VPS. Best for non-technical users.
- **Mode B — pure terminal:** SSH in, run `claude` in the shell. For developers and automation.

Specs: 2 vCPU / 4GB RAM / 20GB disk is comfortable. ~30 min total.

## Step 1 — Server basics (once, as root)

```bash
# Never work as root day-to-day: make a user with sudo
adduser dev && usermod -aG sudo dev
# put your SSH public key on the new user, then log in as dev
```

As `dev`:

```bash
sudo apt update && sudo apt install -y git curl unzip build-essential
# Node 22 (NodeSource):
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs
# uv (brings its own Python when needed):
curl -LsSf https://astral.sh/uv/install.sh | sh
# GitHub CLI + Claude Code:
sudo apt install -y gh 2>/dev/null || (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list && sudo apt update && sudo apt install -y gh)
curl -fsSL https://claude.ai/install.sh | bash
```

Open a new shell; verify: `git --version`, `node --version`, `uv --version`, `gh --version`, `claude --version`.

## Step 2 — Get the repo and set it up

```bash
gh auth login          # GitHub.com → HTTPS → paste the one-time code into a browser on your laptop
gh repo clone YOUR-ORG/agenticos ~/agenticos
cd ~/agenticos
bash scripts/setup.sh
```

Headless-server note: when Playwright's browser downloads, it also needs system libraries — if the e2e suite complains, run `cd e2e && sudo npx playwright install-deps chromium` once, then re-run `bash scripts/setup.sh`. Success = **ALL SUITES PASSED**.

Claude sign-in on a headless box: `claude` prints a login URL/code — open the URL in the browser **on your laptop**, sign in, paste the code back into the terminal.

## Step 3A — Mode A: VS Code Remote-SSH (the laptop is the cockpit)

On your **laptop**:

1. Install VS Code (code.visualstudio.com) → `Ctrl/Cmd+Shift+X` → install **"Remote - SSH"** (Microsoft).
2. `Ctrl/Cmd+Shift+P` → "Remote-SSH: Connect to Host…" → `dev@YOUR_SERVER_IP` → VS Code opens *on the server*.
3. **File → Open Folder** → `/home/dev/agenticos` → accept **"Install recommended extensions"** (installs the Claude extension into the remote session) → spark icon → Sign in.
4. From here it's identical to a local machine: Claude panel, `/backlog show`, and the pipeline (`/spec AOS-002` → … → `/wrap-up`). Terminal → New Terminal runs on the VPS.

Viewing the running app from the laptop: VS Code auto-forwards ports — run `bash scripts/dev.sh` in the remote terminal, then open http://localhost:5173 on the laptop (check the "Ports" tab in VS Code if it didn't auto-forward).

## Step 3B — Mode B: pure terminal

```bash
cd ~/agenticos && claude
```

Then `/backlog show` and the pipeline, exactly as everywhere else. For long sessions that survive SSH drops, run inside tmux: `sudo apt install -y tmux; tmux new -s work` (reattach later with `tmux attach -t work`).

## Security must-dos for any internet-facing VPS

SSH keys only (`PasswordAuthentication no` in `/etc/ssh/sshd_config`); enable the firewall: `sudo ufw allow OpenSSH && sudo ufw enable` (do NOT open 5173/8000 publicly — use VS Code port-forwarding or an SSH tunnel to view the app); unattended upgrades: `sudo apt install -y unattended-upgrades`. The dev servers in this template are development-grade — deploying for real users is a separate exercise (reverse proxy, TLS, hosted Postgres via `DATABASE_URL`), not part of onboarding.

## Troubleshooting quick hits

- e2e fails with missing library errors (`libnss3`, `libatk`…) → `cd e2e && sudo npx playwright install-deps chromium`.
- `claude: command not found` in a fresh shell → `export PATH="$HOME/.local/bin:$PATH"` in `~/.bashrc`, then `source ~/.bashrc`.
- npm installs killed on a 1–2GB RAM box → add swap: `sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`.
- Remote-SSH keeps reconnecting → check the server isn't out of disk (`df -h`); VS Code Server needs ~500MB in `~/.vscode-server`.
