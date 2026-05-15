# Install sravioli/wezterm to ~/.config/wezterm
# License: GPL-2.0 — preserves upstream LICENSE and LICENSE-DOCS files
$ErrorActionPreference = 'Stop'

$Repo  = 'https://github.com/sravioli/wezterm.git'
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
Write-Host "Installed sravioli/wezterm (GPL-2.0, 155 stars)."
Write-Host "Required fonts: Fira Code Nerd Font, Monaspace Radon, Monaspace Krypton."
Write-Host "Requires WezTerm nightly for full feature support."
Write-Host ""
Write-Host "GPL-2.0 NOTICE: Do not delete LICENSE or LICENSE-DOCS files."
Write-Host "Derivative works distributed publicly must also be GPL-2.0."
Write-Host ""
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
Write-Host "To revert: remove $Dest and rename the most recent .bak-* folder back."
