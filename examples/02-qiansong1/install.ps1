# Install QianSong1/wezterm-config to ~/.config/wezterm
# License: MIT — preserves upstream LICENSE
param(
    [switch]$NoFonts
)
$ErrorActionPreference = 'Stop'

$Repo  = 'https://github.com/QianSong1/wezterm-config.git'
$Dest  = Join-Path $HOME '.config\wezterm'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$FontInstaller = Join-Path $PSScriptRoot '..\..\scripts\Install-NerdFont.ps1'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git not found in PATH. Install Git for Windows first."
}

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

New-Item -ItemType Directory -Force -Path (Split-Path $Dest -Parent) | Out-Null
Write-Host "Cloning $Repo -> $Dest"
git clone --depth 1 $Repo $Dest

# Install required Nerd Font (skip with -NoFonts)
# QianSong1 README pins v3.2.1; we honor that.
if (-not $NoFonts) {
    if (Test-Path $FontInstaller) {
        Write-Host ""
        Write-Host "Installing JetBrainsMono Nerd Font v3.2.1 (per-user, no admin)..."
        & $FontInstaller -FontName 'JetBrainsMono' -Version 'v3.2.1'
    } else {
        Write-Warning "Font installer not found — install JetBrainsMono NF v3.2.1 manually from https://www.nerdfonts.com"
    }
}

Write-Host ""
Write-Host "Installed QianSong1/wezterm-config (MIT, 258 stars)."
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
Write-Host "To revert: remove $Dest and rename the most recent .bak-* folder back."
