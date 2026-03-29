set fish_greeting ""
# figlet -n "oida" | cowsay -n
set -x EDITOR nvim
set -x GOPATH ~/.go
set -x DOCKER_HOST unix://$XDG_RUNTIME_DIR/podman/podman.sock
set -gx INFISICAL_API_URL "https://secrets.saygex.xyz"
# set -x MANPAGER nvim +Man!

bind -M insert alt-m accept-autosuggestion

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

if status is-interactive

    fish_vi_key_bindings

    zoxide init --cmd cd fish | source
    starship init fish | source
    atuin init fish --disable-up-arrow | source

    abbr ip 'ip -c'
    alias owo='sudo'
    alias uwu='sudo'
    alias pwease='sudo'
    alias upload='fish ~/dotfiles/.config/fish/thing.fish -u'
    alias download='fish ~/dotfiles/.config/fish/thing.fish'
    alias clock='tty-clock -sc'
    alias neovim='nvim'
    alias v='nvim'
    alias vim='nvim'
    alias vd='cd /home/veya/dotfiles && nvim .'
    alias ff='hyfetch'
    alias :3='hyfetch'
    alias putty='sudo cu -l /dev/ttyUSB0 -s 9600'
    alias ls='eza --icons'
    alias t='bash -c "~/dotfiles/.config/tmux/tmux_startup.sh"'
    alias ga='git add'
    alias glog='git log'
    alias gs='git status'
    alias gd='git diff --stat'
    alias cat='bat'
    alias rec='asciinema rec'
    alias play='asciinema play'
    alias stream='asciinema stream -r'
    alias k='kubectl'
    alias g='gns3util'
    alias gr='go run .'
    alias zr='zig build run'
    alias uuid="python3 -c 'import uuid; print(uuid.uuid4())'"
    alias p='podman'
    alias pd='podman-compose'
    alias docker='podman'
    alias ducktwerk='duckdb'
    alias ragebait='/home/veya/mini-moulinette/mini-moul.sh'
    alias oarsch='norminette'
end
set -gx PATH /home/veya/.local/funcheck/host $PATH

alias gbuild="mise run build-cli && grefresh"
abbr -a gdev "./dist/gns3util"

function grefresh
    if test -f ./dist/gns3util
        ./dist/gns3util _carapace fish | source
        echo "Completions refreshed from ./dist/gns3util"
    else
        echo "Error: ./dist/gns3util not found. Run 'mise run build-cli' first."
    end
end
