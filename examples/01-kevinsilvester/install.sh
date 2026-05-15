#!/usr/bin/env bash
# Install KevinSilvester/wezterm-config to ~/.config/wezterm
# License: MIT — preserves upstream LICENSE
set -euo pipefail

REPO='https://github.com/KevinSilvester/wezterm-config.git'
DEST="${HOME}/.config/wezterm"
STAMP="$(date +%Y%m%d-%H%M%S)"

command -v git >/dev/null || { echo "git not found in PATH"; exit 1; }

LEGACY="${HOME}/.wezterm.lua"
if [[ -e "$LEGACY" ]]; then
    echo "Backing up $LEGACY -> ${LEGACY}.bak-${STAMP}"
    mv "$LEGACY" "${LEGACY}.bak-${STAMP}"
fi
if [[ -e "$DEST" ]]; then
    echo "Backing up $DEST -> ${DEST}.bak-${STAMP}"
    mv "$DEST" "${DEST}.bak-${STAMP}"
fi

mkdir -p "$(dirname "$DEST")"
echo "Cloning $REPO -> $DEST"
git clone --depth 1 "$REPO" "$DEST"

cat <<EOF

Installed KevinSilvester/wezterm-config (MIT, 1072 stars).
Required font: JetBrainsMono Nerd Font  (https://www.nerdfonts.com)
Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
To revert: remove $DEST and rename the most recent .bak-* folder back.
EOF
