-- WezTerm default config
-- Drop in at one of:
--   ~/.wezterm.lua
--   ~/.config/wezterm/wezterm.lua
--   %USERPROFILE%\.wezterm.lua  (Windows)
--
-- Reload after editing with Ctrl+Shift+R (or Super+R on macOS).
-- Debug overlay (errors): Ctrl+Shift+L.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

----------------------------------------------------------------------
-- Appearance
----------------------------------------------------------------------
config.color_scheme = 'Catppuccin Mocha'

config.font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono', weight = 'Medium' },
  'Noto Color Emoji',
  'Symbols Nerd Font Mono',
}
config.font_size = 12.0
config.line_height = 1.05

config.window_background_opacity = 0.96
config.macos_window_background_blur = 20

config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
config.window_decorations = 'RESIZE'
config.adjust_window_size_when_changing_font_size = false

config.cursor_blink_rate = 500
config.default_cursor_style = 'BlinkingBar'

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

----------------------------------------------------------------------
-- Behavior
----------------------------------------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.audible_bell = 'Disabled'
config.exit_behavior = 'CloseOnCleanExit'
config.warn_about_missing_glyphs = false

-- Pick a sensible default shell per OS.
if wezterm.target_triple:find('windows') then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

----------------------------------------------------------------------
-- Copy / Paste
-- (Defaults are fine; these make the behavior explicit and add
--  Ctrl+Insert / Shift+Insert for parity with Linux conventions.)
----------------------------------------------------------------------
config.keys = {
  { key = 'C',      mods = 'CTRL|SHIFT', action = act.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'V',      mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'Insert', mods = 'CTRL',       action = act.CopyTo 'PrimarySelection' },
  { key = 'Insert', mods = 'SHIFT',      action = act.PasteFrom 'PrimarySelection' },

  ----------------------------------------------------------------------
  -- Panes (tmux-style with LEADER = Ctrl+a)
  ----------------------------------------------------------------------
  { key = '\\',     mods = 'LEADER',     action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-',      mods = 'LEADER',     action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'h',      mods = 'LEADER',     action = act.ActivatePaneDirection 'Left' },
  { key = 'l',      mods = 'LEADER',     action = act.ActivatePaneDirection 'Right' },
  { key = 'k',      mods = 'LEADER',     action = act.ActivatePaneDirection 'Up' },
  { key = 'j',      mods = 'LEADER',     action = act.ActivatePaneDirection 'Down' },
  { key = 'z',      mods = 'LEADER',     action = act.TogglePaneZoomState },
  { key = 'x',      mods = 'LEADER',     action = act.CloseCurrentPane { confirm = true } },

  ----------------------------------------------------------------------
  -- Tabs
  ----------------------------------------------------------------------
  { key = 'c',      mods = 'LEADER',     action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n',      mods = 'LEADER',     action = act.ActivateTabRelative(1) },
  { key = 'p',      mods = 'LEADER',     action = act.ActivateTabRelative(-1) },

  ----------------------------------------------------------------------
  -- Workspaces
  ----------------------------------------------------------------------
  { key = 'w',      mods = 'LEADER',     action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

  ----------------------------------------------------------------------
  -- Misc
  ----------------------------------------------------------------------
  { key = 'r',      mods = 'LEADER',     action = act.ReloadConfiguration },
  { key = 'f',      mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'p',      mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  -- WezTerm은 QuitApplication을 기본 바인딩하지 않음. Ctrl+Shift+Q로 전체 종료.
  { key = 'q',      mods = 'CTRL|SHIFT', action = act.QuitApplication },
}

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

----------------------------------------------------------------------
-- Mouse: open links on Ctrl+click without losing selection
----------------------------------------------------------------------
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

return config
