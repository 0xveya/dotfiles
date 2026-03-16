#!/usr/bin/env bash
set -euo pipefail

# Requires: grim, slurp, wl-copy, wayfreeze
TMP_PNG="$(mktemp --suffix=.png)"
cleanup() { killall wayfreeze 2>/dev/null || true; rm -f "$TMP_PNG"; }
trap cleanup EXIT

# Freeze the screen first
wayfreeze --hide-cursor &
FREEZE_PID=$!
sleep 0.1  # wait for freeze to activate

# Now select and capture
GEOM="$(slurp)" || {
  echo "Selection canceled." >&2
  kill $FREEZE_PID 2>/dev/null || true
  exit 1
}

grim -g "$GEOM" "$TMP_PNG"
kill $FREEZE_PID

[[ -s "$TMP_PNG" ]] && wl-copy --type image/png <"$TMP_PNG"
