#!/usr/bin/env bash
set -euo pipefail

pane_path="$(tmux display-message -p "#{pane_current_path}")"
cd "$pane_path"

url="$(git remote get-url origin 2>/dev/null || true)"

if [[ -z "$url" ]]; then
    echo "No origin remote found for $pane_path." >&2
    exit 1
fi

if [[ "$url" == git@* ]]; then
    url="${url#git@}"
    url="${url/:/\/}"
    url="https://$url"
elif [[ "$url" == ssh://git@* ]]; then
    url="${url#ssh://git@}"
    url="${url/:/\/}"
    url="https://$url"
fi

url="${url%.git}"

if [[ "$url" == *github.com* ]] || [[ "$url" == *codeberg.org* ]]; then
    xdg-open "$url" >/dev/null 2>&1 &
else
    echo "This repository is not hosted on GitHub or Codeberg: $url" >&2
    exit 1
fi
