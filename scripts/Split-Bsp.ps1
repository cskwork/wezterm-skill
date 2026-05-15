<#
.SYNOPSIS
    Binary Space Partitioning split for the current WezTerm pane (Windows-native).

.DESCRIPTION
    Reads $env:WEZTERM_PANE, queries `wezterm cli list --format json` for the
    current pane's dimensions, then splits along the shorter axis so the layout
    stays balanced. Prints the new pane id on stdout.

    PowerShell port of scripts/bsp-split.sh. Same contract:
      - Aspect ratio (cols / rows) > 2.0 -> --right
      - Otherwise                       -> --bottom

.EXAMPLE
    PS> $paneId = ./Split-Bsp.ps1
    PS> 'claude' | wezterm cli send-text --pane-id $paneId

.NOTES
    DO NOT use `wezterm cli split-pane -- <command>`. That bypasses your shell
    and loses PATH / aliases. Split first, then send-text.
#>
[CmdletBinding()]
param(
    [string]$WezTerm = 'wezterm'
)

$ErrorActionPreference = 'Stop'

if (-not $env:WEZTERM_PANE) {
    Write-Error 'WEZTERM_PANE is not set. Run this inside a WezTerm pane.'
    exit 1
}

if (-not (Get-Command $WezTerm -ErrorAction SilentlyContinue)) {
    # Fall back to default install path on Windows.
    $candidate = 'C:\Program Files\WezTerm\wezterm.exe'
    if (Test-Path $candidate) {
        $WezTerm = $candidate
    } else {
        Write-Error "wezterm CLI not found in PATH and not at '$candidate'."
        exit 1
    }
}

$paneId = [int]$env:WEZTERM_PANE
$json   = & $WezTerm cli list --format json | Out-String
$panes  = $json | ConvertFrom-Json
$current = $panes | Where-Object { $_.pane_id -eq $paneId } | Select-Object -First 1

if (-not $current) {
    Write-Error "Could not find pane $paneId in 'wezterm cli list' output."
    exit 1
}

$cols  = [int]$current.size.cols
$rows  = [int]$current.size.rows
$ratio = $cols / [double]$rows

$direction = if ($ratio -gt 2.0) { '--right' } else { '--bottom' }

# Returns the new pane id on stdout.
& $WezTerm cli split-pane --pane-id $paneId $direction
