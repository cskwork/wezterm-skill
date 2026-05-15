# Modular Config Layout

Once a `wezterm.lua` passes ~150 lines it starts to hurt. The community pattern is to split the entry file into focused modules, each exporting a single `apply(config)` function. The entry file becomes a manifest of what gets applied, in order.

## Recommended tree

```
~/.config/wezterm/
├── wezterm.lua          -- entry: requires modules, returns final config
├── lua/
│   ├── helpers.lua      -- OS detection, color utilities, generic helpers
│   ├── appearance.lua   -- font, color_scheme, opacity, padding
│   ├── tabs.lua         -- tab bar formatter, indicators
│   ├── keys.lua         -- leader, config.keys, config.key_tables
│   ├── mouse.lua        -- mouse_bindings
│   ├── workspaces.lua   -- named workspaces, launcher bindings
│   ├── events.lua       -- wezterm.on(...) callbacks (update-status, format-tab-title)
│   └── plugins.lua      -- wezterm.plugin.require(...)
└── colors/              -- optional: hand-rolled scheme files
    └── my-theme.toml
```

On Windows, `~/.config/wezterm/` maps to `%USERPROFILE%\.config\wezterm\`. The single-file form `~/.wezterm.lua` still works, but `~/.config/wezterm/wezterm.lua` is preferred once you go modular — Lua's `require` semantics are cleaner with a real directory.

## Entry file (`wezterm.lua`)

```lua
local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

-- Make ./lua resolvable for require()
package.path = package.path .. ';' .. wezterm.config_dir .. '/lua/?.lua'

-- Apply each module in order. Order matters when later modules read
-- earlier values (e.g. keys.lua may read helpers.is_mac()).
require('helpers'   ).apply(config)
require('appearance').apply(config)
require('tabs'      ).apply(config)
require('keys'      ).apply(config)
require('mouse'     ).apply(config)
require('workspaces').apply(config)
require('events'    ).apply(config)
require('plugins'   ).apply(config)

return config
```

## Module shape

Every module exports a table with a single `apply(config)` method. This convention is what makes the entry file readable.

```lua
-- lua/appearance.lua
local wezterm = require 'wezterm'
local M = {}

function M.apply(config)
  config.color_scheme = 'Catppuccin Mocha'
  config.font = wezterm.font_with_fallback {
    { family = 'JetBrains Mono', weight = 'Medium' },
    'Symbols Nerd Font Mono',
  }
  config.font_size = 12.0
  config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
  config.window_background_opacity = 1.0
end

return M
```

```lua
-- lua/helpers.lua
local wezterm = require 'wezterm'
local M = {}

function M.is_windows() return wezterm.target_triple:find('windows') ~= nil end
function M.is_mac()     return wezterm.target_triple:find('darwin')  ~= nil end
function M.is_linux()   return wezterm.target_triple:find('linux')   ~= nil end

-- Pick a value per OS, like a tiny pattern match.
function M.per_os(map)
  if M.is_windows() and map.windows then return map.windows end
  if M.is_mac()     and map.macos   then return map.macos   end
  if M.is_linux()   and map.linux   then return map.linux   end
  return map.default
end

function M.apply(config)
  -- Helpers module has nothing to apply itself; export functions for others.
end

return M
```

```lua
-- lua/keys.lua
local wezterm = require 'wezterm'
local helpers = require 'helpers'
local act     = wezterm.action
local M       = {}

function M.apply(config)
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

  -- Per-OS copy modifier: Cmd on macOS, Ctrl+Shift elsewhere.
  local copy_mods = helpers.per_os {
    macos   = 'CMD',
    default = 'CTRL|SHIFT',
  }

  config.keys = {
    { key = 'C', mods = copy_mods, action = act.CopyTo 'ClipboardAndPrimarySelection' },
    { key = 'V', mods = copy_mods, action = act.PasteFrom 'Clipboard' },

    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  }
end

return M
```

```lua
-- lua/events.lua
local wezterm = require 'wezterm'
local M       = {}

function M.apply(config)
  wezterm.on('update-status', function(window, pane)
    local workspace = window:active_workspace()
    local time      = wezterm.strftime '%H:%M'
    window:set_right_status(wezterm.format {
      { Foreground = { Color = '#a6e3a1' } }, { Text = '  ' .. workspace .. '  ' },
      { Foreground = { Color = '#f9e2af' } }, { Text = time .. ' ' },
    })
  end)
end

return M
```

## Migration from a single file

1. Create `~/.config/wezterm/lua/` and move all `config.x = ...` blocks into thematic modules.
2. Move any `wezterm.on('...', ...)` callbacks into `events.lua`.
3. Add `package.path` line in the entry file (otherwise `require('helpers')` fails with `module not found`).
4. Reload with `Ctrl+Shift+R`. If the debug overlay shows `module 'X' not found`, your `package.path` is wrong.

## Reload behavior

WezTerm watches the entry file (`wezterm.lua`). When you edit a module like `lua/keys.lua`, the entry file is not touched, so reload does not fire automatically. Fixes:

- Manual reload: `Ctrl+Shift+R` after editing any module.
- Add `automatically_reload_config = true` (default) and `touch wezterm.lua` after module edits.
- Or `config.watch_files = { wezterm.config_dir .. '/lua/keys.lua', ... }` to extend the watch list.

## Why the M.apply(config) pattern

- **Order is explicit** — you can read the entry file and see what runs, in what order.
- **Modules can depend on each other** — `keys.lua` can `require 'helpers'`.
- **Easy to disable** — comment out a single line in the entry file to drop a whole feature.
- **No globals** — each module's state stays in its closure.

## Anti-patterns

- **Don't `require('foo').apply` from inside another module** — that's a side-effecting import. Keep `apply` calls in the entry file only.
- **Don't put `return config` in module files** — the entry is the only file that returns the config table to WezTerm.
- **Don't have modules mutate each other's state via globals** — pass values through helpers or explicit returns.

## Source

Pattern documented in: <https://gist.github.com/johnlindquist/66f8c8251792140e52495eef1c8f4263>
