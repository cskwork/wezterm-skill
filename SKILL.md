---
name: wezterm
description: Configure, customize, and operate the WezTerm terminal emulator. Use when the user wants to set up a WezTerm config (fonts, themes, keybindings, copy-paste, panes, tabs), troubleshoot config errors, drive WezTerm via its CLI (split-pane, send-text, spawn, list), or wire up multi-pane workflows (Claude Code, tmux-style sessions, SSH/multiplexing domains). Use for WezTerm-specific requests; a generic terminal color or shell question need not activate it.
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

# Direct process launch is also available; supply the executable/environment explicitly
# when it depends on interactive shell setup.

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

Use the matching reference below for themes, keybindings, pane layouts, modular configs, plugins, workspaces, shell integration, or IDE types. Read only the relevant guide; examples are starting points and must match the installed WezTerm API and existing configuration.

## Driving a pane from an AI agent

WezTerm exposes `send-text` (type input into a pane) and `get-text` (read pane output) over its CLI. This makes it possible for an AI coding agent to operate the terminal itself.

Inspect the pane list and current foreground state first, then target the intended pane explicitly. A request to type a command should leave it unsubmitted; a request to run a command authorizes execution within its scope without another routine Enter gate. Do not inject text into an unrelated interactive program or infer success from text merely appearing in scrollback. Verify the command's observed completion/output.

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

- Direct `split-pane -- <command>` execution does not apply interactive shell setup. Use an explicit executable/environment, or a shell when the command depends on shell PATH/aliases.
- Do not put `wezterm.config_builder()` and a bare config table in the same file — pick one (the builder is preferred).
- Avoid `wezterm.on('format-tab-title', ...)` overrides until the basic config works; tab-title formatters silently fail and are hard to debug.
- Do not run `wezterm cli` from a shell that is not a WezTerm pane — set `WEZTERM_UNIX_SOCKET` or use `--mux-server-unix-domain-socket-path` if you must.
