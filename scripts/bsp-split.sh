#!/usr/bin/env bash
# bsp-split.sh — Binary Space Partitioning split for the current WezTerm pane.
#
# Finds the current pane (via $WEZTERM_PANE), reads its dimensions through
# `wezterm cli list --format json`, and splits along the shorter axis so the
# resulting layout stays balanced.
#
# Prints the new pane id on stdout.
#
# Usage:
#   PANE_ID=$(./bsp-split.sh)
#   printf 'claude\n' | wezterm cli send-text --pane-id "$PANE_ID"
#
# DO NOT use `wezterm cli split-pane -- <cmd>` — that bypasses the shell
# and loses PATH / aliases. Always split first, then send-text.

set -euo pipefail

if [[ -z "${WEZTERM_PANE:-}" ]]; then
  echo "WEZTERM_PANE is not set. Run this inside a WezTerm pane." >&2
  exit 1
fi

if ! command -v wezterm >/dev/null 2>&1; then
  echo "wezterm CLI not found in PATH." >&2
  exit 1
fi

# Pull cols/rows for the active pane.
read -r COLS ROWS <<<"$(
  wezterm cli list --format json \
    | python3 -c "
import json, os, sys
pid = int(os.environ['WEZTERM_PANE'])
for p in json.load(sys.stdin):
    if p['pane_id'] == pid:
        print(p['size']['cols'], p['size']['rows'])
        break
"
)"

if [[ -z "${COLS:-}" || -z "${ROWS:-}" ]]; then
  echo "Could not find pane $WEZTERM_PANE in wezterm cli list output." >&2
  exit 1
fi

# Aspect ratio: > 2.0 means pane is wide -> split right; otherwise split bottom.
RATIO=$(awk -v c="$COLS" -v r="$ROWS" 'BEGIN { printf "%.2f", c / r }')
if awk -v ratio="$RATIO" 'BEGIN { exit !(ratio > 2.0) }'; then
  DIRECTION='--right'
else
  DIRECTION='--bottom'
fi

wezterm cli split-pane --pane-id "$WEZTERM_PANE" "$DIRECTION"
