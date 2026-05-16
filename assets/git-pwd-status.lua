-- git-pwd-status.lua
-- Show current pwd and git branch in the macOS/OS window title bar
-- (the row above the tab bar). Works with any base config — drop the file
-- next to your wezterm.lua and add:
--
--   require('git-pwd-status').setup()
--
-- Why the title bar instead of left/right status:
--   set_left_status / set_right_status both render INSIDE the tab bar row,
--   competing for space with tabs. The OS title bar sits ABOVE the tab bar
--   and is always visible, giving a clean "second header line".
--
-- Requirements:
--   - window_decorations must include 'TITLE' (the WezTerm default on macOS).
--     If you set window_decorations = 'RESIZE', the OS title bar is hidden
--     and this module silently no-ops on the visual side.
--   - For accurate cwd tracking when a child process changes directories,
--     enable OSC 7 in your shell (see references/shell-integration.md).
--     Without OSC 7, WezTerm falls back to libproc on macOS / /proc on Linux,
--     which still works but is one tick behind on rapid cd's.

local wezterm = require('wezterm')

local M = {}

-- Cache: cwd -> { branch = string|false, checked_at = epoch_seconds }
-- update-status fires ~1Hz; without caching, every tick would fork-exec git
-- on the GUI thread. 5s TTL keeps branch info fresh enough for most workflows
-- while bounding spawn cost.
local cache = {}
local CACHE_TTL = 5

local function get_branch(cwd)
   local now = os.time()
   local entry = cache[cwd]
   if entry and (now - entry.checked_at) < CACHE_TTL then
      return entry.branch
   end

   local ok, stdout = wezterm.run_child_process({
      'git', '-C', cwd, 'branch', '--show-current',
   })
   local branch = false
   if ok then
      local trimmed = (stdout or ''):gsub('%s+$', '')
      if trimmed ~= '' then branch = trimmed end
   end
   cache[cwd] = { branch = branch, checked_at = now }
   return branch
end

local function pane_cwd(pane)
   -- pane:get_current_working_dir() returns:
   --   - nil if no shell integration / OSC 7
   --   - string "file://host/path" on older WezTerm
   --   - Url object with .file_path on newer WezTerm
   local uri = pane:get_current_working_dir()
   if uri == nil then return nil end
   if type(uri) == 'string' then
      return uri:match('^file://[^/]*(/.+)$')
   end
   return uri.file_path
end

local function home_shorten(path)
   local home = wezterm.home_dir
   if path:sub(1, #home) == home then
      return '~' .. path:sub(#home + 1)
   end
   return path
end

---@param opts? { branch_glyph?: string }
M.setup = function(opts)
   opts = opts or {}
   -- Default uses U+2387 ALTERNATIVE KEY SYMBOL "⎇" — renders without Nerd Font.
   -- Set to '' to suppress, or '\u{e0a0}' for Powerline branch glyph (needs Nerd Font).
   local glyph = opts.branch_glyph or '⎇'

   wezterm.on('update-status', function(window, pane)
      local cwd = pane_cwd(pane)
      if not cwd then
         window:set_title('')
         return
      end

      local display = home_shorten(cwd)
      local branch = get_branch(cwd)

      if branch then
         window:set_title(display .. '   ' .. glyph .. '  ' .. branch)
      else
         window:set_title(display)
      end
   end)
end

return M
