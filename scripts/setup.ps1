# AgenticOS Windows bootstrap — run FIRST on a fresh Windows machine, in regular PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass -Force; .\scripts\setup.ps1
# Installs the tools (asks before each), then hands off to Git Bash for the project setup.
# Safe to re-run: every install is skipped if the tool already exists.

$ErrorActionPreference = "Continue"

function Ask($q) {
    $a = Read-Host "$q [Y/n]"
    return ($a -eq "" -or $a -match "^[Yy]")
}
function AskNo($q) {   # default NO - for optional components; requires a deliberate 'y'
    $a = Read-Host "$q [y/N]"
    return ($a -match "^[Yy]")
}
function Have($cmd) { return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Step($name, $cmd, $wingetId) {
    if (Have $cmd) { Write-Host "  [OK] $name" -ForegroundColor Green; return }
    if (Ask "  $name is missing - install it now (winget install $wingetId)?") {
        winget install --id $wingetId -e --accept-source-agreements --accept-package-agreements
    } else { Write-Host "  [!!] Skipped $name - some steps will fail without it" -ForegroundColor Yellow }
}

Write-Host "`n== AgenticOS Windows bootstrap ==" -ForegroundColor Cyan

if (-not (Have "winget")) {
    Write-Host "  [XX] winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
    exit 1
}

Write-Host "`n-- 1/4 Installing tools (each asks first) --"
Step "Visual Studio Code" "code"   "Microsoft.VisualStudioCode"
# Pre-existing VS Code can be too old for the Claude Code extension (needs 1.94+): check and offer update.
if (Have "code") {
    try {
        $vsver = (code --version | Select-Object -First 1)
        if ([version]$vsver -lt [version]"1.94.0") {
            Write-Host "  [!!] VS Code $vsver is too old for the Claude Code extension (needs 1.94+)" -ForegroundColor Yellow
            if (Ask "  Update VS Code now?") {
                winget upgrade --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements
                Write-Host "  If winget can't update it: open VS Code -> Help -> Check for Updates." -ForegroundColor Yellow
            }
        } else { Write-Host "  [OK] VS Code $vsver (extension-compatible)" -ForegroundColor Green }
    } catch { Write-Host "  [!!] Could not read VS Code version - if extension install fails, update via Help -> Check for Updates" -ForegroundColor Yellow }
}
Step "Git for Windows"    "git"    "Git.Git"          # REQUIRED: provides Git Bash for Claude Code + this template
Step "Node.js LTS"        "node"   "OpenJS.NodeJS.LTS"
Step "Python 3.12"        "python" "Python.Python.3.12"
Step "uv"                 "uv"     "astral-sh.uv"

Write-Host "`n-- 2/4 Claude Code --"
if (Have "claude") { Write-Host "  [OK] Claude Code" -ForegroundColor Green }
elseif (Ask "  Install Claude Code (official installer)?") {
    Write-Host "  NOTE: takes a few minutes and may go quiet - DO NOT CLICK inside this window" -ForegroundColor Yellow
    Write-Host "  (a click pauses the program; press Esc once if that happens). Wait for 'Installation complete'." -ForegroundColor Yellow
    irm https://claude.ai/install.ps1 | iex
    # Belt-and-braces: ensure the install dir is on the User PATH (new windows only).
    $claudeBin = "$env:USERPROFILE\.local\bin"
    if (Test-Path "$claudeBin\claude.exe") {
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*$claudeBin*") {
            [Environment]::SetEnvironmentVariable('Path', "$userPath;$claudeBin", 'User')
        }
        Write-Host "  [OK] Claude Code installed at $claudeBin" -ForegroundColor Green
        Write-Host "  IMPORTANT: 'claude' works only in NEW terminal windows opened from now on." -ForegroundColor Yellow
    } else {
        Write-Host "  [!!] Installer finished but claude.exe not found at $claudeBin - see docs/setup-windows.md troubleshooting" -ForegroundColor Yellow
    }
    # Deliberately NOT using npm here: npm v11+ blocks the package's postinstall (allow-scripts gate),
    # leaving a stub exe that fails with a misleading 'not compatible with Windows' error.
}

Write-Host "`n-- 3/4 Long-path support (needs admin) --"
$lp = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -ErrorAction SilentlyContinue).LongPathsEnabled
if ($lp -eq 1) { Write-Host "  [OK] Long paths already enabled" -ForegroundColor Green }
else {
    Write-Host "  [!!] Not enabled. Run this ONCE in an ADMIN PowerShell:" -ForegroundColor Yellow
    Write-Host '      New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force'
}
if (Have "git") { git config --global core.longpaths true | Out-Null }

Write-Host "`n-- 4/4 Hand-off --"
Write-Host @"
  Tools done. One manual moment, then the guided setup finishes everything:

    CLOSE this window, open 'Git Bash' from the Start menu, then:
         cd '$((Get-Location).Path)'
         bash scripts/setup.sh

  (New terminals are required so the just-installed tools appear on PATH.)
"@ -ForegroundColor Cyan
