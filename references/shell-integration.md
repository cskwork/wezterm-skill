# Shell Integration (OSC 7 and Friends)

When you split a pane WezTerm tries to inherit the parent pane's current working directory. It can only do that if your shell *tells* WezTerm where it is, by emitting an **OSC 7** escape sequence after every `cd`. Without OSC 7, every new pane starts in `default_cwd` (typically your home directory) and the `LEADER -` / `LEADER \` split workflow feels broken.

WezTerm also understands OSC 133 (semantic prompts) and OSC 1337 (extended terminal features) which power things like "jump to previous prompt" and `wezterm cli get-text --escapes`. These come "for free" if you source the bundled integration scripts.

## The fast path: source WezTerm's bundled scripts

WezTerm ships ready-made integration files. The location depends on platform:

| Platform | Path |
|---|---|
| Windows | `C:\Program Files\WezTerm\wezterm.sh` (and `wezterm.fish`) |
| macOS   | `/Applications/WezTerm.app/Contents/Resources/wezterm/wezterm.sh` |
| Linux   | `/usr/share/wezterm/shell-integration/wezterm.sh` |

### bash (`~/.bashrc`)

```bash
if [[ -n "$WEZTERM_PANE" && -f "/usr/share/wezterm/wezterm.sh" ]]; then
  source "/usr/share/wezterm/wezterm.sh"
fi
```

On Windows from Git Bash:

```bash
if [[ -n "$WEZTERM_PANE" && -f "/c/Program Files/WezTerm/wezterm.sh" ]]; then
  source "/c/Program Files/WezTerm/wezterm.sh"
fi
```

### zsh (`~/.zshrc`)

```zsh
if [[ -n "$WEZTERM_PANE" ]] && [[ -f "/usr/share/wezterm/wezterm.sh" ]]; then
  source "/usr/share/wezterm/wezterm.sh"
fi
```

### fish (`~/.config/fish/conf.d/wezterm.fish`)

```fish
if set -q WEZTERM_PANE
    set -l wezterm_share /usr/share/wezterm/wezterm.fish
    if test -f $wezterm_share
        source $wezterm_share
    end
end
```

## PowerShell: manual OSC 7

WezTerm does not ship a PowerShell integration file. Add the following to `$PROFILE` (run `notepad $PROFILE` to find/create it):

```powershell
if ($env:WEZTERM_PANE) {
    # Wrap any existing prompt function so we don't clobber Starship etc.
    $prevPrompt = $function:prompt
    function global:prompt {
        # OSC 7: tell the terminal our CWD as a file:// URL.
        $cwd = (Get-Location).ProviderPath -replace '\\','/'
        # Percent-encode spaces and special chars minimally.
        $cwd = [System.Uri]::EscapeUriString($cwd)
        $hostName = [System.Net.Dns]::GetHostName()
        $osc7 = "`e]7;file://${hostName}${cwd}`e\"
        [Console]::Write($osc7)
        & $prevPrompt
    }
}
```

After reloading the shell (`. $PROFILE`), every prompt redraw emits OSC 7. Verify with `wezterm cli list --format json` — the `cwd` field should now match your real PWD.

## cmd.exe

`cmd.exe` cannot emit escape sequences from a prompt hook in any clean way. Use PowerShell, Git Bash, or WSL inside WezTerm if you want CWD inheritance.

## Verifying it works

```bash
# 1. Look at the cwd field for the current pane.
wezterm cli list --format json | jq '.[] | select(.pane_id == env.WEZTERM_PANE | tonumber) | .cwd'

# 2. Split and confirm the new pane started in the same directory.
PANE=$(wezterm cli split-pane --right --percent 30)
sleep 1
wezterm cli list --format json | jq ".[] | select(.pane_id == $PANE) | .cwd"
```

If both show a real `file://...` URL pointing to your project directory, OSC 7 is working. If you see `file:///home/user` instead of the project path, your shell isn't emitting OSC 7 yet.

## What you get with full integration (OSC 133)

If you source the bundled `wezterm.sh` / `wezterm.fish`, WezTerm also learns:

- **Semantic prompt boundaries** — `wezterm cli get-text --escapes` can pull just the last command's output, not the whole scrollback.
- **`ScrollByCurrentEventPage` and friends** — keybindings can jump to the previous/next prompt rather than scrolling by lines.
- **Status hints for long commands** — visual indicators when a command is still running.

These do not currently have a PowerShell equivalent shipped by WezTerm. Manual OSC 133 is possible but verbose; skip it unless you need it.

## Common gotchas

- **Don't quote `WEZTERM_PANE` away.** Some shells expand `$WEZTERM_PANE` to empty if it leaks through `env -i` or a `sudo` invocation without `--preserve-env`. The integration must run in the same shell that has the variable.
- **PROMPT_COMMAND chains** — bash users with `starship`, `liquidprompt`, or `oh-my-posh` may already have a multi-step `PROMPT_COMMAND`. Source `wezterm.sh` *after* setting up the other prompt and it appends safely.
- **Performance** — OSC 7 is two cheap printf calls per prompt. Don't worry.
- **Spaces in paths** — the manual snippets above URL-encode spaces. If you see literal spaces in the `cwd` field, your encoder is wrong.

## Sources

- <https://wezterm.org/shell-integration.html>
- <https://gitlab.freedesktop.org/terminal-wg/specifications/-/merge_requests/3> (OSC 7 spec)
