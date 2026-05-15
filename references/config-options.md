# WezTerm Config Options

Source: <https://wezterm.org/config/lua/config/index.html>

Use `wezterm.config_builder()` — it validates option names and gives clearer errors than a bare table.

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
-- ... set fields on config ...
return config
```

## Appearance

| Field | Type | Notes |
|---|---|---|
| `color_scheme` | string | Built-in theme name (see `color-schemes.md`) |
| `colors` | table | Override individual colors (foreground, background, ansi, brights) |
| `font` | font | `wezterm.font 'Name'` or `wezterm.font_with_fallback { ... }` |
| `font_size` | number | Points |
| `line_height` | number | Multiplier (1.0 default, 1.05–1.2 reads nicer) |
| `cell_width` | number | Horizontal cell scale |
| `bold_brightens_ansi_colors` | bool | Default true |
| `window_background_opacity` | 0.0–1.0 | True transparency |
| `text_background_opacity` | 0.0–1.0 | Transparency behind text only |
| `macos_window_background_blur` | int | macOS blur radius |
| `win32_acrylic_accent_color` | string | Windows acrylic tint |
| `window_padding` | table | `{ left, right, top, bottom }` in px |
| `window_decorations` | string | `'TITLE \| RESIZE'`, `'RESIZE'`, `'NONE'` |
| `default_cursor_style` | string | `BlinkingBar`, `SteadyBar`, `BlinkingBlock`, `SteadyBlock`, ... |
| `cursor_blink_rate` | int | ms |

## Tabs

| Field | Type | Notes |
|---|---|---|
| `enable_tab_bar` | bool | Toggle bar entirely |
| `hide_tab_bar_if_only_one_tab` | bool | Auto-hide for single tab |
| `use_fancy_tab_bar` | bool | Rounded tabs vs. flat |
| `tab_bar_at_bottom` | bool | Move bar below panes |
| `tab_max_width` | int | Truncate long titles |
| `show_new_tab_button_in_tab_bar` | bool | The `+` button |
| `show_tab_index_in_tab_bar` | bool | Prefix titles with `N:` |

## Behavior

| Field | Type | Notes |
|---|---|---|
| `default_prog` | array | E.g. `{ 'pwsh.exe', '-NoLogo' }` on Windows |
| `default_cwd` | string | Override starting directory |
| `set_environment_variables` | table | `{ KEY = 'value' }` |
| `scrollback_lines` | int | Per-pane history |
| `enable_scroll_bar` | bool | Show scrollbar gutter |
| `scroll_to_bottom_on_input` | bool | Jump on keypress |
| `audible_bell` | string | `Disabled` or `SystemBeep` |
| `visual_bell` | table | Flash on bell |
| `exit_behavior` | string | `Close`, `Hold`, `CloseOnCleanExit` |
| `automatically_reload_config` | bool | Default true |
| `warn_about_missing_glyphs` | bool | Default true |

## Keys

| Field | Notes |
|---|---|
| `leader` | `{ key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }` |
| `keys` | List of `{ key, mods, action }` entries |
| `key_tables` | Named modal binding sets, entered via `ActivateKeyTable` |
| `disable_default_key_bindings` | bool | Start from a clean slate |
| `disable_default_mouse_bindings` | bool | Same for mouse |
| `mouse_bindings` | List of mouse bindings |

## Multiplexing / domains

| Field | Notes |
|---|---|
| `unix_domains` | List of unix-socket muxes for persistent sessions |
| `ssh_domains` | Declarative SSH multiplexer endpoints |
| `wsl_domains` | WSL distributions to expose |
| `default_domain` | Pick which domain a new tab uses |
| `default_workspace` | Initial workspace name |
| `default_gui_startup_args` | Args passed to wezterm on launch (e.g. `{ 'connect', 'main' }`) |

## Performance

| Field | Notes |
|---|---|
| `front_end` | `OpenGL` (default), `Software`, `WebGpu` |
| `webgpu_power_preference` | `LowPower` or `HighPerformance` |
| `max_fps` | Cap GPU frames per second |
| `animation_fps` | Animation refresh rate |
| `prefer_egl` | Linux GLX/EGL choice |

## Starter pattern

```lua
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 12.0
config.window_background_opacity = 0.95
config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000

return config
```

## Inspecting your effective config

```bash
wezterm show-keys --lua             # active keybindings
wezterm -n start                    # launch without your config (sanity check)
wezterm --config-file ./test.lua    # temporarily try a config
wezterm --config color_scheme='Dracula' start
```
