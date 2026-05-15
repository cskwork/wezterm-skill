# Pane Splitting

Three ways to split a pane, plus the navigation/management bindings that go with them. CLI patterns at the bottom are what agents and scripts should use.

## Direction terminology

WezTerm's `SplitHorizontal` creates a pane to the **right** (side-by-side), and `SplitVertical` creates a pane **below** (stacked). The action name describes the axis being split, not the divider orientation — easy to misread, so the table below restates it in plain words.

| Action | Result |
|---|---|
| `SplitHorizontal { domain = 'CurrentPaneDomain' }` | New pane to the right |
| `SplitVertical   { domain = 'CurrentPaneDomain' }` | New pane below |

CLI uses physical directions, which is clearer:

| Flag | Result |
|---|---|
| `--right` | New pane to the right |
| `--left` | New pane to the left |
| `--bottom` | New pane below |
| `--top` | New pane above |

## 1. Keyboard — tmux-style leader (recommended)

The default skill config sets `LEADER = Ctrl+a`. Press `Ctrl+a`, release, then the next key (1-second timeout).

| Keys | Action |
|---|---|
| `LEADER \` | Split right |
| `LEADER -` | Split below |
| `LEADER h/j/k/l` | Move focus (vim directions) |
| `LEADER z` | Zoom toggle (maximize current pane) |
| `LEADER x` | Close current pane (with confirm) |
| `LEADER r` then `h/j/k/l` | Enter resize mode; `Esc` to exit |

## 2. Keyboard — WezTerm defaults (no leader)

If you have not set up a leader key, the out-of-the-box bindings still work:

| Keys | Action |
|---|---|
| `Ctrl+Shift+Alt+"` | Split vertically (pane below) |
| `Ctrl+Shift+Alt+%` | Split horizontally (pane right) |
| `Ctrl+Shift+Arrow` | Move focus |
| `Ctrl+Shift+Alt+Arrow` | Resize |
| `Ctrl+Shift+Z` | Zoom toggle |

These are ergonomically worse than leader-style — fingers contort for the modifier stack — but they need no config.

## 3. CLI — for scripts and AI agents

```bash
# Split right, default 50/50
PANE_ID=$(wezterm cli split-pane --right)

# Explicit percent
PANE_ID=$(wezterm cli split-pane --right --percent 40)

# Split below
PANE_ID=$(wezterm cli split-pane --bottom --percent 30)

# Target a non-focused pane to split
PANE_ID=$(wezterm cli split-pane --pane-id 3 --bottom --percent 25)

# Capture the new id and send text into it
LOGS=$(wezterm cli split-pane --right --percent 35)
printf 'tail -f /var/log/app.log\n' | wezterm cli send-text --pane-id "$LOGS"
```

### Anti-pattern (do not use)

```bash
# WRONG — bypasses your shell, loses PATH, aliases, and shell init
wezterm cli split-pane --right -- claude
```

The `--` form runs the program directly via the wezterm mux rather than your shell. PATH additions in `~/.bashrc` / `~/.zshrc` / PowerShell profile are skipped, so commands like `claude`, `pnpm`, `nvm`-installed Node, etc. mysteriously become "command not found". Always:

1. `split-pane` to create the empty pane (your default shell runs there).
2. `send-text` to type the command into that shell.

## Useful layout recipes

### Editor + logs (70/30 vertical split)

```bash
EDITOR_PANE=$WEZTERM_PANE
LOGS=$(wezterm cli split-pane --bottom --percent 30)
printf 'tail -f /var/log/app.log\n' | wezterm cli send-text --pane-id "$LOGS"
wezterm cli activate-pane --pane-id "$EDITOR_PANE"
```

### Three-column dashboard (editor / repl / status)

```bash
EDITOR=$WEZTERM_PANE
REPL=$(wezterm cli split-pane --right --percent 66)
STATUS=$(wezterm cli split-pane --pane-id "$REPL" --right --percent 50)

printf 'python\n'        | wezterm cli send-text --pane-id "$REPL"
printf 'htop\n'          | wezterm cli send-text --pane-id "$STATUS"
wezterm cli activate-pane --pane-id "$EDITOR"
```

### BSP split (always split the shorter axis)

`scripts/bsp-split.sh` shipped with this skill picks `--right` when the pane is wide and `--bottom` when tall, keeping each split balanced. Use it when spawning many panes (e.g. several Claude Code sessions):

```bash
PANE=$(./scripts/bsp-split.sh)
printf 'claude\n' | wezterm cli send-text --pane-id "$PANE"
```

## Inspecting layout

```bash
wezterm cli list --format json | jq '.[] | {pane_id, tab_id, size: .size.cols, title}'
```

The current pane's id is always in `$WEZTERM_PANE`, so scripts that need to "go back home" can stash it and call `wezterm cli activate-pane --pane-id "$WEZTERM_PANE"` later.

## Closing panes

| Method | Behavior |
|---|---|
| `LEADER x` | Confirm prompt, then close |
| `Ctrl+Shift+W` (default) | Close current pane (no confirm by default) |
| `wezterm cli kill-pane --pane-id N` | Scriptable close |
| Exit the shell (`exit` / `Ctrl+D`) | Process exit closes the pane |

When the last pane in a tab closes, the tab closes. When the last tab in a window closes, the window closes.

## Tips

- Splits inherit the **current working directory** of the source pane only if your shell emits OSC 7. zsh and fish do this by default; bash needs `PROMPT_COMMAND='printf "\033]7;file://%s%s\033\\" "$HOSTNAME" "$PWD"'` or wezterm's shell integration script.
- After splitting, the new pane is focused. Use `wezterm cli activate-pane --pane-id "$SOURCE"` to return focus where you were.
- `LEADER z` (zoom) is non-destructive — it temporarily maximizes a pane; press again to restore the layout. Useful when one pane needs the whole window briefly.
- To rearrange panes, use `wezterm cli move-pane-to-new-tab --pane-id N` (extract) — there is no in-place "swap" command yet.
