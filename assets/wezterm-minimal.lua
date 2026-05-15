-- Minimal WezTerm starter. Add things as you need them.
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 12.0
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = true
config.min_scroll_bar_height = '2cell'
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }

return config
