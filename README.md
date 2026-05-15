# wezterm-skill

A Claude Code skill for configuring and driving the [WezTerm](https://wezterm.org) terminal emulator.

Install once, then ask Claude things like:

- "set up wezterm with Catppuccin Mocha and tmux-style splits"
- "add a leader-key binding that opens a Claude Code pane below"
- "what does `wezterm cli send-text` do and how do I preserve PATH?"
- "switch my color scheme to Tokyo Night Storm and bump font size to 13"

The skill knows the WezTerm CLI surface, the most useful config options, default keybindings, popular color schemes, and includes a ready-to-paste `wezterm.lua` you can drop into your config directory.

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

- Catppuccin Mocha theme, JetBrains Mono 12pt, slight transparency
- `Ctrl+a` as leader (tmux-style)
- Vim-style pane navigation (`LEADER h/j/k/l`), splits (`LEADER \` / `LEADER -`), zoom (`LEADER z`)
- Explicit copy/paste (`Ctrl+Shift+C` / `Ctrl+Shift+V`) plus `Ctrl+Insert` / `Shift+Insert`
- Tab bar hidden when there is only one tab
- Sensible defaults for scrollback, cursor, and window padding

## Multi-pane Claude Code workflow

The `assets/wezterm-claude.lua` config plus `scripts/bsp-split.sh` give you a tmux-free way to run several Claude Code sessions side by side.

```bash
install -m 755 scripts/bsp-split.sh /tmp/bsp-split.sh
```

Then `LEADER s` (Ctrl+a, s) splits the current pane along its shorter axis and starts `claude` in the new pane. PATH and aliases are preserved because the command goes through your shell rather than the `wezterm cli split-pane -- claude` shortcut (which bypasses the shell — do not use it).

## License

MIT. See [LICENSE](LICENSE).
