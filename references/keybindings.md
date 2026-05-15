# WezTerm Keybindings Reference

Source: <https://wezterm.org/config/default-keys.html>

## Default keybindings

`Super` is the Command key on macOS and the Windows / Meta key on Linux/Windows. On Linux/Windows the `Ctrl+Shift` variants below are the practical defaults.

### Copy / Paste
| Key | Action |
|---|---|
| `Super+C` / `Ctrl+Shift+C` | Copy selection to clipboard |
| `Super+V` / `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+Insert` | Copy to primary selection |
| `Shift+Insert` | Paste from primary selection |

### Pane management
| Key | Action |
|---|---|
| `Ctrl+Shift+Alt+"` | Split vertically |
| `Ctrl+Shift+Alt+%` | Split horizontally |
| `Ctrl+Shift+Arrow` | Navigate between panes |
| `Ctrl+Shift+Alt+Arrow` | Resize pane |
| `Ctrl+Shift+Z` | Toggle zoom |

### Tabs
| Key | Action |
|---|---|
| `Super+T` / `Ctrl+Shift+T` | New tab |
| `Super+[1-9]` / `Ctrl+Shift+[1-9]` | Jump to tab N |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Tab` | Next tab |
| `Super+W` / `Ctrl+Shift+W` | Close tab |

### Font size
| Key | Action |
|---|---|
| `Ctrl+=` | Increase |
| `Ctrl+-` | Decrease |
| `Ctrl+0` | Reset |

### Search and selection
| Key | Action |
|---|---|
| `Ctrl+Shift+F` | Search |
| `Ctrl+Shift+X` | Copy mode (vim-like motions) |
| `Ctrl+Shift+Space` | Quick select (regex-driven hint mode) |
| `Ctrl+Shift+U` | Character / emoji picker |

### Utilities
| Key | Action |
|---|---|
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+L` | Debug overlay (config errors live here) |
| `Ctrl+Shift+R` | Reload config |

## Custom binding cheatsheet

```lua
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Leader key (tmux-style). LEADER acts as a modifier in subsequent entries.
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Splits
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- Vim-style pane navigation
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },

  -- Pane management
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- Resize via key_table (LEADER+r enters resize mode for 4 seconds)
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable {
      name = 'resize', one_shot = false, timeout_milliseconds = 4000,
  } },

  -- Tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- Workspaces (persistent named sessions)
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

  -- Command palette and search
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
}

config.key_tables = {
  resize = {
    { key = 'h', action = act.AdjustPaneSize { 'Left',  5 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up',    5 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down',  5 } },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config
```

## Key action quick reference

| Action | Use |
|---|---|
| `CopyTo 'Clipboard'` | Copy selection |
| `CopyTo 'ClipboardAndPrimarySelection'` | Copy to both (Linux convention) |
| `PasteFrom 'Clipboard'` | Paste |
| `SplitHorizontal { domain = 'CurrentPaneDomain' }` | Side-by-side |
| `SplitVertical   { domain = 'CurrentPaneDomain' }` | Stacked |
| `ActivatePaneDirection 'Left'\|'Right'\|'Up'\|'Down'` | Focus neighbor |
| `TogglePaneZoomState` | Maximize/restore pane |
| `CloseCurrentPane { confirm = true }` | Close with prompt |
| `SpawnTab 'CurrentPaneDomain'` | New tab in same shell |
| `ActivateTabRelative(N)` | Next/prev tab |
| `ActivateCommandPalette` | Searchable command palette |
| `ShowLauncherArgs { flags = 'FUZZY\|WORKSPACES' }` | Workspace switcher |
| `SendString "echo hi\r"` | Inject text into the pane |
| `ActivateKeyTable { name = 'X', one_shot = false }` | Modal key tables (resize, copy, etc.) |
| `PopKeyTable` | Exit a modal key table |
| `ReloadConfiguration` | Re-read `wezterm.lua` |

## Inspecting what is bound right now

```bash
wezterm show-keys --lua   # paste-ready Lua you can copy into wezterm.lua
wezterm show-keys         # human-readable form
```

## Tips

- Wrap modal flows (resize, navigation) in a `key_table` instead of using a long chain of `LEADER+...` bindings. Modes are discoverable and easier to extend.
- Avoid binding common shell shortcuts (`Ctrl+A`, `Ctrl+E`, `Ctrl+W`) as plain keys — choose them only for `LEADER` so they pass through to your shell normally.
- The debug overlay (`Ctrl+Shift+L`) prints which binding fired on every key press; use it when something does not behave as expected.
