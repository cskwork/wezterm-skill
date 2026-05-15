-- catppuccin/wezterm starter — OS-appearance-aware Catppuccin
-- 원본 README 의 appearance-sync 예제를 토대로 즉시 사용 가능한 형태로 정리
-- License: MIT (catppuccin/wezterm)

local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

----------------------------------------------------------------------
-- 1. OS 다크/라이트 모드에 따라 플레이버 자동 선택
----------------------------------------------------------------------
local function scheme_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'Catppuccin Mocha'      -- 가장 어두운 플레이버
  else
    return 'Catppuccin Latte'      -- 가장 밝은 플레이버
  end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

-- 실시간 외관 변경에도 대응 (macOS / Windows)
wezterm.on('window-config-reloaded', function(window, _)
  local overrides = window:get_config_overrides() or {}
  local target = scheme_for_appearance(window:get_appearance())
  if overrides.color_scheme ~= target then
    overrides.color_scheme = target
    window:set_config_overrides(overrides)
  end
end)

----------------------------------------------------------------------
-- 2. 가독성 좋은 기본값 (선택, 자유롭게 수정)
----------------------------------------------------------------------
config.font            = wezterm.font_with_fallback({ 'JetBrains Mono', 'Consolas' })
config.font_size       = 12
config.window_padding  = { left = 8, right = 8, top = 8, bottom = 8 }
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity    = 0.97  -- 살짝 투명; 1.0 으로 두면 완전 불투명
config.scrollback_lines             = 10000
config.audible_bell                 = 'Disabled'

----------------------------------------------------------------------
-- 3. tmux 스타일 리더 키 + 패널 분할 (옵션)
----------------------------------------------------------------------
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1500 }
config.keys = {
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'LEADER',       action = wezterm.action.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER',       action = wezterm.action.CloseCurrentPane { confirm = true } },
  { key = 'c', mods = 'LEADER',       action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
}

return config
