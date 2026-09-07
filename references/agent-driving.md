# Driving WezTerm From an AI Agent

Use this pattern when an AI coding agent (Claude Code, etc.) needs to *operate* a terminal session — type commands, watch output, react. WezTerm's CLI exposes exactly the two primitives this needs: write input into a pane, and read text back out.

## The execution loop

Inspect the pane list and foreground application, select the intended pane, send the requested input, then read its result. If the request is to type or stage a command, omit Enter. If the user requested execution, submit it within the authorized scope; do not require the exact phrase "just run it" or a second routine confirmation. Verify completion rather than treating echoed input as command output.

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

- Select the intended pane from current state; use `--pane-id` to avoid focus races.
- Do not type into an unrelated running program or overwrite pending user input.
- Distinguish typing from execution based on the actual request, not a magic phrase.
- Read relevant output after execution and verify completion; shell prompt/exit evidence is stronger than echoed text.
- For commands requiring interactive shell setup, invoke the intended shell/environment explicitly rather than assuming direct process launch inherits aliases.

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
