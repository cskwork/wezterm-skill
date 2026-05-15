# SSH with WezTerm

WezTerm has its own built-in SSH client. You can either connect ad-hoc (`wezterm ssh user@host`) or declare persistent SSH endpoints in `wezterm.lua` as `ssh_domains` and reach them with `wezterm connect <name>`.

## When to use which

| | `wezterm ssh` | `ssh_domains` + `wezterm connect` |
|---|---|---|
| Persistent multiplexer | no | yes (with `multiplexing = 'WezTerm'`) |
| Survives disconnects | no | yes — panes/tabs recover |
| Requires wezterm on remote | no | only for multiplexing |
| Best for | one-offs, jump boxes | daily-driver servers |

System OpenSSH (`/usr/bin/ssh`) still works from inside a WezTerm pane like in any terminal — pick `wezterm ssh` only when you want WezTerm's protocol parsing (better escape handling, true color, image protocols) or its mux.

## Ad-hoc: `wezterm ssh`

```bash
wezterm ssh user@host                          # default port 22, default $USER
wezterm ssh user@host:2222                     # custom port
wezterm ssh -oIdentityFile=~/.ssh/id_ed25519 host
wezterm ssh -v user@host                       # protocol trace on stderr
wezterm ssh user@host -- tmux attach -t main   # run a command remote-side
```

Caveats:

- WezTerm parses *some* `~/.ssh/config` options but not all. Anything unsupported can be forced with `-o name=value`.
- `ProxyCommand` is supported via `-oProxyCommand="..."`.
- Agent auth (`SSH_AUTH_SOCK`) works on Linux/macOS. On Windows use OpenSSH Authentication Agent service or 1Password's SSH agent.

## Persistent: ssh_domains

Add to `wezterm.lua`:

```lua
config.ssh_domains = {
  {
    name = 'prod',
    remote_address = '10.0.0.42:22',
    username = 'deploy',
    ssh_option = {
      identityfile = '/home/me/.ssh/id_ed25519',
    },
    multiplexing = 'WezTerm',          -- requires wezterm on the remote
    assume_shell = 'Posix',
    local_echo_threshold_ms = 10,      -- predictive echo for high-latency links
  },
  {
    name = 'cheap-box',
    remote_address = 'box.example.com',
    username = 'me',
    multiplexing = 'None',             -- plain ssh, no remote wezterm needed
  },
}

-- Optional: launch directly into a domain on startup
-- config.default_domain = 'prod'
-- config.default_gui_startup_args = { 'connect', 'prod' }
```

Connect with:

```bash
wezterm connect prod
```

Tabs/panes you open inside that connection survive client restarts when `multiplexing = 'WezTerm'`.

### Field reference (most useful)

| Field | Notes |
|---|---|
| `name` | Unique across all domains |
| `remote_address` | `host` or `host:port` |
| `username` | Falls back to local `$USER` if omitted |
| `ssh_option` | Table of OpenSSH config keys (lowercase): `identityfile`, `port`, `proxycommand`, `userknownhostsfile`, ... |
| `multiplexing` | `'WezTerm'` (default) or `'None'` |
| `remote_wezterm_path` | Path to wezterm on the remote if not on `PATH` |
| `assume_shell` | `'Posix'` enables shell integration features |
| `default_prog` | Command to run in new tabs/panes for this domain |
| `no_agent_auth` | Disable agent auth for this domain |
| `connect_automatically` | Connect at startup |
| `timeout` | Read timeout in seconds |
| `local_echo_threshold_ms` | Predict echo when round-trip > N ms |

## OpenSSH `~/.ssh/config` interop

WezTerm reads `~/.ssh/config`, so the easiest workflow is:

1. Add the host to `~/.ssh/config` (with `Host`, `HostName`, `User`, `IdentityFile`, `Port`).
2. Optionally promote that host to a wezterm `ssh_domain` so you get multiplexing.

Example `~/.ssh/config` block:

```sshconfig
Host prod
    HostName 10.0.0.42
    User deploy
    IdentityFile ~/.ssh/id_ed25519_prod
    Port 22
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

After this, both `wezterm ssh prod` and a `ssh_domains` entry referencing `prod` work.

## Helper script

This skill ships `scripts/add-ssh-host.sh`. It:

1. Generates an Ed25519 keypair if one does not exist for the host.
2. Appends a `Host` block to `~/.ssh/config`.
3. (Optional) prints a paste-ready `ssh_domains` entry for your `wezterm.lua`.
4. (Optional) runs `ssh-copy-id` to push the public key.

Run it from any WezTerm pane:

```bash
./scripts/add-ssh-host.sh                  # interactive
./scripts/add-ssh-host.sh --alias prod \
                         --hostname 10.0.0.42 \
                         --user deploy \
                         --port 22 \
                         --keytype ed25519 \
                         --copy-id \
                         --wezterm-domain
```

## Troubleshooting

- **`Authentication failed`** — run `wezterm ssh -v user@host` for the protocol trace. Common causes: agent not running, wrong identity file, server's `AuthorizedKeysFile` permission mode (must be 600 on the key, 700 on `~/.ssh`).
- **`Connection refused`** — server not listening on that port, firewall, or VPN not up.
- **Multiplexed connection drops** — set `ServerAliveInterval 30` in `~/.ssh/config` (or `timeout` on the wezterm domain).
- **Slow typing over high-latency link** — `local_echo_threshold_ms = 10` enables predictive echo.
- **`remote wezterm not found`** — install wezterm on the remote *or* switch the domain to `multiplexing = 'None'`.

## Sources

- <https://wezterm.org/cli/ssh.html>
- <https://wezterm.org/config/lua/SshDomain.html>
