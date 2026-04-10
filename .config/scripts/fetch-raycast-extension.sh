#!/usr/bin/env bash
set -euo pipefail

extension="${1:-}"
target="${2:-$HOME/github/raycast-extensions}"

if [[ -z "$extension" ]]; then
    echo "usage: ${0##*/} <extension-name> [target-dir]" >&2
    echo "example: ${0##*/} sesh" >&2
    exit 2
fi

repo="https://github.com/raycast/extensions.git"
extension_path="extensions/$extension"

if [[ ! -d "$target/.git" ]]; then
    git clone --filter=blob:none --sparse "$repo" "$target"
fi

git -C "$target" sparse-checkout set "$extension_path"
git -C "$target" pull --ff-only origin main

echo "$target/$extension_path"
