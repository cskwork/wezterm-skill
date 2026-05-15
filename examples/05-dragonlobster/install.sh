#!/usr/bin/env bash
# Install dragonlobster/wezterm-config to ~/.wezterm.lua
# License: NOT SPECIFIED upstream. Script downloads directly from upstream raw URL
# rather than redistributing — caller's machine, caller's responsibility.
set -euo pipefail

URL='https://raw.githubusercontent.com/dragonlobster/wezterm-config/main/wezterm.lua'
DEST="${HOME}/.wezterm.lua"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ -e "$DEST" ]]; then
    echo "Backing up $DEST -> ${DEST}.bak-${STAMP}"
    mv "$DEST" "${DEST}.bak-${STAMP}"
fi

echo "Downloading $URL -> $DEST"
if command -v curl >/dev/null; then
    curl -fsSL "$URL" -o "$DEST"
elif command -v wget >/dev/null; then
    wget -q "$URL" -O "$DEST"
else
    echo "Need curl or wget in PATH" >&2
    [[ -e "${DEST}.bak-${STAMP}" ]] && mv "${DEST}.bak-${STAMP}" "$DEST"
    exit 1
fi

cat <<EOF

Installed dragonlobster/wezterm-config (no license, 68 stars).
Required font: Maple Mono NF or JetBrains Mono NL (fallback works without).
Leader key: Alt+q (2s timeout) — see README.md for full keybindings.
Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
EOF
