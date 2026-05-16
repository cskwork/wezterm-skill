---
name: wezterm
description: Configure, customize, and operate the WezTerm terminal emulator. Use when the user wants to set up a WezTerm config (fonts, themes, keybindings, copy-paste, panes, tabs), troubleshoot config errors, drive WezTerm via its CLI (split-pane, send-text, spawn, list), or wire up multi-pane workflows (Claude Code, tmux-style sessions, SSH/multiplexing domains). Also triggers on "WezTerm 설정", "터미널 색상", "wezterm.lua".
---

# WezTerm Skill

You are an expert assistant for the WezTerm terminal emulator. WezTerm is configured in Lua and exposes a powerful CLI for driving panes, tabs, and remote multiplexers.

## When to use this skill

Triggers:
- User wants to create, edit, or debug a `wezterm.lua` config
- User asks about copy/paste, fonts, color schemes, keybindings, tab bar, opacity, padding
- User wants to drive WezTerm from a script: `wezterm cli split-pane`, `send-text`, `spawn`, `list`
- User wants a multi-pane workflow (e.g. several Claude Code sessions, BSP layout, dev server + logs)
- User mentions SSH domains, unix multiplexer, `wezterm connect`, persistent sessions

## Operating procedure

1. **Detect the config path** before editing:
   - Linux/macOS: `~/.wezterm.lua` or `~/.config/wezterm/wezterm.lua`
   - Windows: `%USERPROFILE%\.wezterm.lua` or `%USERPROFILE%\.config\wezterm\wezterm.lua`
   - If none exists and the user wants a starter, copy `assets/wezterm.lua` from this skill.

2. **Always use `wezterm.config_builder()`** in new configs — it gives clearer error messages than a bare table.

3. **Preserve existing config**. Read the file first, then make surgical edits. Do not rewrite the whole file unless the user asks.

4. **Verify against current docs**. WezTerm's API changes; if you are unsure about a key name, fetch the current page from `https://wezterm.org` rather than guessing. Common doc paths:
   - `https://wezterm.org/config/lua/config/index.html` — config options
   - `https://wezterm.org/config/lua/keyassignment/<Name>.html` — key action reference
   - `https://wezterm.org/colorschemes/index.html` — full theme list
   - `https://wezterm.org/cli/general.html` — CLI subcommands

5. **Reload after editing**. WezTerm watches the config file and reloads automatically; user can force reload with `Ctrl+Shift+R` (or `Super+R` on macOS). If the config has an error, WezTerm shows it in the debug overlay (`Ctrl+Shift+L`).

## Default starter config

If the user wants a sensible default (covers copy-paste, fonts, theme, panes, tabs, opacity), copy `assets/wezterm.lua` from this skill to the user's config location. Confirm overwrite before replacing an existing file.

For a tiny minimal config, use `assets/wezterm-minimal.lua`.

For a Claude-Code-multi-pane workflow, use `assets/wezterm-claude.lua` and the helper at `scripts/bsp-split.sh`.

## Popular community templates (`examples/`)

If the user wants to start from a battle-tested community config instead of the skill's defaults, point them at `examples/`. Each subfolder ships a README, `install.ps1`, and `install.sh` that back up the user's existing config before pulling from upstream. All five were validated against WezTerm `20240203-110809-5046fc22`.

| # | Preset | ⭐ | License | Best for |
|---|--------|------|---------|----------|
| [01](examples/01-kevinsilvester/) | KevinSilvester/wezterm-config | 1072 | MIT | full-featured modular (backdrops, GPU selector) |
| [02](examples/02-qiansong1/) | QianSong1/wezterm-config | 258 | MIT | lighter modular fork of #1 |
| [03](examples/03-catppuccin/) | catppuccin/wezterm | 358 | MIT | theme-first single-file with OS dark/light sync |
| [04](examples/04-sravioli/) | sravioli/wezterm | 155 | GPL-2.0 | OOP-style modular with responsive status bar |
| [05](examples/05-dragonlobster/) | dragonlobster/wezterm-config | 68 | unspecified | single-file tmux-style starter |

See `examples/README.md` for the comparison table, validation recipe (wrapper trick to test multi-file configs without installing them), and license notes (#04 GPL-2.0 viral, #05 no license — install only, no redistribution).

## CLI patterns (most useful)

```bash
# Inspect state
wezterm cli list --format json
wezterm cli list-clients

# Spawn / split panes (preserves PATH because it goes through your shell)
PANE_ID=$(wezterm cli split-pane --right)
printf 'claude\n' | wezterm cli send-text --pane-id "$PANE_ID"

# Do NOT do this — bypasses shell, loses PATH:
# wezterm cli split-pane -- claude    (DON'T)

# Activate, kill, zoom
wezterm cli activate-pane --pane-id "$PANE_ID"
wezterm cli zoom-pane --pane-id "$PANE_ID"
wezterm cli kill-pane --pane-id "$PANE_ID"

# Show current keybindings as Lua
wezterm show-keys --lua

# List installed fonts
wezterm ls-fonts --list-system
```

See `references/cli.md` for the full subcommand list.

## SSH setup

For a one-off connection use `wezterm ssh user@host`. For a daily-driver host, declare an `ssh_domain` so panes/tabs survive disconnects. The skill ships `scripts/add-ssh-host.sh` which:

1. Generates a per-host Ed25519 keypair (idempotent)
2. Appends a `Host` block to `~/.ssh/config`
3. Optionally runs `ssh-copy-id`
4. Optionally prints a paste-ready `ssh_domains` snippet for `wezterm.lua`

```bash
./scripts/add-ssh-host.sh --alias prod --hostname 10.0.0.42 \
                          --user deploy --copy-id --wezterm-domain
```

Full SSH guide (key fields, `wezterm ssh` vs `ssh_domains`, troubleshooting): `references/ssh.md`.

## Common tasks

### Change theme
Edit `config.color_scheme = 'Catppuccin Mocha'`. See `references/color-schemes.md` for the curated list of popular names.

### Set up copy-paste explicitly
WezTerm already has sane defaults (`Ctrl+Shift+C` / `Ctrl+Shift+V` on Linux/Windows, `Cmd+C` / `Cmd+V` on macOS). To customize:

```lua
config.keys = {
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
}
```

### Add a leader key (tmux-style)
```lua
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
}
```

### Split a pane

With the default skill config (`LEADER = Ctrl+a`):

- `Ctrl+a \` — split right (side-by-side)
- `Ctrl+a -` — split below (stacked)
- `Ctrl+a h/j/k/l` — move focus, `z` zoom, `x` close, `r` resize mode

From a script (preserves PATH):

```bash
PANE=$(wezterm cli split-pane --right --percent 40)
printf 'tail -f app.log\n' | wezterm cli send-text --pane-id "$PANE"
```

Never `wezterm cli split-pane -- <cmd>` — that bypasses the shell. Full guide and layout recipes: `references/pane-splitting.md`.

### Switch to a modular config

Once `wezterm.lua` passes ~150 lines, split it. Each module exports `M.apply(config)` and the entry file is a manifest:

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config  = wezterm.config_builder()
package.path = package.path .. ';' .. wezterm.config_dir .. '/lua/?.lua'

require('appearance').apply(config)
require('keys'      ).apply(config)
require('events'    ).apply(config)

return config
```

Full pattern (helpers/theme/keys/workspaces/events/plugins) and migration steps: `references/modular-config.md`.

### Add a plugin

```lua
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'
resurrect.apply_to_config(config)
```

Pin with `/tree/v1.0.0` suffix. Update via `wezterm.plugin.update_all()` or `wezterm cli plugin update`. Curated list and security notes: `references/plugins.md`.

### Enable IDE autocomplete

Install `lua-language-server`, clone `DrKJeff16/wezterm-types`, drop a `.luarc.json` next to your config:

```json
{
  "workspace": { "library": ["~/wezterm-types"] },
  "diagnostics": { "globals": ["wezterm"] }
}
```

Now `config.colo<Tab>` autocompletes, hover shows docs, action payloads are type-checked. Full setup: `references/types.md`.

### Workspaces

Named tab/pane collections per project. Switch via launcher, persist via unix multiplexer:

```lua
-- LEADER w opens fuzzy workspace launcher; existing names complete, new names create
{ key = 'w', mods = 'LEADER',
  action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } }

-- Persist sessions across GUI restarts
config.unix_domains = { { name = 'main' } }
config.default_gui_startup_args = { 'connect', 'main' }
```

Full workspace API, auto-bootstrap on launch, status bar display: `references/workspaces.md`.

### Shell integration (CWD inheritance on split)

By default a new pane starts in `default_cwd`, not the parent pane's directory. To make splits inherit CWD, the shell must emit OSC 7. Sourcing WezTerm's bundled scripts is the fast path:

```bash
# bash / zsh — Linux
[[ -n "$WEZTERM_PANE" ]] && source /usr/share/wezterm/wezterm.sh

# bash — Windows (Git Bash)
[[ -n "$WEZTERM_PANE" ]] && source "/c/Program Files/WezTerm/wezterm.sh"
```

PowerShell has no bundled script; use the manual emitter in `references/shell-integration.md` (works with Starship etc.).

Verify with `wezterm cli list --format json | jq '.[].cwd'` — should show real paths, not just `file:///home/<user>`.

### Hide tab bar when only one tab
```lua
config.hide_tab_bar_if_only_one_tab = true
```

### Transparent window
```lua
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20  -- macOS only
```

## Driving a pane from an AI agent

WezTerm exposes `send-text` (type input into a pane) and `get-text` (read pane output) over its CLI. This makes it possible for an AI coding agent to operate the terminal itself.

The canonical loop:

1. **Send** with `wezterm cli send-text 'cmd'` (no trailing newline — user reviews before pressing Enter)
2. **Wait** for the user to press Enter
3. **Read** with `wezterm cli get-text --start-line -30`

Defaults an agent should follow:
- Operate the **focused pane** by default (omit `--pane-id`); use `--pane-id N` only when the user says "send to pane N" or "use the build terminal"
- **Type, do not execute** — append `\n` only when the user explicitly says "just run it"
- Always follow `send-text` with `get-text --start-line -N` to confirm the result
- Discover layout with `wezterm cli list --format json | jq '.[] | {pane_id, title, cwd}'`

Full pattern, examples, and limits: `references/agent-driving.md`.

## References (load on demand)

- `references/cli.md` — full `wezterm cli` subcommand reference
- `references/keybindings.md` — default keybindings + custom binding patterns
- `references/pane-splitting.md` — keyboard, defaults, CLI, and layout recipes for splitting panes
- `references/config-options.md` — config option catalog by category
- `references/color-schemes.md` — popular built-in themes with exact names
- `references/agent-driving.md` — driving a WezTerm pane from an AI agent (send-text / get-text loop)
- `references/ssh.md` — `wezterm ssh` vs persistent `ssh_domains`, OpenSSH config interop, troubleshooting
- `references/shell-integration.md` — OSC 7 setup so split panes inherit CWD (bash/zsh/fish + PowerShell)
- `references/modular-config.md` — split wezterm.lua into helpers/theme/keys/events modules with `M.apply(config)` pattern
- `references/types.md` — `lua-language-server` + community type stubs for IDE autocomplete and inline docs
- `references/plugins.md` — `wezterm.plugin.require` mechanism + curated plugin list (resurrect, smart-splits, bar.wezterm, ...)
- `references/workspaces.md` — named workspaces, switching, persistence via unix mux + resurrect, status bar display
- `references/status-bar.md` — left/right status, OS title bar, and tab title — when to use which surface, with pwd+git recipe

## Anti-patterns

- Never use `wezterm cli split-pane -- <command>` — it bypasses the shell and loses PATH/aliases. Use `split-pane` to create the pane, then pipe with `send-text`.
- Do not put `wezterm.config_builder()` and a bare config table in the same file — pick one (the builder is preferred).
- Avoid `wezterm.on('format-tab-title', ...)` overrides until the basic config works; tab-title formatters silently fail and are hard to debug.
- Do not run `wezterm cli` from a shell that is not a WezTerm pane — set `WEZTERM_UNIX_SOCKET` or use `--mux-server-unix-domain-socket-path` if you must.
