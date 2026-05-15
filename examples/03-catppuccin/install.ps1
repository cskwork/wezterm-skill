# Install catppuccin/wezterm starter to ~/.wezterm.lua
# License: MIT (catppuccin/wezterm)
$ErrorActionPreference = 'Stop'

$Source = Join-Path $PSScriptRoot 'wezterm.lua'
$Dest   = Join-Path $HOME '.wezterm.lua'
$Stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'

if (Test-Path $Dest) {
    $Backup = "$Dest.bak-$Stamp"
    Write-Host "Backing up $Dest -> $Backup"
    Move-Item -Path $Dest -Destination $Backup
}

Write-Host "Installing $Source -> $Dest"
Copy-Item -Path $Source -Destination $Dest

Write-Host ""
Write-Host "Installed catppuccin/wezterm starter (MIT, 358 stars)."
Write-Host "Theme is built into WezTerm 20220903+ — no plugin install needed."
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
Write-Host "To switch flavor, edit scheme_for_appearance() in $Dest."
