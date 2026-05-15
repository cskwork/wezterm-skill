# Install QianSong1/wezterm-config to ~/.config/wezterm
# License: MIT — preserves upstream LICENSE
$ErrorActionPreference = 'Stop'

$Repo  = 'https://github.com/QianSong1/wezterm-config.git'
$Dest  = Join-Path $HOME '.config\wezterm'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

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

Write-Host ""
Write-Host "Installed QianSong1/wezterm-config (MIT, 258 stars)."
Write-Host "Required font: JetBrainsMono NF v3.2.1 or MesloLGM Nerd Font."
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
Write-Host "To revert: remove $Dest and rename the most recent .bak-* folder back."
