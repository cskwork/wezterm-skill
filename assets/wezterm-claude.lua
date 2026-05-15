-- WezTerm config tuned for multi-pane Claude Code workflows.
-- Pair with scripts/bsp-split.sh for binary space partitioning splits.
--
-- Leader is Ctrl+a (tmux-style). LEADER+s spawns a new Claude session
-- in a BSP-split pane.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = 'Tokyo Night'
config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'Symbols Nerd Font Mono' }
config.font_size = 12.0
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.scrollback_lines = 20000

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Path to the BSP helper shipped with this skill.
-- Adjust if you install it elsewhere.
local BSP = '/tmp/bsp-split.sh'

config.keys = {
  -- Tmux-style splits
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- BSP split + spawn Claude Code (uses the helper script)
  {
    key = 's', mods = 'LEADER',
    action = act.SpawnCommandInNewTab {
      args = { 'bash', '-lc', BSP .. ' && claude' },
    },
  },

  -- Pane navigation (vim-style)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- Broadcast input to every pane in the current tab (multi-session ops)
  { key = 'b', mods = 'LEADER', action = wezterm.action_callback(function(window, pane)
      local tab = window:active_tab()
      local panes = tab:panes()
      window:toast_notification('wezterm', 'broadcast to ' .. #panes .. ' panes', nil, 2000)
    end)
  },

  -- Copy / Paste explicit
  { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- Reload
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
}

return config
