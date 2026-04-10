#!/usr/bin/env nu

const CONFIG = "~/.config/niri/config.kdl"
const START = "// niri-monitor-preset:start"
const END = "// niri-monitor-preset:end"

const PRESETS = {
    pc: 'output "DP-1" {
    mode "2560x1440@165"
    scale 1.6
    position x=0 y=0
}

output "eDP-1" {
    off
    mode "2560x1600"
    scale 2.4
}'
    laptop: 'output "eDP-1" {
    mode "2560x1600"
    scale 2.4
    position x=0 y=0
}

output "DP-1" {
    off
}'
}

def main [] {
    print "presets:"
    $PRESETS | columns | each { |preset| print $"  ($preset)" }
}

def "main apply" [
    preset: string
    --reload
] {
    if not ($preset in ($PRESETS | columns)) {
        error make { msg: $"unknown preset: ($preset)" }
    }

    let path = ($CONFIG | path expand)
    let config = (open --raw $path)
    let before = ($config | split row $START | get 0)
    let after = ($config | split row $END | get 1)
    let block = ($PRESETS | get $preset)

    [
        ($before | str trim --right)
        $START
        $block
        $END
        ($after | str trim --left)
    ] | str join "\n" | save --force $path

    print $"wrote niri monitor preset: ($preset)"

    if $reload {
        ^niri msg action do-screen-transition
        ^niri msg action load-config-file
    }
}
