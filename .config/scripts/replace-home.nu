#!/usr/bin/env nu

const DEFAULT_FILES = [
    ".config"
    ".zshrc"
    ".stow-local-ignore"
    ".gitignore"
]

def text-files [roots: list<string>] {
    let files = (
        $roots
        | each { |root| if ($root | path exists) { glob --no-dir $"($root)/**" } else { [] } }
        | flatten
        | where {|path| $path !~ '(^|/)(tmux/plugins|\.git|\.jj)(/|$)' }
    )

    $files | where {|path|
        let kind = (file $path | complete | get stdout)
        $kind =~ 'text|JSON|TOML|shell|script|KDL|Unicode|ASCII'
    }
}

def main [
    --from: string = "/home/veya"
    --to: string = ""
    --write
] {
    let target_home = if $to == "" { $env.HOME } else { $to }
    let files = (text-files $DEFAULT_FILES)
    let matches = ($files | where {|path| (open --raw $path) | str contains $from })

    if (not $write) {
        $matches | each { |path| { file: $path, from: $from, to: $target_home } }
        print "dry run: pass --write to replace"
        return
    }

    $matches | each { |path|
        let updated = (open --raw $path | str replace --all $from $target_home)
        $updated | save --force $path
        $path
    }
}
