# WezTerm CLI Reference

Source: <https://wezterm.org/cli/general.html>

WezTerm ships with the `wezterm` binary and a powerful `wezterm cli` subcommand that talks to the running GUI via its multiplexer.

## Top-level commands

| Command | Purpose |
|---|---|
| `wezterm start [-- prog]` | Launch the GUI; optionally run a program in the initial tab |
| `wezterm ssh user@host` | Open an SSH session in a new window |
| `wezterm serial /dev/ttyUSB0` | Connect to a serial port |
| `wezterm connect <domain>` | Connect to a multiplexer domain (e.g. `unix`) |
| `wezterm ls-fonts` | List available fonts (`--list-system` for all installed) |
| `wezterm show-keys [--lua]` | Dump the active keybindings (Lua form is paste-ready) |
| `wezterm imgcat path.png` | Render an image inline in the terminal |
| `wezterm set-working-directory` | Emit OSC 7 so wezterm knows the CWD |
| `wezterm record` / `replay` | Record/replay sessions as asciicast |
| `wezterm shell-completion --shell zsh` | Print shell completion script |

### Common top-level flags

| Flag | Effect |
|---|---|
| `-n, --skip-config` | Start without loading `wezterm.lua` (useful for debugging) |
| `--config-file PATH` | Load a specific config file |
| `--config NAME=VALUE` | Override one config option from the command line |

## `wezterm cli` subcommands

These require a running WezTerm GUI to talk to.

| Subcommand | Purpose |
|---|---|
| `list [--format json]` | Dump all windows / tabs / panes (most useful with `json`) |
| `list-clients` | List connected multiplexer clients |
| `spawn` | Create a new tab or window (`--new-window`, `--workspace NAME`) |
| `split-pane` | Split the current pane (`--right`, `--bottom`, `--left`, `--top`, `--percent N`) |
| `send-text` | Send text to a pane via stdin pipe |
| `kill-pane` | Close a pane |
| `activate-pane` | Focus a pane by id |
| `activate-pane-direction` | Focus the pane in a direction (`--left`, etc.) |
| `activate-tab` | Focus a tab by id or index |
| `set-tab-title` | Rename a tab |
| `get-text` | Read the text content of a pane |
| `rename-workspace` | Rename a workspace |
| `zoom-pane` | Toggle pane zoom |
| `move-pane-to-new-tab` | Move a pane into a new tab |
| `adjust-pane-size` | Resize a pane (`--amount N`, `--direction Up/Down/Left/Right`) |
| `get-pane-direction` | Query which pane lies in a direction from another |

### Identifying panes

Most subcommands accept `--pane-id N`. Inside a pane the environment variable `$WEZTERM_PANE` holds the current id, which makes scripts predictable:

```bash
PANE_ID="${WEZTERM_PANE}"
wezterm cli activate-pane --pane-id "$PANE_ID"
```

If you omit `--pane-id`, the command targets the focused pane (usually the one you launched the command from).

## Canonical patterns

### Split + start a command, preserving shell PATH

```bash
PANE_ID=$(wezterm cli split-pane --right --percent 40)
printf 'claude\n' | wezterm cli send-text --pane-id "$PANE_ID"
```

Do not use `wezterm cli split-pane -- claude`. That form runs `claude` directly without going through your shell, so PATH, aliases, and shell init are skipped.

### Spawn into a named workspace

```bash
wezterm cli spawn --new-window --workspace dev -- bash -lc 'cd ~/code && exec $SHELL'
```

### Inspect layout as JSON

```bash
wezterm cli list --format json | jq '.[] | {pane_id, tab_id, size, cwd}'
```

### Send a multi-line block safely

```bash
printf '%s\n' "echo hello" "echo world" | wezterm cli send-text --pane-id "$PANE_ID"
```

Avoid embedding `\n` in shell string escapes — quoting rules differ between bash/zsh/pwsh and break in loops. `printf` with explicit `\n` is portable.

### Dump current keybindings to your config

```bash
wezterm show-keys --lua > my-keys.lua
```

Then copy what you want into `wezterm.lua`.

## Multiplexer (`wezterm connect`)

Define a domain in `wezterm.lua`:

```lua
config.unix_domains = { { name = 'main' } }
config.default_gui_startup_args = { 'connect', 'main' }
```

Then `wezterm connect main` attaches to that mux. The mux survives GUI restarts — useful as a tmux replacement.
