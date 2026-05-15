# Install KevinSilvester/wezterm-config to ~/.config/wezterm
# License: MIT — preserves upstream LICENSE
param(
    [switch]$NoFonts  # opt out of JetBrainsMono Nerd Font install
)
$ErrorActionPreference = 'Stop'

$Repo  = 'https://github.com/KevinSilvester/wezterm-config.git'
$Dest  = Join-Path $HOME '.config\wezterm'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$FontInstaller = Join-Path $PSScriptRoot '..\..\scripts\Install-NerdFont.ps1'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git not found in PATH. Install Git for Windows first."
}

# 1. Back up existing config
$LegacyFile = Join-Path $HOME '.wezterm.lua'
if (Test-Path $LegacyFile) {
    $BackupFile = "$LegacyFile.bak-$Stamp"
    Write-Host "Backing up $LegacyFile -> $BackupFile"
    Move-Item -Path $LegacyFile -Destination $BackupFile
}
if (Test-Path $Dest) {
    $BackupDir = "$Dest.bak-$Stamp"
    Write-Host "Backing up $Dest -> $BackupDir"
    Move-Item -Path $Dest -Destination $BackupDir
}

# 2. Clone fresh
New-Item -ItemType Directory -Force -Path (Split-Path $Dest -Parent) | Out-Null
Write-Host "Cloning $Repo -> $Dest"
git clone --depth 1 $Repo $Dest

# 3. Install required Nerd Font (skip with -NoFonts)
if (-not $NoFonts) {
    if (Test-Path $FontInstaller) {
        Write-Host ""
        Write-Host "Installing JetBrainsMono Nerd Font (per-user, no admin)..."
        & $FontInstaller -FontName 'JetBrainsMono'
    } else {
        Write-Warning "Font installer not found at $FontInstaller — install JetBrainsMono Nerd Font manually from https://www.nerdfonts.com"
    }
}

# 4. Done
Write-Host ""
Write-Host "Installed KevinSilvester/wezterm-config (MIT, 1072 stars)."
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
Write-Host "To revert: remove $Dest and rename the most recent .bak-* folder back."
