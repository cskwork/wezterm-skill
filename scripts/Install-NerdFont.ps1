<#
.SYNOPSIS
    Per-user Nerd Font installer for Windows (no admin required).

.DESCRIPTION
    Downloads a font archive from ryanoasis/nerd-fonts releases, extracts it,
    and installs all .ttf / .otf files into the per-user font directory
    %LOCALAPPDATA%\Microsoft\Windows\Fonts. Registers each font in the
    HKCU font registry so the system picks it up immediately.

    Works without administrator privileges. Skips fonts that are already
    installed.

.PARAMETER FontName
    Asset name from the nerd-fonts release (zip filename without extension).
    Common: JetBrainsMono, FiraCode, Hack, Meslo, CascadiaCode.

.PARAMETER Version
    Tag of the nerd-fonts release. Default: 'latest'.

.PARAMETER Quiet
    Suppress progress output.

.EXAMPLE
    .\Install-NerdFont.ps1
    .\Install-NerdFont.ps1 -FontName FiraCode
    .\Install-NerdFont.ps1 -FontName JetBrainsMono -Version v3.2.1
#>
[CmdletBinding()]
param(
    [string]$FontName = 'JetBrainsMono',
    [string]$Version  = 'latest',
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

if ($Version -eq 'latest') {
    $Url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
} else {
    $Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/$Version/$FontName.zip"
}

$TempDir = Join-Path $env:TEMP "nerd-font-$([guid]::NewGuid().ToString().Substring(0,8))"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
$Zip = Join-Path $TempDir "$FontName.zip"

try {
    if (-not $Quiet) { Write-Host "Downloading $Url" }
    Invoke-WebRequest -Uri $Url -OutFile $Zip -UseBasicParsing

    if (-not $Quiet) { Write-Host "Extracting $Zip" }
    Expand-Archive -Path $Zip -DestinationPath $TempDir -Force

    $FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    New-Item -ItemType Directory -Force -Path $FontDir | Out-Null

    $RegKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    if (-not (Test-Path $RegKey)) {
        New-Item -Path $RegKey -Force | Out-Null
    }

    $installed = 0
    $skipped   = 0

    # Prefer .ttf, then .otf
    $files = Get-ChildItem -Path $TempDir -Recurse -Include '*.ttf','*.otf' -File
    foreach ($file in $files) {
        $dest    = Join-Path $FontDir $file.Name
        $regName = "$($file.BaseName) (TrueType)"

        if (Test-Path $dest) {
            $skipped++
            continue
        }

        Copy-Item -Path $file.FullName -Destination $dest -Force
        # Register so apps find it without re-login
        Set-ItemProperty -Path $RegKey -Name $regName -Value $dest -Force
        $installed++
    }

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "Installed $installed font file(s); skipped $skipped already-present file(s)."
        Write-Host "Location: $FontDir (per-user — no admin required)"
        if ($installed -gt 0) {
            Write-Host "Restart WezTerm (or reload with Ctrl+Shift+R) to pick up new fonts."
        }
    }
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
