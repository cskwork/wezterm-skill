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
-- Cheat sheet: Ctrl+Shift+H은 이 텍스트를 새 탭에 출력. 내용은 아래에 있는
-- 실제 바인딩과 동기 상태를 유지해야 함. 바인딩 추가/변경 시 함께 갱신.
-- (Ctrl+H = ASCII Backspace라 사용 회피, Shift 조합으로 안전하게 둠.)
----------------------------------------------------------------------
local cheatsheet = [[
==============================================================
  WezTerm cheat sheet — generated from your wezterm.lua
  Close this tab: Ctrl+Shift+W   |   Reopen: Ctrl+Shift+H
==============================================================

LEADER prefix: Ctrl+a   (timeout 1s)

Copy / paste / search
  Ctrl+Shift+C                Copy to clipboard + primary
  Ctrl+Shift+V                Paste from clipboard
  Ctrl+Insert                 Copy to primary selection
  Shift+Insert                Paste from primary selection
  Ctrl+Shift+F                Search current selection
  Ctrl+Shift+P                Command palette
  Ctrl+Shift+H                Show this cheat sheet
  Ctrl+Shift+Q                Quit WezTerm

Panes (tmux-style)
  LEADER  \                   Split horizontal (side-by-side)
  LEADER  -                   Split vertical (stacked)
  LEADER  h / j / k / l       Move focus L / D / U / R
  LEADER  z                   Toggle pane zoom
  LEADER  x                   Close current pane

Tabs
  LEADER  c                   New tab (current pane domain)
  LEADER  n / p               Next / previous tab
  Ctrl+Shift+T                New tab (default — built-in)
  Ctrl+Shift+W                Close current tab (built-in)
  Ctrl+Shift+1..9             Activate tab N (built-in)

Workspaces
  LEADER  w                   Fuzzy workspace launcher

Config
  LEADER  r                   Reload config
  Ctrl+Shift+R                Reload config (built-in)
  Ctrl+Shift+L                Debug overlay (Lua errors)

Mouse
  Ctrl+click                  Open URL under cursor
]]

-- WezTerm Lua는 config 로드 시 io.open 사용 가능. config_dir 옆에 파일로 저장.
local cheatsheet_path = wezterm.config_dir .. '/.wezterm-cheatsheet.txt'
local _f = io.open(cheatsheet_path, 'w')
if _f then _f:write(cheatsheet); _f:close() end

----------------------------------------------------------------------
-- Usage tracking (EWMA): 멀티키 바인딩 사용 빈도 학습 → 치트시트 상단에
-- top 10 표시. 단일 키(F-keys 등 mods='NONE')는 instrument()가 자동 통과.
-- JSON 영속화. decay=0.95/day → 반감기 약 13일, 무한 누적 방지.
-- 추적 끄려면 아래 usage.instrument(config.keys) 한 줄만 제거하면 됨.
----------------------------------------------------------------------
local usage = {}
do
  local PATH = wezterm.config_dir .. '/.wezterm-usage.json'
  local DECAY = 0.95
  local DAY = 86400
  local DESC, COUNTS = {}, nil

  local function decay_count(count, last_used, now)
    if not last_used then return count end
    local days = (now - last_used) / DAY
    if days <= 0 then return count end
    return count * (DECAY ^ days)
  end

  local function load()
    if COUNTS then return end
    COUNTS = {}
    local f = io.open(PATH, 'r')
    if not f then return end
    local s = f:read('*a'); f:close()
    if not s or s == '' then return end
    local ok, data = pcall(wezterm.json_parse, s)
    if not (ok and type(data) == 'table') then return end
    local now = os.time()
    for id, v in pairs(data) do
      if type(v) == 'number' then data[id] = { count = v, last_used = now } end
    end
    COUNTS = data
  end

  local function flush()
    local f = io.open(PATH, 'w')
    if f then f:write(wezterm.json_encode(COUNTS)); f:close() end
  end

  function usage.track(id, description, action)
    DESC[id] = description
    return wezterm.action_callback(function(window, pane)
      load()
      local now = os.time()
      local e = COUNTS[id]
      if e then
        e.count = decay_count(e.count, e.last_used, now) + 1
        e.last_used = now
      else
        COUNTS[id] = { count = 1, last_used = now }
      end
      flush()
      window:perform_action(action, pane)
    end)
  end

  function usage.read_top(n)
    load()
    local now = os.time()
    local arr = {}
    for id, e in pairs(COUNTS) do
      table.insert(arr, {
        id = id, description = DESC[id] or id,
        count = decay_count(e.count, e.last_used, now),
      })
    end
    table.sort(arr, function(a, b) return a.count > b.count end)
    local out = {}
    for i = 1, math.min(n, #arr) do out[i] = arr[i] end
    return out
  end

  function usage.instrument(keys)
    for _, k in ipairs(keys) do
      if k.mods and k.mods ~= 'NONE' then
        local id = (tostring(k.mods) .. '+' .. tostring(k.key)):lower()
        k.action = usage.track(id, id, k.action)
      end
    end
    return keys
  end
end

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
-- 스크롤바 thumb이 기본은 탭바 배경색이라 잘 안 보임. 최소 크기 + 명시 색으로 항상 또렷하게.
config.min_scroll_bar_height = '2cell'
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

  -- Ctrl+Shift+H: top-10 사용 빈도 + 정적 cheatsheet를 합쳐 새 탭에 출력.
  -- Ctrl+H = Backspace(0x08)라 회피. 추적 데이터는 .wezterm-usage.json.
  {
    key = 'h', mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local rendered_path = wezterm.config_dir .. '/.wezterm-cheatsheet-rendered.txt'
      local top = usage.read_top(10)
      local lines = { 'TOP 10 MOST USED (EWMA, half-life ~13 days):', '' }
      if #top == 0 then
        table.insert(lines, '  (no data yet — use a few multi-key shortcuts and reopen)')
      else
        for i, e in ipairs(top) do
          table.insert(lines, string.format('  %2d. %-32s x%.1f', i, e.description, e.count))
        end
      end
      table.insert(lines, '')
      table.insert(lines, string.rep('=', 62))
      table.insert(lines, '')
      local f = io.open(rendered_path, 'w')
      if f then f:write(table.concat(lines, '\n') .. '\n' .. cheatsheet); f:close() end

      local args
      if wezterm.target_triple:find('windows') then
        args = { 'pwsh', '-NoLogo', '-NoExit', '-NoProfile', '-Command',
                 'Clear-Host; Get-Content "' .. rendered_path .. '"' }
      else
        args = { 'sh', '-c',
                 'clear; cat "' .. rendered_path .. '"; printf "\\n"; exec ${SHELL:-bash}' }
      end
      window:perform_action(act.SpawnCommandInNewTab { args = args }, pane)
    end),
  },
}

-- 멀티키 바인딩만 추적. mods='NONE' (F-keys 등 단일키)는 자동 통과.
usage.instrument(config.keys)

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
