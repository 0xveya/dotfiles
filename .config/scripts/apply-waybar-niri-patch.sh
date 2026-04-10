#!/usr/bin/env bash
set -euo pipefail

waybar_dir="${WAYBAR_DIR:-$HOME/github/Waybar}"
remote_url="${WAYBAR_REMOTE:-https://github.com/Alexays/Waybar}"
patch_file="${WAYBAR_PATCH:-$HOME/dotfiles/.config/waybar/patches/niri-workspaces-nonempty.patch}"
commit_file="${WAYBAR_COMMIT_FILE:-$HOME/dotfiles/.config/waybar/patches/niri-workspaces-nonempty.commit}"
commit="$(<"$commit_file")"
force=0

if [[ "${1:-}" == "--force" ]]; then
    force=1
fi

if [[ ! -d "$waybar_dir/.git" ]]; then
    git clone "$remote_url" "$waybar_dir"
fi

if [[ "$force" != 1 ]] && [[ -n "$(git -C "$waybar_dir" status --porcelain)" ]]; then
    echo "Waybar tree is dirty: $waybar_dir" >&2
    echo "Commit or stash it, or rerun with --force to reset it." >&2
    exit 1
fi

git -C "$waybar_dir" fetch origin
git -C "$waybar_dir" checkout --detach "$commit"

if [[ "$force" == 1 ]]; then
    git -C "$waybar_dir" reset --hard "$commit"
    git -C "$waybar_dir" clean -fd
fi

git -C "$waybar_dir" apply --check "$patch_file"
git -C "$waybar_dir" apply "$patch_file"

echo "Applied Waybar Niri patch on $commit in $waybar_dir"
