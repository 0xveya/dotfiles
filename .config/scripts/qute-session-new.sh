#!/usr/bin/env bash
set -euo pipefail

name="$(printf '' | tv --prompt "New session > " || true)"
[ -z "$name" ] && exit 0

printf 'session-save %s\n' "$name" >> "$QUTE_FIFO"
printf 'message-info "Saved session: %s"\n' "$name" >> "$QUTE_FIFO"
