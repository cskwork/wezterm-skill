# Type Completion for `wezterm.lua`

WezTerm's config is plain Lua. By default editors give you nothing — no autocomplete on `config.`, no signature help on `wezterm.action.SplitHorizontal { ... }`, no doc on hover. Wiring up `lua-language-server` + community type annotations fixes this and is the single highest-ROI tooling change for anyone writing more than a starter config.

## What you get

- Autocomplete every config option, action, and event name
- Inline docs on hover for every field
- Type-checking on action payloads (`SplitHorizontal { direction = ...}` warns on typos)
- Jump-to-definition into the type stubs to see what a function accepts

## Setup

### 1. Install `lua-language-server`

| Platform | Command |
|---|---|
| macOS | `brew install lua-language-server` |
| Windows | `winget install LuaLS.lua-language-server` or download from <https://github.com/LuaLS/lua-language-server/releases> |
| Linux | Package manager or download release tarball |

### 2. Pick a type-stubs source

Two community sources, both work:

- [`DrKJeff16/wezterm-types`](https://github.com/DrKJeff16/wezterm-types) — actively maintained, includes plugin type extensions
- [`justinsgithub/wezterm-types`](https://github.com/justinsgithub/wezterm-types) — older but still complete

Clone or symlink one of them into a known location:

```bash
git clone https://github.com/DrKJeff16/wezterm-types ~/wezterm-types
```

### 3. Tell `lua-language-server` where the stubs are

Create `.luarc.json` next to your `wezterm.lua` (or `~/.config/wezterm/.luarc.json`):

```json
{
  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
  "runtime": {
    "version": "Lua 5.4"
  },
  "workspace": {
    "library": [
      "~/wezterm-types"
    ],
    "checkThirdParty": false
  },
  "diagnostics": {
    "globals": ["wezterm"]
  }
}
```

Path notes:
- `~/` expands in newer `lua-language-server` builds. If it doesn't, use the absolute path.
- On Windows: `"C:/Users/me/wezterm-types"` (forward slashes are fine).

### 4. Editor setup

**VSCode** — install the `sumneko.lua` extension. It picks up `.luarc.json` automatically.

**Neovim with nvim-lspconfig**:

```lua
require('lspconfig').lua_ls.setup {
  settings = {
    Lua = {
      runtime = { version = 'Lua 5.4' },
      workspace = { library = { vim.fn.expand('~/wezterm-types') } },
      diagnostics = { globals = { 'wezterm' } },
    },
  },
}
```

**JetBrains IDEs (IntelliJ, etc.)** — install the EmmyLua or SumnekoLua plugin and point it at the types directory in Settings → Lua.

### 5. (Optional) Annotate your config

The language server picks up types implicitly, but you can be explicit for clarity:

```lua
local wezterm = require 'wezterm'
---@type Wezterm
local config = wezterm.config_builder()

---@cast config Wezterm.Config
config.color_scheme = 'Catppuccin Mocha'
```

For module files in a modular layout:

```lua
-- lua/keys.lua
local M = {}

---@param config Wezterm.Config
function M.apply(config)
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
end

return M
```

## Verifying it works

1. Open your `wezterm.lua` in the editor.
2. Type `config.colo` — autocomplete should suggest `color_scheme`, `colors`, `color_schemes`.
3. Type `wezterm.action.` — popup should list `SplitHorizontal`, `SplitVertical`, `ActivatePaneDirection`, ... .
4. Hover over a known field like `config.window_padding` — should show the type and docstring.

If you only see the global `wezterm` highlighted as unknown, your `diagnostics.globals` entry is missing. If autocomplete is empty, your `workspace.library` path is wrong.

## Keeping stubs current

WezTerm adds options every release. Re-pull the types repo when you upgrade WezTerm:

```bash
cd ~/wezterm-types && git pull
```

Both `DrKJeff16/wezterm-types` and `justinsgithub/wezterm-types` track upstream WezTerm tags.

## Sources

- <https://github.com/LuaLS/lua-language-server>
- <https://github.com/DrKJeff16/wezterm-types>
- <https://github.com/justinsgithub/wezterm-types>
