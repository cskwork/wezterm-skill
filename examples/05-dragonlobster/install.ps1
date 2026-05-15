# Install dragonlobster/wezterm-config to ~/.wezterm.lua
# License: NOT SPECIFIED upstream. Script downloads directly from upstream raw URL
# rather than redistributing — caller's machine, caller's responsibility.
$ErrorActionPreference = 'Stop'

$Url   = 'https://raw.githubusercontent.com/dragonlobster/wezterm-config/main/wezterm.lua'
$Dest  = Join-Path $HOME '.wezterm.lua'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if (Test-Path $Dest) {
    $Backup = "$Dest.bak-$Stamp"
    Write-Host "Backing up $Dest -> $Backup"
    Move-Item -Path $Dest -Destination $Backup
}

Write-Host "Downloading $Url -> $Dest"
try {
    Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
} catch {
    Write-Error "Download failed: $_"
    if (Test-Path "$Dest.bak-$Stamp") {
        Move-Item -Path "$Dest.bak-$Stamp" -Destination $Dest
        Write-Host "Restored previous config."
    }
    exit 1
}

Write-Host ""
Write-Host "Installed dragonlobster/wezterm-config (no license, 68 stars)."
Write-Host "Required font: Maple Mono NF or JetBrains Mono NL (fallback works without)."
Write-Host "Leader key: Alt+q (2s timeout) — see README.md for full keybindings."
Write-Host "Reload WezTerm with Ctrl+Shift+R or restart the app."
