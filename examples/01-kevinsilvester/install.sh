#!/usr/bin/env bash
# Install KevinSilvester/wezterm-config to ~/.config/wezterm
# License: MIT — preserves upstream LICENSE
# Usage: ./install.sh [--no-fonts]
set -euo pipefail

NO_FONTS=0
for arg in "$@"; do
    case "$arg" in
        --no-fonts) NO_FONTS=1 ;;
        *) echo "Unknown arg: $arg" >&2; exit 2 ;;
    esac
done

REPO='https://github.com/KevinSilvester/wezterm-config.git'
DEST="${HOME}/.config/wezterm"
STAMP="$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_INSTALLER="${SCRIPT_DIR}/../../scripts/install-nerd-font.sh"

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

if (( NO_FONTS == 0 )); then
    if [[ -x "$FONT_INSTALLER" || -f "$FONT_INSTALLER" ]]; then
        echo ""
        echo "Installing JetBrainsMono Nerd Font (per-user, no sudo)..."
        bash "$FONT_INSTALLER" JetBrainsMono
    else
        echo "Font installer not found at $FONT_INSTALLER — install JetBrainsMono Nerd Font manually from https://www.nerdfonts.com" >&2
    fi
fi

cat <<EOF

Installed KevinSilvester/wezterm-config (MIT, 1072 stars).
Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
To revert: remove $DEST and rename the most recent .bak-* folder back.
EOF
