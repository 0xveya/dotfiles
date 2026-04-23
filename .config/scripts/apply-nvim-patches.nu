#!/usr/bin/env nu

const LAZY_DIR    = "~/.local/share/nvim/lazy"
const PATCHES_DIR = "~/.config/nvim/patches"

def lazy-dir    [] { $LAZY_DIR    | path expand }
def patches-dir [] { $PATCHES_DIR | path expand }

# Extract the target file path from a patch file (reads the +++ b/<path> line)
def patch-target [patch_file: path] {
    open --raw $patch_file
        | lines
        | where { |l| $l | str starts-with "+++" }
        | first
        | str replace --regex '^\+{3}\s+(b/)?' ''
        | str trim
}

# Check if a patch is already applied by looking for the first added line in the target file
def patch-applied? [plugin_dir: path, patch_file: path] {
    let rel    = (patch-target $patch_file)
    let target = ($plugin_dir | path join $rel)
    if not ($target | path exists) { return false }

    let added = (
        open --raw $patch_file
            | lines
            | where { |l| ($l | str starts-with "+") and not ($l | str starts-with "+++") }
            | first
            | str substring 1..
    )
    open --raw $target | str contains $added
}

# List all nvim plugin patches and their current status
def main [] {
    let pdir    = (patches-dir)
    let patches = (glob ($pdir | path join "*.patch"))
    if ($patches | is-empty) {
        print $"no patches found in ($pdir)"
        return
    }
    $patches | each { |p|
        let plugin     = ($p | path basename | str replace ".patch" "")
        let plugin_dir = ((lazy-dir) | path join $plugin)
        let installed  = ($plugin_dir | path exists)
        let applied    = if $installed { patch-applied? $plugin_dir $p } else { false }
        { plugin: $plugin, installed: $installed, applied: $applied }
    } | table
}

# Apply nvim plugin patches (all patches, or just one plugin)
def "main apply" [
    plugin?: string  # plugin name e.g. supermaven-nvim — omit to apply all
] {
    let pdir    = (patches-dir)
    let ldir    = (lazy-dir)
    let patches = if $plugin != null {
        let p = ($pdir | path join $"($plugin).patch")
        if not ($p | path exists) {
            error make { msg: $"no patch found for ($plugin) at ($p)" }
        }
        [$p]
    } else {
        glob ($pdir | path join "*.patch")
    }

    if ($patches | is-empty) {
        print "no patches found"
        return
    }

    for patch_file in $patches {
        let plugin_name = ($patch_file | path basename | str replace ".patch" "")
        let plugin_dir  = ($ldir | path join $plugin_name)

        if not ($plugin_dir | path exists) {
            print $"  ⚠  ($plugin_name): not installed at ($plugin_dir)"
            continue
        }

        if (patch-applied? $plugin_dir $patch_file) {
            print $"  ✓  ($plugin_name): already applied"
            continue
        }

        let result = (
            ^patch -p1 -d ($plugin_dir | into string) -i ($patch_file | into string)
                | complete
        )

        if $result.exit_code == 0 {
            print $"  ✓  ($plugin_name): applied"
        } else {
            print $"  ✗  ($plugin_name): failed"
            print $result.stdout
            if ($result.stderr | str length) > 0 { print $result.stderr }
        }
    }
}
