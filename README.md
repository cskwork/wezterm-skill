# wezterm-skill

A Claude Code skill for configuring and driving the [WezTerm](https://wezterm.org) terminal emulator. Bash + PowerShell helpers and an opinionated default config ship in the box.

Install once, then ask Claude things like:

- "set up wezterm with Catppuccin Mocha and tmux-style splits"
- "split my wezterm.lua into modules and add a workspace switcher binding"
- "scaffold a new SSH host called `prod` and add it as an ssh_domain"
- "drive the pane on the right with `wezterm cli send-text` to run my tests"
- "switch my color scheme to Tokyo Night Storm and bump font size to 13"
- "install `resurrect.wezterm` and wire up auto-save every 5 minutes"
- "fix CWD inheritance — new panes start in `~` instead of my project"

## What it covers

- Default `wezterm.lua` (Catppuccin Mocha, tmux-style leader, copy/paste, pane splits) plus minimal and Claude-Code-multi-pane variants
- WezTerm CLI surface: `list`, `spawn`, `split-pane`, `send-text`, `get-text`, `connect`, `ssh`
- Default + custom keybindings, leader-key patterns, key_tables (resize/copy mode)
- Pane splitting recipes, BSP layout helper
- Driving a pane from an AI agent (`send-text` / `get-text` loop)
- SSH: `wezterm ssh` vs persistent `ssh_domains`, helper scripts for both bash and PowerShell
- Shell integration (OSC 7) for CWD inheritance on split, bash/zsh/fish/PowerShell
- Modular `wezterm.lua` layout (`M.apply(config)` pattern, `helpers`/`theme`/`keys`/`events`)
- IDE type completion via `lua-language-server` + community type stubs
- Plugin system (`wezterm.plugin.require`) + curated community plugin list
- Named workspaces, switching, persistence via unix multiplexer or `resurrect.wezterm`
- Polish: inactive-pane dimming, `WebGpu` front-end, Zen mode toggle, OS-aware config

## What's inside

```
wezterm-skill/
  SKILL.md                       — entry point Claude loads
  assets/
    wezterm.lua                  — opinionated default config (copy this in)
    wezterm-minimal.lua          — minimum viable starter
    wezterm-claude.lua           — multi-pane Claude Code workflow
  references/
    cli.md                       — wezterm CLI subcommand reference
    keybindings.md               — default + custom binding patterns
    pane-splitting.md            — split panes by keyboard, defaults, CLI, layout recipes
    config-options.md            — config option catalog
    color-schemes.md             — popular themes with exact names
    agent-driving.md             — drive a pane from an AI agent (send-text / get-text)
    ssh.md                       — `wezterm ssh` and persistent ssh_domains
    shell-integration.md         — OSC 7 setup for CWD inheritance on split
    modular-config.md            — split wezterm.lua into helpers/theme/keys modules
    types.md                     — lua-language-server + wezterm-types for IDE autocomplete
    plugins.md                   — wezterm.plugin.require + curated community plugin list
    workspaces.md                — named workspaces, switching, persistence, status bar
  scripts/
    bsp-split.sh                 — binary-space-partition pane split helper
    add-ssh-host.sh              — scaffold a new SSH host (bash, key + ~/.ssh/config + ssh_domains)
    Split-Bsp.ps1                — PowerShell port of bsp-split.sh (Windows-native)
    Add-SshHost.ps1              — PowerShell port of add-ssh-host.sh (Windows-native)
```

## Install

Copy the `wezterm-skill/` folder into your Claude Code skills directory:

```bash
# Linux / macOS
mkdir -p ~/.claude/skills
cp -r wezterm-skill ~/.claude/skills/wezterm

# Windows (PowerShell)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
Copy-Item -Recurse wezterm-skill "$env:USERPROFILE\.claude\skills\wezterm"
```

Restart Claude Code (or `/skill-health`) and the `wezterm` skill should be listed.

## Use the default config

Drop the bundled config into your WezTerm config location:

```bash
# Linux / macOS
cp ~/.claude/skills/wezterm/assets/wezterm.lua ~/.wezterm.lua

# Windows (PowerShell)
Copy-Item "$env:USERPROFILE\.claude\skills\wezterm\assets\wezterm.lua" `
          "$env:USERPROFILE\.wezterm.lua"
```

WezTerm watches the file and reloads automatically. If something breaks, open the debug overlay with `Ctrl+Shift+L` to see the Lua error.

The default config sets:

- Catppuccin Mocha theme, JetBrains Mono 14pt, slight transparency
- `Ctrl+a` as leader (tmux-style)
- Vim-style pane navigation (`LEADER h/j/k/l`), splits (`LEADER \` / `LEADER -`), zoom (`LEADER z`)
- Explicit copy/paste (`Ctrl+Shift+C` / `Ctrl+Shift+V`) plus `Ctrl+Insert` / `Shift+Insert`
- Tab bar hidden when there is only one tab
- Sensible defaults for scrollback, cursor, and window padding
- **pwd + git branch in the OS title bar** (the row above the tabs) — updates ~1Hz, git is cached per pwd with a 5s TTL. See `references/status-bar.md` for the full pattern. Standalone module: `assets/git-pwd-status.lua`.

### macOS: putting `wezterm` on PATH

The Homebrew cask installs WezTerm to `/Applications/WezTerm.app` but does NOT symlink the CLI into PATH. Without the symlinks, `wezterm cli send-text`, `wezterm cli list`, etc. fail to launch. WezTerm is a multi-call binary — `wezterm` shells out to sibling binaries `wezterm-gui` and `wezterm-mux-server`, so all three need to be on PATH together:

```bash
ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm            ~/.local/bin/wezterm
ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm-gui        ~/.local/bin/wezterm-gui
ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm-mux-server ~/.local/bin/wezterm-mux-server
hash -r   # reset zsh's command-location cache in this session
```

Substitute `~/.local/bin` with whichever directory in your PATH is user-writable (`/opt/homebrew/bin` works too if you want it next to other Homebrew tools).

## Multi-pane Claude Code workflow

The `assets/wezterm-claude.lua` config plus the BSP split helper give you a tmux-free way to run several Claude Code sessions side by side.

```bash
# Linux / macOS / Git Bash
install -m 755 scripts/bsp-split.sh /tmp/bsp-split.sh

# Windows-native (no Git Bash needed)
Copy-Item scripts\Split-Bsp.ps1 "$env:USERPROFILE\bin\Split-Bsp.ps1"
```

Then `LEADER s` (Ctrl+a, s) splits the current pane along its shorter axis and starts `claude` in the new pane. PATH and aliases are preserved because the command goes through your shell rather than `wezterm cli split-pane -- claude` (which bypasses the shell — do not use it).

## SSH helpers

Scaffold a new SSH host (keypair, `~/.ssh/config` block, optional `ssh-copy-id`, optional WezTerm `ssh_domains` snippet):

```bash
# Linux / macOS / Git Bash
./scripts/add-ssh-host.sh --alias prod --hostname 10.0.0.42 --user deploy \
                          --copy-id --wezterm-domain

# Windows-native PowerShell
./scripts/Add-SshHost.ps1 -Alias prod -HostAddress 10.0.0.42 -User deploy `
                          -CopyId -WezTermDomain
```

Both scripts are idempotent — re-running with the same alias is a no-op unless `--force` / `-Force` is passed.

## License

MIT. See [LICENSE](LICENSE).
