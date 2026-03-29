let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

let carapace_completer = {|spans|
    CARAPACE_LENIENT=1 ^carapace $spans.0 nushell ...$spans | from json
}

let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        nu => $fish_completer
        git => $fish_completer
        asdf => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}

$env.config = {
    show_banner: false
    edit_mode: vi
    buffer_editor: "nvim"
    cursor_shape: {
        vi_insert: line
        vi_normal: block
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"

        external: {
            enable: true
            max_results: 100
            completer: $external_completer
        }

        use_ls_colors: true
    }
     history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
}

$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }

alias clock = tty-clock -sc
alias v = nvim
alias vim = nvim
alias ff = hyfetch
alias ":3" = hyfetch

alias putty = sudo cu -l /dev/ttyUSB0 -s 9600
alias core-ls = eza --icons

source ~/.config/nushell/catppuccin_macchiato.nu

$env.config.keybindings = [
    {
        name: accept_autosuggestion
        modifier: alt
        keycode: char_m
        mode: [emacs, vi_insert]
        event: { send: HistoryHintComplete }
    }
]

alias owo = sudo
alias uwu = sudo
alias pwease = sudo

alias v = nvim
alias vim = nvim
alias neovim = nvim

alias ff = hyfetch
alias ":3" = hyfetch
alias clock = tty-clock -sc

alias putty = sudo cu -l /dev/ttyUSB0 -s 9600
alias cat = bat

alias ga = git add
alias glog = git log
alias gs = git status
alias gd = git diff --stat

alias p = podman
alias pd = podman-compose
alias docker = podman

alias k = kubectl
alias g = gns3util
alias gr = go run .
alias zr = zig build run

alias rec = asciinema rec
alias play = asciinema play
alias stream = asciinema stream -r
alias ducktwerk = duckdb
alias ragebait = /home/veya/mini-moulinette/mini-moul.sh
alias oarsch = norminette
alias ip = ip -c

def uuid [] {
    ^python3 -c "import uuid; print(uuid.uuid4())"
}


source ~/.zoxide.nu
source ~/.cache/carapace/init.nu
source ~/.local/share/atuin/init.nu
use ~/.cache/starship/init.nu
use ~/.cache/mise/init.nu
