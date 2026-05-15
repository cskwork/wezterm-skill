#!/usr/bin/env bash
# Install sravioli/wezterm to ~/.config/wezterm
# License: GPL-2.0 — preserves upstream LICENSE and LICENSE-DOCS files
set -euo pipefail

REPO='https://github.com/sravioli/wezterm.git'
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

Installed sravioli/wezterm (GPL-2.0, 155 stars).
Required fonts: Fira Code Nerd Font, Monaspace Radon, Monaspace Krypton.
Requires WezTerm nightly for full feature support.

GPL-2.0 NOTICE: Do not delete LICENSE or LICENSE-DOCS files.
Derivative works distributed publicly must also be GPL-2.0.

Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
To revert: remove $DEST and rename the most recent .bak-* folder back.
EOF
