#!/usr/bin/env nu

const ROOTS = [
    ".config"
    ".zshrc"
]

def color-files [] {
    rg --files-with-matches --color never '#[0-9a-fA-F]{6,8}' ...($ROOTS)
    | lines
    | where {|path| $path !~ '(^|/)(tmux/plugins|\.git|\.jj)(/|$)' }
}

def main [] {
    rg --no-heading --line-number --color never '#[0-9a-fA-F]{6,8}' ...($ROOTS)
}

def "main unique" [] {
    rg --no-filename --only-matching --color never '#[0-9a-fA-F]{6,8}' ...($ROOTS)
    | lines
    | str downcase
    | uniq
    | sort
}

def "main apply-map" [
    map_file: path
    --write
] {
    let replacements = (open $map_file)
    let files = (color-files)

    if (not $write) {
        print "dry run: pass --write to replace"
    }

    for file in $files {
        mut text = (open --raw $file)
        mut changed = false

        for color in ($replacements | transpose from to) {
            let next = ($text | str replace --all $color.from $color.to)
            if $next != $text {
                $changed = true
                $text = $next
            }
        }

        if $changed {
            print $file
            if $write {
                $text | save --force $file
            }
        }
    }
}
