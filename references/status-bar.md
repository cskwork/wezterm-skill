# Status Bar Customization

WezTerm exposes three independently-styled "status surfaces" you can drive from Lua. Picking the right one matters — they have different space budgets and visibility characteristics.

## The three surfaces

| Surface | API | Lives | When to use |
|---|---|---|---|
| **Left status** | `window:set_left_status(text)` | Inside the tab bar row, left of tabs | Modal indicators (leader active, key-table mode) — short, high-frequency |
| **Right status** | `window:set_right_status(text)` | Inside the tab bar row, right of tabs | Persistent chrome: clock, battery, workspace name |
| **Window title** | `window:set_title(text)` | OS title bar, ABOVE the tab bar | Long context info that would crowd the tab row: full path, git branch, hostname |
| **Tab title** | `wezterm.on('format-tab-title', ...)` | Inside each tab cell | Per-tab info: shell name, foreground process, unseen output |

All four can be active at once. There is no native API for a "second tab-bar row" — the tab bar is single-row by design.

## Common gotcha: left/right status share the tab row

`set_left_status` and `set_right_status` render *inside* the tab bar row. As tabs grow (more tabs, longer titles), they squeeze the status text. If you need a status surface that never fights tabs for space, use the **window title** instead.

The macOS title bar appears by default (`window_decorations = 'TITLE | RESIZE'`). On Linux/Windows it depends on your decoration setting. To keep the title bar visible cross-platform:

```lua
config.window_decorations = 'TITLE | RESIZE'
```

## Recipe: pwd + git branch in the title bar

This pattern is shipped by default in `assets/wezterm.lua` and as a standalone module in `assets/git-pwd-status.lua`. The interesting bits:

```lua
-- Cache git output: update-status fires ~1Hz; without caching, every tick
-- would fork-exec git on the GUI thread.
local cache, CACHE_TTL = {}, 5

local function get_branch(cwd)
  local now = os.time()
  local entry = cache[cwd]
  if entry and (now - entry.checked_at) < CACHE_TTL then return entry.branch end
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

-- pane:get_current_working_dir() returns either a string ("file://host/path")
-- on older WezTerm or a Url object with .file_path on newer versions.
local function pane_cwd(pane)
  local uri = pane:get_current_working_dir()
  if uri == nil then return nil end
  if type(uri) == 'string' then return uri:match('^file://[^/]*(/.+)$') end
  return uri.file_path
end

wezterm.on('update-status', function(window, pane)
  local cwd = pane_cwd(pane)
  if not cwd then window:set_title(''); return end
  local branch = get_branch(cwd)
  if branch then
    window:set_title(cwd .. '   ⎇  ' .. branch)
  else
    window:set_title(cwd)
  end
end)
```

### Why `update-status` and not `format-window-title`?

`format-window-title` only fires on tab/window structural changes. `update-status` fires on a fixed cadence (`status_update_interval`, default 1000ms), so calling `set_title` from inside it gives live updates as the user `cd`s around. The cadence is also the reason caching matters — without it, you'd fork-exec `git` once per second on the GUI thread.

### CWD tracking accuracy

`pane:get_current_working_dir()` is most accurate when the shell emits OSC 7 escape sequences on every directory change. macOS's system zsh does this by default; on Linux you usually need to add a hook (see `references/shell-integration.md`). Without OSC 7, WezTerm falls back to reading the foreground process's cwd via `libproc` (macOS) or `/proc` (Linux) — works, but lags by one tick on rapid `cd`s.

## Recipe: workspace name in the right status

```lua
wezterm.on('update-status', function(window)
  local ws = window:active_workspace()
  window:set_right_status(wezterm.format({
    { Background = { Color = '#1f2335' } },
    { Foreground = { Color = '#7aa2f7' } },
    { Text = '  ' .. ws .. '  ' },
  }))
end)
```

`wezterm.format(items)` returns an escape sequence the status bar renders. `items` is a list of `Foreground`/`Background`/`Attribute`/`Text` records — read like a tiny ANSI builder.

## Recipe: leader-active badge in the left status

```lua
wezterm.on('update-status', function(window)
  if window:leader_is_active() then
    window:set_left_status(wezterm.format({
      { Background = { Color = '#f7768e' } },
      { Foreground = { Color = '#1a1b26' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = '  LEADER  ' },
    }))
  else
    window:set_left_status('')
  end
end)
```

When you have multiple `update-status` handlers writing to the same status surface, the LAST handler registered wins for each tick. To compose, read the existing status (e.g. via a shared module that builds the full string) rather than relying on order.

## Recipe: per-tab pwd + git in `format-tab-title`

If you want the info in each tab rather than the title bar:

```lua
wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, _hover, max_width)
  local pane = tab.active_pane
  -- Inside format-tab-title, `pane` is a PaneInformation table, NOT a Pane object.
  -- It exposes pane.current_working_dir as a Url, and pane.foreground_process_name.
  local cwd_url = pane.current_working_dir
  local cwd = cwd_url and cwd_url.file_path or '?'
  local title = string.format('%d: %s', tab.tab_index + 1, cwd)
  return wezterm.truncate_right(title, max_width)
end)
```

Beware: `format-tab-title` cannot run `wezterm.run_child_process` reliably from inside the callback on every tab redraw — the formatter fires more often than `update-status` and blocking the GUI thread there causes visible jank. If you want git branch per tab, compute it from `update-status` into a `tab_id -> branch` table and read from that table inside `format-tab-title`.

## Anti-patterns

- **Don't fork-exec without caching.** `update-status` fires on a 1Hz default; running `git`, `kubectl`, or any external command on every tick will lag the GUI thread.
- **Don't assume `get_current_working_dir()` returns a string.** Newer WezTerm returns a `Url` object — handle both for compatibility.
- **Don't use `format-window-title` for live data.** It fires on structural changes only. Use `update-status` + `set_title()`.
- **Don't put critical info in `set_left_status` if you have many tabs.** Tabs squeeze it. Use the window title for always-visible info.
- **Don't write to the same status surface from two handlers.** The second registered wins per tick — and you'll wonder why your update keeps getting overwritten.
