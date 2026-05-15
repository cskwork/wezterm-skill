# Driving WezTerm From an AI Agent

Use this pattern when an AI coding agent (Claude Code, etc.) needs to *operate* a terminal session — type commands, watch output, react. WezTerm's CLI exposes exactly the two primitives this needs: write input into a pane, and read text back out.

## The three-step loop

1. **Send** input with `wezterm cli send-text` (no trailing newline by default)
2. **Wait** for the human to review and press Enter (safety boundary)
3. **Read** the output with `wezterm cli get-text`

```bash
wezterm cli send-text 'ls -la'
# user inspects the typed command, presses Enter
wezterm cli get-text --start-line -30
```

Why no automatic newline? `send-text` *types* the text into the pane the same way the keyboard would, so the user gets to review before execution. If you genuinely want fire-and-forget, append `\n`:

```bash
printf 'ls -la\n' | wezterm cli send-text
```

## Read commands

| Command | Reads |
|---|---|
| `wezterm cli get-text` | Currently visible screen |
| `wezterm cli get-text --start-line -30` | Last 30 lines (negative = from bottom of scrollback) |
| `wezterm cli get-text --start-line 0 --end-line 100` | Absolute range |
| `wezterm cli get-text --pane-id 7` | A specific pane |

## Send commands

| Command | Sends |
|---|---|
| `wezterm cli send-text 'cmd'` | Types into the focused pane, no Enter |
| `printf 'cmd\n' \| wezterm cli send-text` | Types and submits |
| `wezterm cli send-text --pane-id 7 'cmd'` | Targets a specific pane |
| `wezterm cli send-text 'cd /tmp; ls'` | Multiple commands joined with `;` |

## Discovering panes

```bash
wezterm cli list --format json
```

Returns one entry per pane with `pane_id`, `tab_id`, `window_id`, `workspace`, `size`, `cwd`, `title`. Filter with `jq`:

```bash
wezterm cli list --format json | jq '.[] | {pane_id, title, cwd}'
```

The current pane's id is always in `$WEZTERM_PANE`.

## Default behavior an agent should follow

- **Default: operate the current pane** (omit `--pane-id`). Users expect commands to land where they look.
- **Use `--pane-id` only when asked** ("send this to pane 3", "use the build terminal", etc.).
- **Type, do not execute**, unless the user explicitly asks ("just run it", "no prompt", `\n` appended).
- **Read scrollback after every interactive command** — agents can lose track of state because they only see what they read. After a `cd`, run `wezterm cli get-text --start-line -5` to confirm the new CWD.
- **Never use `wezterm cli split-pane -- <cmd>`** — bypasses the shell, loses PATH. Split first, then send-text.

## Suggested SKILL.md addendum

If you build a skill that drives the terminal, include something like:

```
## When driving a WezTerm pane

DEFAULT: omit --pane-id (use focused pane)
TARGET PANE: use --pane-id N when user says "use terminal X" or "send to pane Y"
SUBMIT: omit \n so user reviews; append \n only when user says "just run it"
READ AFTER WRITE: always follow send-text with get-text --start-line -N to confirm outcome
LIST: `wezterm cli list --format json | jq ...` to discover panes
```

## End-to-end example

```bash
# Discover layout
wezterm cli list --format json | jq '.[] | {pane_id, title}'

# Type a build command into the current pane (user presses Enter)
wezterm cli send-text 'cargo test --workspace'

# After the user runs it, read the tail to see results
sleep 2
wezterm cli get-text --start-line -50 | tail -20

# Spawn a dedicated "logs" pane and tail a file in it
LOGS=$(wezterm cli split-pane --right --percent 35)
printf 'tail -f /var/log/app.log\n' | wezterm cli send-text --pane-id "$LOGS"

# Later, read what the logs pane has captured
wezterm cli get-text --pane-id "$LOGS" --start-line -100
```

## Limits and caveats

- `get-text` returns plain text; ANSI styling is stripped. Color-based output (e.g. `git diff`) loses semantic meaning unless you pass `--escapes` (and even then you must parse SGR yourself).
- TUIs (vim, htop, k9s) repaint the same cells; `get-text` shows the *rendered* state, not a history. Use it to read snapshots, not transcripts.
- `send-text` is keyboard input — control keys go through escape sequences (`$'\x03'` for Ctrl-C, `$'\e'` for Esc).
- On Windows, prefer `pwsh.exe` semicolons or `&&` chains in PowerShell 7+. Bash idioms (`;` always sequential, `&&` short-circuit) work everywhere in WezTerm's mux because text is delivered before any shell parses it.

## Source

Pattern documented in: <https://medium.com/@michaelheca/the-best-terminal-for-ai-502651a00485> ("The best terminal for AI", 2024).
