#!/usr/bin/env bash
set -euo pipefail

QUTE_SESS="$HOME/dotfiles/.config/scripts/qute-tv-sessions.py"

choice="$(
  {
    echo "󰆓  new-session"
    echo "󰈔  save-current"
    echo "󰩺  delete-session"
    "$QUTE_SESS" list-sessions | sed 's/^/󰓩  load\t/'
  } | vicinae dmenu || true
)"

[ -z "$choice" ] && exit 0

case "$choice" in
  *"new-session"*)
    name="$(printf '' | vicinae dmenu --placeholder 'New session name' || true)"
    [ -n "$name" ] && printf 'session-save %s\n' "$name" >> "$QUTE_FIFO"
    ;;

  *"save-current"*)
    name="$(printf '' | vicinae dmenu --placeholder 'Save current session as' || true)"
    [ -n "$name" ] && printf 'session-save %s\n' "$name" >> "$QUTE_FIFO"
    ;;

  *"delete-session"*)
    session="$("$QUTE_SESS" list-sessions | vicinae dmenu || true)"
    [ -z "$session" ] && exit 0
    name="$(printf '%s\n' "$session" | cut -f1)"
    rm -f "$HOME/.local/share/qutebrowser/sessions/$name.yml"
    ;;

  *$'\t'*)
    # Row shape:
    # icon load<TAB>session<TAB>tabs<TAB>path
    session="$(printf '%s\n' "$choice" | cut -f2)"
    printf 'session-load %s\n' "$session" >> "$QUTE_FIFO"
    ;;
esac
