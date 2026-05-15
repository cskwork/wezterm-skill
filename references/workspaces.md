# Workspaces

A workspace in WezTerm is a named collection of tabs and panes. Think of it as a project context — each workspace has its own tab strip, independent of the others. When you switch workspaces, the entire visible terminal state swaps out.

## Core mental model

| Concept | What it is |
|---|---|
| Window | A native OS window |
| Workspace | A named collection of tabs visible in one window at a time |
| Tab | A horizontal slot in the tab bar; can contain multiple panes |
| Pane | A subdivision of a tab |

You can have N windows. Each window shows one workspace at a time. The set of workspaces is global — switching workspaces in one window changes that window's tabs, the others stay on their workspace.

## Inspecting workspaces

```bash
# Every pane with its workspace
wezterm cli list --format json | jq '.[] | {pane_id, workspace, title}'

# Unique workspaces
wezterm cli list --format json | jq -r '.[].workspace' | sort -u
```

The currently active workspace for the focused window:

```lua
wezterm.on('update-status', function(window, pane)
  wezterm.log_info('current workspace = ' .. window:active_workspace())
end)
```

## Built-in keybindings

| Keys | Action |
|---|---|
| `Ctrl+Shift+P` | Open command palette, then type "workspace" |
| `Ctrl+Shift+Space` (default) | Workspace launcher (fuzzy) — actually quick-select; bind below for workspace |

Add a dedicated binding:

```lua
config.keys = {
  -- Workspace launcher (fuzzy)
  { key = 'w', mods = 'LEADER', action = wezterm.action.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
  } },

  -- Rename current workspace via prompt
  { key = '$', mods = 'LEADER|SHIFT', action = wezterm.action.PromptInputLine {
      description = 'Rename workspace:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
        end
      end),
  } },

  -- Next / previous workspace
  { key = ']', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(1)  },
  { key = '[', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(-1) },
}
```

## Creating named workspaces

Three ways:

1. **From the launcher** — `LEADER w`, then type a new name, hit Enter. WezTerm creates the workspace and switches to it.
2. **From the CLI** — when spawning:
   ```bash
   wezterm cli spawn --new-window --workspace dev -- bash -lc 'cd ~/code && exec $SHELL'
   ```
3. **At startup** — in `wezterm.lua`:
   ```lua
   config.default_workspace = 'dev'
   ```

## Renaming

```bash
# CLI
wezterm cli rename-workspace --workspace dev project-x

# Lua (inside a callback)
local mux = wezterm.mux
mux.rename_workspace('dev', 'project-x')
```

## Auto-bootstrap multiple workspaces on launch

```lua
wezterm.on('gui-startup', function(cmd)
  local mux = wezterm.mux
  local _, _, window = mux.spawn_window {
    workspace = 'main',
    cwd = wezterm.home_dir,
  }
  mux.spawn_window {
    workspace = 'notes',
    cwd = wezterm.home_dir .. '/notes',
  }
  mux.spawn_window {
    workspace = 'logs',
    cwd = '/var/log',
    args = { 'tail', '-f', '/var/log/syslog' },
  }
  -- Activate the one we want focused
  window:gui_window():perform_action(
    wezterm.action.SwitchToWorkspace { name = 'main' },
    window:active_pane()
  )
end)
```

## Persistence across GUI restarts

WezTerm itself does not save workspace layouts to disk. Two patterns:

### 1. Unix multiplexer (built-in)

Run a long-lived mux server; the GUI is just a client. When the GUI quits, the mux survives. Restart the GUI and reattach.

```lua
config.unix_domains = { { name = 'main' } }
config.default_gui_startup_args = { 'connect', 'main' }
```

Now `wezterm` always connects to the local mux. Kill the GUI, relaunch — your panes are still there, running.

### 2. resurrect.wezterm plugin

Saves the *shape* (which panes, which CWD, which titles) but not the in-memory shell state. Restores after reboots. See `references/plugins.md` for setup.

```lua
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'
resurrect.state_manager.periodic_save { interval_seconds = 300 }
```

## Displaying the current workspace in the status bar

```lua
wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace()
  local leader    = window:leader_is_active() and ' LEADER ' or ''
  window:set_right_status(wezterm.format {
    { Background = { Color = '#1e1e2e' } },
    { Foreground = { Color = '#a6e3a1' } }, { Text = ' ' .. workspace .. ' ' },
    { Foreground = { Color = '#f9e2af' } }, { Text = leader },
  })
end)
```

## Recipes

### Per-project workspace from the CLI

```bash
# Wrap into a function in ~/.bashrc / ~/.zshrc
wezws() {
  local dir="${1:-$(pwd)}"
  local name="$(basename "$dir")"
  wezterm cli spawn --new-window --workspace "$name" --cwd "$dir"
}

# Usage:
wezws ~/code/project-x
```

### Switch and run a command

```bash
wezterm cli spawn --workspace logs --cwd /var/log -- bash -lc 'tail -f syslog'
```

(Yes, this is one of the rare cases where `-- cmd` is fine — it spawns a new pane in the chosen workspace, the new pane's *shell* runs the command, just inside the explicit `bash -lc`.)

## Gotchas

- Workspaces share the global mux; closing the last window of a workspace does not delete the workspace — its panes keep running headless. Use `wezterm cli kill-pane` or quit the panes from inside to fully clean up.
- `SwitchToWorkspace { name = 'X' }` creates `X` if it doesn't exist. If you want a strict switch (fail when missing), check `wezterm.mux.get_workspace_names()` first.
- `default_workspace` is only the *name* assigned to the initial workspace on launch — it does not auto-create panes.

## Sources

- <https://wezterm.org/config/lua/keyassignment/SwitchToWorkspace.html>
- <https://wezterm.org/config/lua/wezterm.mux/index.html>
- <https://gist.github.com/johnlindquist/f5befe0c3e58b54717fe22b89467c4eb>
