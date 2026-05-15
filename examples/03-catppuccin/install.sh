#!/usr/bin/env bash
# Install catppuccin/wezterm starter to ~/.wezterm.lua
# License: MIT (catppuccin/wezterm)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SCRIPT_DIR}/wezterm.lua"
DEST="${HOME}/.wezterm.lua"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ -e "$DEST" ]]; then
    echo "Backing up $DEST -> ${DEST}.bak-${STAMP}"
    mv "$DEST" "${DEST}.bak-${STAMP}"
fi

echo "Installing $SOURCE -> $DEST"
cp "$SOURCE" "$DEST"

cat <<EOF

Installed catppuccin/wezterm starter (MIT, 358 stars).
Theme is built into WezTerm 20220903+ — no plugin install needed.
Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
To switch flavor, edit scheme_for_appearance() in $DEST.
EOF
