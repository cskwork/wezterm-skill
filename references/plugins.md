# WezTerm Plugins

WezTerm has a plugin system that pulls Lua modules from any git URL. Plugins live under `$HOME/.local/share/wezterm/plugins/<sanitized-url>/`. The mechanism is intentionally minimal: clone the repo, `require` its `plugin/init.lua`, let it mutate the config table.

## Loading a plugin

```lua
local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

-- Latest main branch
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'

-- Pin to a tag or commit by suffixing the URL
local switcher = wezterm.plugin.require
  'https://github.com/MLFlexer/smart_workspace_switcher.wezterm/tree/v1.6.0'

resurrect.apply_to_config(config)   -- each plugin's API is its own; read its README
switcher.apply_to_config(config)

return config
```

Each plugin's API surface (`apply_to_config`, exposed events, public functions) is defined by the plugin author. Always read the plugin's README before adoption.

## Update mechanism

```bash
# CLI (since WezTerm 20240128)
wezterm cli plugin list
wezterm cli plugin update    # pulls all
```

From Lua you can trigger updates programmatically too:

```lua
wezterm.plugin.update_all()
```

Or `git -C $HOME/.local/share/wezterm/plugins/<url> pull` manually.

## Security note

`wezterm.plugin.require` clones an arbitrary remote and executes its Lua at startup. **Review the source the first time you install a plugin**, prefer pinned tags over `main`, and watch for unexpected diff on `update_all()`. Treat plugins like browser extensions.

## Curated list

The community catalog is at <https://github.com/michaelbrusegard/awesome-wezterm>. Below is a focused short list ranked by adoption.

### Workspace / session

| Plugin | Why |
|---|---|
| [`MLFlexer/resurrect.wezterm`](https://github.com/MLFlexer/resurrect.wezterm) | Save / restore window, tab, pane state across restarts. Closest thing to tmux-resurrect. |
| [`MLFlexer/smart_workspace_switcher.wezterm`](https://github.com/MLFlexer/smart_workspace_switcher.wezterm) | Fuzzy + zoxide workspace switcher. Pair with resurrect for full session management. |
| [`mikkasendke/sessionizer.wezterm`](https://github.com/mikkasendke/sessionizer.wezterm) | Each git repo becomes a workspace, tmux-sessionizer style. |
| [`vieitesss/workspacesionizer.wezterm`](https://github.com/vieitesss/workspacesionizer.wezterm) | Lightweight alternative to the above. |

### Pane navigation

| Plugin | Why |
|---|---|
| [`mrjones2014/smart-splits.nvim`](https://github.com/mrjones2014/smart-splits.nvim) | Unified `Ctrl+h/j/k/l` across Neovim and WezTerm panes. Essential if you live in Neovim. |
| [`sei40kr/wez-pain-control`](https://github.com/sei40kr/wez-pain-control) | tmux-pain-control style bindings out of the box. |
| [`ChrisGVE/pivot_panes.wezterm`](https://github.com/ChrisGVE/pivot_panes.wezterm) | Toggle a pair of panes between horizontal and vertical orientation. |

### Tab bar / status

| Plugin | Why |
|---|---|
| [`adriankarlen/bar.wezterm`](https://github.com/adriankarlen/bar.wezterm) | Full-featured configurable tab bar. Most popular. |
| [`michaelbrusegard/tabline.wez`](https://github.com/michaelbrusegard/tabline.wez) | lualine.nvim-style retro tab bar. |
| [`yriveiro/wezterm-status`](https://github.com/yriveiro/wezterm-status) | Right-side status with battery / CPU / cwd. |

### Productivity

| Plugin | Why |
|---|---|
| [`MLFlexer/modal.wezterm`](https://github.com/MLFlexer/modal.wezterm) | Vim-style modal keybindings with a visual mode indicator. |
| [`abidibo/wezterm-cmdpicker`](https://github.com/abidibo/wezterm-cmdpicker) | Fuzzy picker over your keybindings — discoverability when you forget a binding. |
| [`dfsramos/wezterm-sync`](https://github.com/dfsramos/wezterm-sync) | Sync config across machines via GitHub Gist. |
| [`koh-sh/wezterm-theme-rotator`](https://github.com/koh-sh/wezterm-theme-rotator) | Hotkey cycles through built-in color schemes. |

## A worked example: resurrect + workspace switcher + bar

```lua
local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

config.color_scheme = 'Catppuccin Mocha'
config.font         = wezterm.font 'JetBrains Mono'
config.font_size    = 12.0

-- Plugins
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'
local switcher  = wezterm.plugin.require 'https://github.com/MLFlexer/smart_workspace_switcher.wezterm'
local bar       = wezterm.plugin.require 'https://github.com/adriankarlen/bar.wezterm'

bar.apply_to_config(config, {
  position    = 'bottom',
  max_width   = 32,
  modules     = { workspace = { enabled = true }, leader = { enabled = true } },
})

-- Workspace switcher needs a binding; example via LEADER+s
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 's', mods = 'LEADER', action = switcher.switch_workspace() },
  -- Resurrect: save current state, restore on launch
  { key = 'S', mods = 'LEADER', action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
  end) },
}

-- On startup, auto-restore the last workspace
wezterm.on('gui-startup', function()
  resurrect.state_manager.periodic_save({ interval_seconds = 60 * 5 })
end)

return config
```

## When NOT to use plugins

- If a 10-line snippet does the same thing, just write the snippet — plugins are a maintenance dependency.
- If your team shares the config, plugins increase setup burden for everyone.
- If you're new to WezTerm — get the base config right first, then layer plugins.

## Sources

- <https://wezterm.org/config/plugins.html>
- <https://github.com/michaelbrusegard/awesome-wezterm>
