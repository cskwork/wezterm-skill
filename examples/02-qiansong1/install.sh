#!/usr/bin/env bash
# Install QianSong1/wezterm-config to ~/.config/wezterm
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

REPO='https://github.com/QianSong1/wezterm-config.git'
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

# QianSong1 README pins JetBrainsMono NF v3.2.1
if (( NO_FONTS == 0 )); then
    if [[ -f "$FONT_INSTALLER" ]]; then
        echo ""
        echo "Installing JetBrainsMono Nerd Font v3.2.1 (per-user, no sudo)..."
        bash "$FONT_INSTALLER" JetBrainsMono v3.2.1
    else
        echo "Font installer not found — install JetBrainsMono NF v3.2.1 manually" >&2
    fi
fi

cat <<EOF

Installed QianSong1/wezterm-config (MIT, 258 stars).
Reload WezTerm with Ctrl+Shift+R (or Cmd+R on macOS) or restart the app.
To revert: remove $DEST and rename the most recent .bak-* folder back.
EOF
