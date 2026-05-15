#!/usr/bin/env bash
# Per-user Nerd Font installer for Linux / macOS / Git Bash on Windows.
# Downloads a font archive from ryanoasis/nerd-fonts releases and installs
# all .ttf / .otf files into the per-user font directory.
#
# Usage:
#   ./install-nerd-font.sh                              # JetBrainsMono, latest
#   ./install-nerd-font.sh FiraCode                     # FiraCode, latest
#   ./install-nerd-font.sh JetBrainsMono v3.2.1         # specific version
#
# Common font names: JetBrainsMono, FiraCode, Hack, Meslo, CascadiaCode,
# SourceCodePro, IBMPlexMono, Iosevka.
set -euo pipefail

FONT_NAME="${1:-JetBrainsMono}"
VERSION="${2:-latest}"

if [[ "$VERSION" == "latest" ]]; then
    URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
else
    URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${FONT_NAME}.zip"
fi

# Resolve per-user font directory by OS
case "$(uname -s)" in
    Darwin)
        FONT_DIR="${HOME}/Library/Fonts"
        ;;
    Linux)
        FONT_DIR="${HOME}/.local/share/fonts"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Git Bash on Windows — install to per-user font dir
        if [[ -n "${LOCALAPPDATA:-}" ]]; then
            FONT_DIR="${LOCALAPPDATA}/Microsoft/Windows/Fonts"
        else
            FONT_DIR="${HOME}/AppData/Local/Microsoft/Windows/Fonts"
        fi
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac

command -v unzip >/dev/null || { echo "unzip not found in PATH" >&2; exit 1; }
if command -v curl >/dev/null; then
    FETCH=(curl -fsSL -o)
elif command -v wget >/dev/null; then
    FETCH=(wget -q -O)
else
    echo "Need curl or wget in PATH" >&2
    exit 1
fi

mkdir -p "$FONT_DIR"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading $URL"
"${FETCH[@]}" "$TMP/font.zip" "$URL"

echo "Extracting"
unzip -q -o "$TMP/font.zip" -d "$TMP"

installed=0
skipped=0
shopt -s nullglob nocaseglob
for ttf in "$TMP"/*.ttf "$TMP"/*.otf "$TMP"/**/*.ttf "$TMP"/**/*.otf; do
    [[ -f "$ttf" ]] || continue
    name="$(basename "$ttf")"
    if [[ -e "$FONT_DIR/$name" ]]; then
        skipped=$((skipped + 1))
    else
        cp "$ttf" "$FONT_DIR/"
        installed=$((installed + 1))
    fi
done
shopt -u nullglob nocaseglob

# Refresh font cache where applicable (Linux fontconfig)
if command -v fc-cache >/dev/null; then
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
fi

# Windows: also register each font in HKCU so apps without font_dirs config see them.
# Skipped silently if reg.exe is unavailable (non-Windows shells).
registered=0
if command -v reg.exe >/dev/null; then
    rkey='HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    win_font_dir="$(cygpath -w "$FONT_DIR" 2>/dev/null || echo "$FONT_DIR")"
    shopt -s nullglob nocaseglob
    for ttf in "$FONT_DIR"/*.ttf "$FONT_DIR"/*.otf; do
        [[ -f "$ttf" ]] || continue
        base="$(basename "$ttf")"
        stem="${base%.*}"
        # Use just the filename — Windows resolves it relative to per-user font dir
        if reg.exe add "$rkey" /v "$stem (TrueType)" /t REG_SZ /d "$base" /f >/dev/null 2>&1; then
            registered=$((registered + 1))
        fi
    done
    shopt -u nullglob nocaseglob
fi

echo ""
echo "Installed $installed font file(s); skipped $skipped already-present file(s)."
echo "Location: $FONT_DIR (per-user — no admin/sudo required)"
if (( registered > 0 )); then
    echo "Registered $registered font(s) in HKCU font registry."
fi
if (( installed > 0 )); then
    echo "Restart WezTerm (or reload with Ctrl+Shift+R) to pick up new fonts."
fi
