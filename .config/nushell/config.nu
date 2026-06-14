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
        mise => $fish_completer
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
        file_format: "sqlite"
        isolation: true
    }

    menus: [
        {
            name: history_menu
            only_buffer_difference: false
            marker: "i am a bottom >w< "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: normal
                selected_text: green_bold
                description_text: dim_gray
            }
        }
    ]
}

$env.config.shell_integration.osc133 = false

alias clock = tty-clock -sc
alias v = nvim
alias vim = nvim
alias ff = hyfetch
alias ":3" = hyfetch
alias flake8 = uvx flake8 . --exclude=.venv,.git,__pycache__

alias putty = sudo cu -l /dev/ttyUSB0 -s 9600
alias core-ls = eza --icons
alias uselesspkgs = sudo pacman -Rns ...(^pacman -Qqdt | lines)

# source ~/.config/nushell/catppuccin_macchiato.nu


alias owo = sudo
alias uwu = sudo
alias pwease = sudo

alias v = nvim
alias vim = nvim
alias neovim = nvim

alias ff = hyfetch
alias ":3" = hyfetch
alias clock = tty-clock -sc

alias putty = cu -l /dev/ttyUSB0 -s 9600
alias cat = bat

alias ga = git add
alias glog = git log
alias gs = git status
alias gd = git diff --stat

alias p = podman
alias pd = podman-compose

alias k = kubectl
alias g = gns3util
alias gr = go run .
alias zr = zig build run
alias cr = cargo run
alias meow = ^cat
alias manyasl = less ~/Downloads/yasl.0

alias ducktwerk = duckdb
alias ip = ip -c
alias zt = zig build test --summary all

def vivien [] {
    ^systemctl --user stop kanata.service
    let in_kitty = (($env | get -o KITTY_PID | default "") | is-not-empty)

    if $in_kitty {
        ^kitty --single-instance --wait-for-single-instance-window-close --title vivien -o background_opacity=1.0 -o font_size=16 -o cursor_shape=block -o cursor=#f8f8f2 -o cursor_text_color=#111111 -o foreground=#f8f8f2 -o background=#111111 /usr/bin/zsh -ic "export VIVEN_MODE=1 EDITOR=vim VISUAL=vim; exec zsh -i"
    } else {
        with-env {
            VIVEN_MODE: "1"
            EDITOR: "vim"
            VISUAL: "vim"
        } {
            ^zsh -i
        }
    }
    ^systemctl --user start kanata.service
}

def unvivien [] {
    ^systemctl --user start kanata.service
}

def vivien-off [] {
    ^systemctl --user stop kanata.service
}

def --wrapped valgrind [...args] {
    let result = (
        with-env {
            DEBUGINFOD_URLS: "https://debuginfod.archlinux.org"
        } {
            ^valgrind ...$args | complete
        }
    )

    let text = (($result.stderr | default "") + ($result.stdout | default ""))

    $text
    | lines
    | each {|line|
        if ($line | str contains "ERROR SUMMARY: 0 errors") {
            $"(ansi green_bold)($line)(ansi reset)"
        } else if ($line | str contains "ERROR SUMMARY") {
            $"(ansi red_bold)($line)(ansi reset)"
        } else if ($line | str contains "All heap blocks were freed") {
            $"(ansi green_bold)($line)(ansi reset)"
        } else if ($line | str contains "no leaks are possible") {
            $"(ansi green)($line)(ansi reset)"
        } else if ($line | str contains "definitely lost") {
            $"(ansi yellow_bold)($line)(ansi reset)"
        } else if ($line | str contains "indirectly lost") {
            $"(ansi yellow)($line)(ansi reset)"
        } else if ($line | str contains "possibly lost") {
            $"(ansi magenta)($line)(ansi reset)"
        } else if ($line | str contains "Invalid read") or ($line | str contains "Invalid write") {
            $"(ansi red_bold)($line)(ansi reset)"
        } else if ($line | str contains "Error") {
            $"(ansi red)($line)(ansi reset)"
        } else {
            $line
        }
    }
    | str join "\n"
}

source ~/.config/nushell/valg.nu

def uuid4 [] {
    ^python3 -c "import uuid; print(uuid.uuid4())"
}

def uuid7 [] {
    ^python3 -c "import uuid; print(uuid.uuid7())"
}

use $ENV_DIR atuin ATUIN_INIT_PATH
source $ATUIN_INIT_PATH
hide ATUIN_INIT_PATH

use $ENV_DIR carapace CARAPACE_INIT_PATH
source $CARAPACE_INIT_PATH
hide CARAPACE_INIT_PATH

use $ENV_DIR zoxide ZOXIDE_INIT_PATH
source $ZOXIDE_INIT_PATH
hide ZOXIDE_INIT_PATH

use $ENV_DIR starship STARSHIP_INIT_PATH
use $STARSHIP_INIT_PATH
hide STARSHIP_INIT_PATH

use $ENV_DIR mise MISE_INIT_PATH
use $MISE_INIT_PATH
hide MISE_INIT_PATH

let old_prompt = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = {
  print --no-newline $'(ansi esc)]9;9;('.' | path expand)(ansi esc)\'
  do $old_prompt
}
$env.PROMPT_INDICATOR_VI_INSERT = { "" }

def _hist_search [] {
    let res = (
        ^/home/veya/coding/nushell_hist_thing/target/debug/nushell_hist_thing
            --db ~/dotfiles/.config/nushell/history.sqlite3
            --session (history session)
            --forward-format "am i a good girl? >w<"c:w
            --backward-format "i am a bottom >w<"
        e>| str trim
    )
    if ($res | str starts-with "__execute__:") {
        commandline edit --accept ($res | str replace "__execute__:" "")
    } else if ($res | is-not-empty) {
        commandline edit $res
    }
}

$env.config.keybindings = ($env.config.keybindings | append [
    {
        name: accept_autosuggestion
        modifier: alt
        keycode: char_m
        mode: [emacs, vi_insert]
        event: { send: HistoryHintComplete }
    }
    {
        name: atuin_history
        modifier: alt
        keycode: char_r
        mode: [emacs, vi_insert]
        event: { send: executehostcommand cmd: (_atuin_search_cmd) }
    }
    {
        name: sigma_history_search
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand cmd: "_hist_search" }
    }
])

def tmux-fix-gui-env [] {
    load-env {
        DISPLAY: ":0"
        WAYLAND_DISPLAY: "wayland-1"
        DBUS_SESSION_BUS_ADDRESS: "unix:path=/run/user/1000/bus"
        SSH_AUTH_SOCK: "/run/user/1000/ssh-agent.socket"
        XDG_CURRENT_DESKTOP: "niri"
        XDG_RUNTIME_DIR: "/run/user/1000"
        XDG_SESSION_DESKTOP: "niri"
        XDG_SESSION_TYPE: "wayland"
    }
}

def usb-diff [duration: duration = 5sec] {
    let before = (lsusb | lines)
    sleep $duration
    let after = (lsusb | lines)

    let added = ($after | where {|x| $x not-in $before})
    let removed = ($before | where {|x| $x not-in $after})

    if ($added | is-empty) and ($removed | is-empty) {
        print "No changes detected"
    } else {
        if not ($added | is-empty) {
            print "+ Added:"
            for x in $added { print $"  ($x)" }
        }
        if not ($removed | is-empty) {
            print "- Removed:"
            for x in $removed { print $"  ($x)" }
        }
    }
}

$env.NIX_REMOTE = 'daemon'
