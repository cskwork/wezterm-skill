<#
.SYNOPSIS
    Scaffold a new SSH host on Windows: keypair + ~/.ssh/config block + optional
    ssh-copy-id and WezTerm ssh_domains snippet.

.DESCRIPTION
    PowerShell port of scripts/add-ssh-host.sh. Idempotent: re-running with the
    same -Alias is a no-op unless -Force is passed.

    Requires Windows OpenSSH client (built into Windows 10/11) for ssh-keygen
    and ssh. Install with:
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

.PARAMETER Alias
    ssh-config Host alias and key suffix. Required.

.PARAMETER HostAddress
    Real hostname or IP. Required. (Named -HostAddress instead of -HostName
    because -Hostname is a reserved-ish parameter on some platforms.)

.PARAMETER User
    SSH username. Defaults to $env:USERNAME.

.PARAMETER Port
    SSH port. Default 22.

.PARAMETER KeyType
    ed25519 (default), rsa, or ecdsa.

.PARAMETER KeyPath
    Override key path. Default: ~/.ssh/id_<keytype>_<alias>

.PARAMETER NoKeygen
    Skip keypair generation even if the key file does not exist.

.PARAMETER CopyId
    Push the public key to the remote using ssh (Windows has no ssh-copy-id,
    so this uses cat-pipe-ssh equivalent).

.PARAMETER WezTermDomain
    Print a paste-ready ssh_domains snippet for wezterm.lua.

.PARAMETER Force
    Replace an existing Host block with the same alias.

.EXAMPLE
    PS> ./Add-SshHost.ps1 -Alias prod -HostAddress 10.0.0.42 -User deploy `
                          -CopyId -WezTermDomain

.EXAMPLE
    PS> ./Add-SshHost.ps1   # interactive
#>
[CmdletBinding()]
param(
    [string]$Alias,
    [string]$HostAddress,
    [string]$User = $env:USERNAME,
    [int]$Port = 22,
    [ValidateSet('ed25519','rsa','ecdsa')]
    [string]$KeyType = 'ed25519',
    [string]$KeyPath,
    [switch]$NoKeygen,
    [switch]$CopyId,
    [switch]$WezTermDomain,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Note($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Die($msg)  { Write-Error $msg; exit 1 }

# ----- locate ~/.ssh
$sshDir    = Join-Path $HOME '.ssh'
$sshConfig = Join-Path $sshDir 'config'

# ----- interactive fill-ins
if (-not $Alias)       { $Alias       = Read-Host 'alias (Host name in ssh config)' }
if (-not $HostAddress) { $HostAddress = Read-Host 'hostname or IP' }
if (-not $Alias)       { Die 'alias is required' }
if (-not $HostAddress) { Die 'hostname is required' }
if (-not $User)        { Die 'username is required ($env:USERNAME or -User)' }

if (-not $KeyPath) {
    $KeyPath = Join-Path $sshDir "id_${KeyType}_${Alias}"
}

# ----- prepare ~/.ssh
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}
if (-not (Test-Path $sshConfig)) {
    New-Item -ItemType File -Path $sshConfig -Force | Out-Null
}

# ----- verify ssh-keygen / ssh available
foreach ($tool in 'ssh-keygen','ssh') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Die "$tool not found. Install OpenSSH Client: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
    }
}

# ----- key generation
if (-not $NoKeygen -and -not (Test-Path $KeyPath)) {
    Note "generating $KeyType keypair at $KeyPath"
    $comment = "$User@$Alias"
    switch ($KeyType) {
        'ed25519' { & ssh-keygen -t ed25519 -a 100 -f $KeyPath -C $comment -N '""' }
        'rsa'     { & ssh-keygen -t rsa -b 4096   -f $KeyPath -C $comment -N '""' }
        'ecdsa'   { & ssh-keygen -t ecdsa -b 521  -f $KeyPath -C $comment -N '""' }
    }
    if ($LASTEXITCODE -ne 0) { Die "ssh-keygen failed (exit $LASTEXITCODE)" }
} else {
    Note "key at $KeyPath already exists (skipping keygen)"
}

# ----- ssh-config block
$header = "# >>> added by Add-SshHost.ps1: $Alias >>>"
$footer = "# <<< added by Add-SshHost.ps1: $Alias <<<"

$existing = Get-Content $sshConfig -ErrorAction SilentlyContinue
if ($existing -and ($existing -contains $header)) {
    if ($Force) {
        Note "removing existing block for '$Alias' (-Force)"
        $skip = $false
        $kept = foreach ($line in $existing) {
            if ($line -eq $header) { $skip = $true; continue }
            if ($line -eq $footer) { $skip = $false; continue }
            if (-not $skip) { $line }
        }
        Set-Content -Path $sshConfig -Value $kept -Encoding ascii
    } else {
        Die "alias '$Alias' already present in $sshConfig (use -Force to replace)"
    }
}

$block = @"

$header
Host $Alias
    HostName $HostAddress
    User $User
    Port $Port
    IdentityFile $KeyPath
    IdentitiesOnly yes
    ServerAliveInterval 30
    ServerAliveCountMax 3
$footer
"@

Add-Content -Path $sshConfig -Value $block -Encoding ascii
Note "appended Host block for '$Alias' to $sshConfig"

# ----- push public key
if ($CopyId) {
    Note "pushing public key (you'll be prompted for the remote password)"
    $pub = Get-Content "$KeyPath.pub" -Raw
    $remoteCmd = "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    $pub | & ssh -p $Port "$User@$HostAddress" $remoteCmd
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "ssh exited with $LASTEXITCODE; key push may have failed."
    }
}

# ----- wezterm snippet
if ($WezTermDomain) {
    Write-Host ""
    Write-Host "==> paste this into your wezterm.lua:" -ForegroundColor Yellow
    @"

config.ssh_domains = config.ssh_domains or {}
table.insert(config.ssh_domains, {
  name = '$Alias',
  remote_address = '${HostAddress}:${Port}',
  username = '$User',
  ssh_option = {
    identityfile = '$($KeyPath -replace '\\','/')',
    identitiesonly = 'yes',
  },
  multiplexing = 'None',   -- switch to 'WezTerm' if wezterm is installed on the remote
  assume_shell = 'Posix',
})
"@ | Write-Host

    Write-Host "==> then connect with:" -ForegroundColor Yellow
    Write-Host "    wezterm connect $Alias"
}

Note "done. test with: ssh $Alias"
