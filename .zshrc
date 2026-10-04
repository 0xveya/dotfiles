# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:$HOME/.cargo/bin
PATH="$PATH":"$HOME/.local/scripts/"
export LANG=en_US.UTF-8
export EDITOR="nvim"
if [[ -n "${VIVEN_MODE:-}" ]]; then
    export EDITOR="vim"
    export VISUAL="vim"
    PROMPT='; '
    RPROMPT=''
    RPS1=''
    bindkey -e
    bindkey '^L' clear-screen
    alias vi='/usr/bin/vim -u NONE -N'
    alias vim='/usr/bin/vim -u NONE -N'
    alias v='vim'
    alias nvim='/usr/bin/nvim -u NONE -i NONE'
    printf '\e[2 q'
    printf '\e]12;#ffffff\a'
    return
fi
#export ANDROID_HOME=$HOME/Android/Sdk
#path+=("$HOME/Android/Sdk/platform-tools")
#path=("$HOME/Android/Sdk/platform-tools" $path)
export PATH
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
[[ -r ~/Repos/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
znap source marlonrichert/zsh-edit
bindkey '^L' clear-screen
HISTORY_IGNORE=clear
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=()

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
alias vim="nvim"
alias v="nvim"
alias ff="hyfetch -b fastfetch"
alias hy="hyfetch -b fastfetch"
alias :3="hyfetch -b fastfetch"
printf '%b\n' '\e[49m                         \e[38;2;104;186;170;49m▄\e[38;2;99;187;166;48;2;119;200;182m▄\e[38;2;104;194;168;48;2;134;215;193m▄\e[38;2;126;215;185;49m▄\e[49m      \e[m'
printf '%b\n' '\e[49m        \e[38;2;119;188;171;49m▄\e[38;2;130;213;194;49m▄\e[38;2;137;210;192;49m▄\e[49m             \e[49;38;2;129;190;178m▀\e[38;2;94;191;170;48;2;98;187;168m▄\e[38;2;82;196;166;48;2;83;185;159m▄\e[38;2;90;203;169;48;2;85;190;159m▄\e[38;2;118;214;182;48;2;107;206;172m▄\e[49m      \e[m'
printf '%b\n' '\e[49m       \e[38;2;124;192;169;48;2;132;188;169m▄\e[38;2;93;191;164;48;2;96;184;161m▄\e[38;2;74;184;156;48;2;78;180;155m▄\e[38;2;92;194;167;48;2;100;192;168m▄\e[38;2;138;214;191;48;2;145;214;193m▄\e[49m             \e[38;2;74;185;159;48;2;90;196;172m▄\e[38;2;75;192;162;48;2;76;195;164m▄\e[38;2;112;215;185;48;2;85;197;164m▄\e[38;2;138;208;184;48;2;135;221;192m▄\e[49m      \e[m'
printf '%b\n' '\e[49m       \e[49;38;2;124;192;169m▀\e[38;2;107;196;171;48;2;101;194;169m▄\e[38;2;81;186;157;48;2;80;184;158m▄\e[38;2;87;192;163;48;2;90;192;164m▄\e[38;2;128;207;182;48;2;133;210;186m▄\e[49m            \e[38;2;101;193;171;48;2;105;193;172m▄\e[38;2;79;195;169;48;2;70;184;157m▄\e[38;2;90;195;169;48;2;83;192;164m▄\e[49;38;2;128;214;189m▀\e[49m       \e[m'
printf '%b\n' '\e[49m         \e[38;2;85;193;159;48;2;82;189;158m▄\e[38;2;78;189;161;48;2;76;189;155m▄\e[38;2;115;206;182;48;2;126;210;184m▄\e[49m         \e[49;38;2;247;243;235m▀\e[38;2;239;255;243;49m▄\e[38;2;188;242;222;49m▄\e[38;2;101;203;178;48;2;110;204;182m▄\e[38;2;79;195;169;48;2;74;190;165m▄\e[38;2;112;206;186;48;2;108;207;185m▄\e[49m        \e[m'
printf '%b\n' '\e[49;38;2;196;197;190m▀\e[49m \e[49;38;2;189;189;185m▀\e[49;38;2;239;239;235m▀\e[49m     \e[38;2;101;199;173;48;2;94;197;167m▄\e[38;2;81;189;173;48;2;82;187;170m▄\e[38;2;90;197;181;48;2;102;198;184m▄\e[38;2;124;216;196;49m▄\e[49m         \e[38;2;103;216;193;49m▄\e[38;2;95;231;204;48;2;132;216;189m▄\e[38;2;50;204;177;48;2;86;202;174m▄\e[38;2;58;205;181;48;2;76;194;168m▄\e[38;2;108;225;206;48;2;124;211;193m▄\e[49m        \e[m'
printf '%b\n' '\e[49m         \e[38;2;109;224;204;48;2;107;202;179m▄\e[38;2;79;219;199;48;2;84;202;178m▄\e[38;2;48;195;177;48;2;75;194;174m▄\e[38;2;83;217;206;48;2;117;217;201m▄\e[38;2;81;239;231;49m▄\e[49m \e[38;2;4;249;239;49m▄\e[38;2;45;255;255;49m▄\e[38;2;30;248;238;49m▄\e[38;2;31;242;235;49m▄\e[38;2;45;255;254;48;2;104;255;255m▄\e[38;2;11;255;238;48;2;54;237;221m▄\e[38;2;0;252;230;48;2;36;236;214m▄\e[38;2;5;247;229;48;2;26;235;210m▄\e[38;2;13;246;229;48;2;20;233;209m▄\e[38;2;18;241;225;48;2;7;225;202m▄\e[38;2;27;239;222;48;2;9;217;195m▄\e[38;2;33;232;210;48;2;41;222;198m▄\e[38;2;83;255;240;48;2;96;244;219m▄\e[38;2;105;255;235;48;2;119;226;201m▄\e[38;2;124;249;223;49m▄\e[49m     \e[m'
printf '%b\n' '\e[49m         \e[38;2;37;223;213;48;2;74;231;217m▄\e[38;2;35;234;228;48;2;58;234;227m▄\e[38;2;33;241;235;48;2;24;213;208m▄\e[38;2;37;250;240;48;2;42;234;226m▄\e[38;2;19;246;238;48;2;44;255;245m▄\e[38;2;0;248;244;48;2;0;246;238m▄\e[38;2;0;255;251;48;2;0;252;243m▄\e[38;2;1;251;239;48;2;0;239;228m▄\e[38;2;0;249;235;48;2;8;247;232m▄\e[38;2;0;252;236;48;2;9;251;235m▄\e[38;2;0;254;238;48;2;2;248;231m▄\e[38;2;0;246;227;48;2;0;252;232m▄\e[38;2;26;252;239;48;2;14;255;240m▄\e[38;2;31;206;204;48;2;34;247;241m▄\e[38;2;0;133;136;48;2;38;227;224m▄\e[38;2;92;203;204;48;2;20;189;187m▄\e[38;2;104;213;213;48;2;19;182;177m▄\e[38;2;79;211;207;48;2;16;184;175m▄\e[38;2;0;135;124;48;2;25;208;192m▄\e[38;2;21;241;217;48;2;26;231;205m▄\e[38;2;8;254;225;48;2;26;236;208m▄\e[38;2;2;247;224;49m▄\e[49m    \e[m'
printf '%b\n' '\e[49m       \e[38;2;20;223;209;49m▄\e[38;2;28;205;207;48;2;29;221;217m▄\e[38;2;8;174;175;48;2;60;255;255m▄\e[38;2;10;181;164;48;2;61;255;248m▄\e[38;2;29;201;179;48;2;50;251;231m▄\e[38;2;81;252;237;48;2;55;251;235m▄\e[38;2;89;255;255;48;2;44;248;241m▄\e[38;2;50;255;255;48;2;27;254;255m▄\e[38;2;13;245;248;48;2;11;253;253m▄\e[38;2;2;252;242;48;2;2;251;244m▄\e[38;2;0;254;240;48;2;0;252;242m▄\e[38;2;2;251;244;48;2;0;252;244m▄\e[38;2;7;249;240;48;2;3;251;240m▄\e[38;2;11;244;227;48;2;16;255;240m▄\e[38;2;20;214;196;48;2;25;226;211m▄\e[38;2;0;117;103;48;2;0;120;114m▄\e[38;2;0;30;17;48;2;0;24;21m▄\e[38;2;0;23;14;48;2;0;50;47m▄\e[38;2;0;31;21;48;2;0;22;17m▄\e[38;2;0;104;87;48;2;0;47;39m▄\e[38;2;31;197;173;48;2;0;112;96m▄\e[38;2;29;236;207;48;2;14;219;193m▄\e[38;2;18;246;217;48;2;9;243;216m▄\e[38;2;12;239;215;48;2;10;245;227m▄\e[38;2;0;229;207;48;2;9;230;214m▄\e[38;2;4;238;214;49m▄\e[49m \e[38;2;205;255;253;49m▄\e[m'
printf '%b\n' '\e[49m       \e[38;2;0;128;121;48;2;29;190;183m▄\e[38;2;0;22;22;48;2;0;92;97m▄\e[38;2;0;39;38;48;2;114;200;203m▄\e[38;2;0;37;29;48;2;121;222;213m▄\e[38;2;10;119;107;48;2;32;153;139m▄\e[38;2;0;94;86;48;2;12;154;145m▄\e[38;2;29;207;204;48;2;97;255;255m▄\e[38;2;30;234;238;48;2;76;255;255m▄\e[38;2;17;245;244;48;2;19;246;249m▄\e[38;2;7;251;234;48;2;0;253;238m▄\e[38;2;5;253;228;48;2;0;255;236m▄\e[38;2;13;248;230;48;2;3;252;236m▄\e[38;2;23;244;228;48;2;11;248;234m▄\e[38;2;2;209;196;48;2;6;229;213m▄\e[38;2;0;193;176;48;2;19;224;205m▄\e[38;2;0;204;177;48;2;15;204;179m▄\e[38;2;11;247;220;48;2;13;195;170m▄\e[38;2;9;248;231;48;2;11;191;175m▄\e[38;2;7;255;239;48;2;16;212;196m▄\e[38;2;0;255;230;48;2;10;238;209m▄\e[38;2;0;247;210;48;2;6;244;209m▄\e[38;2;0;242;208;48;2;0;221;187m▄\e[38;2;9;238;204;48;2;0;201;165m▄\e[38;2;8;236;195;48;2;0;206;169m▄\e[38;2;2;233;196;48;2;7;234;198m▄\e[38;2;11;252;225;48;2;17;254;224m▄\e[49m  \e[m'
printf '%b\n' '\e[49m       \e[38;2;30;220;201;48;2;8;178;164m▄\e[38;2;61;205;186;48;2;0;43;31m▄\e[38;2;71;202;183;48;2;0;29;18m▄\e[38;2;71;217;199;48;2;0;26;12m▄\e[38;2;38;214;196;48;2;0;52;36m▄\e[38;2;8;227;208;48;2;0;174;158m▄\e[38;2;0;236;218;48;2;1;212;200m▄\e[38;2;0;239;225;48;2;1;230;223m▄\e[38;2;9;241;226;48;2;12;245;237m▄\e[38;2;0;192;171;48;2;10;236;217m▄\e[38;2;0;187;164;48;2;11;228;207m▄\e[38;2;0;185;163;48;2;22;230;210m▄\e[38;2;0;169;151;48;2;7;205;191m▄\e[38;2;0;164;154;48;2;0;186;178m▄\e[38;2;0;201;195;48;2;0;188;179m▄\e[38;2;0;246;238;48;2;0;229;211m▄\e[38;2;0;254;245;48;2;2;255;239m▄\e[38;2;1;255;245;48;2;8;255;242m▄\e[38;2;2;252;240;48;2;3;255;239m▄\e[38;2;0;247;236;48;2;0;255;233m▄\e[38;2;0;247;233;48;2;0;252;228m▄\e[38;2;0;252;233;48;2;0;249;224m▄\e[38;2;0;253;235;48;2;0;248;220m▄\e[38;2;1;252;233;48;2;2;246;218m▄\e[38;2;1;251;237;48;2;2;245;222m▄\e[38;2;0;251;245;48;2;0;248;235m▄\e[38;2;0;250;246;48;2;13;247;238m▄\e[38;2;0;245;235;49m▄\e[m'
printf '%b\n' '\e[49m      \e[38;2;39;202;193;48;2;32;191;178m▄\e[38;2;0;221;204;48;2;5;216;195m▄\e[38;2;0;229;207;48;2;15;222;198m▄\e[38;2;0;242;220;48;2;24;228;205m▄\e[38;2;10;254;238;48;2;33;241;223m▄\e[38;2;7;255;243;48;2;15;241;224m▄\e[38;2;0;255;240;48;2;0;251;231m▄\e[38;2;0;255;242;48;2;0;254;234m▄\e[38;2;9;249;229;48;2;0;246;226m▄\e[38;2;9;229;209;48;2;8;232;213m▄\e[38;2;0;204;185;48;2;0;177;156m▄\e[38;2;22;215;193;48;2;0;183;159m▄\e[38;2;7;198;170;48;2;0;175;146m▄\e[38;2;1;199;171;48;2;0;169;143m▄\e[38;2;12;223;200;48;2;0;177;161m▄\e[38;2;21;244;232;48;2;6;223;216m▄\e[38;2;14;253;255;48;2;13;255;255m▄\e[38;2;3;248;255;48;2;0;251;255m▄\e[38;2;2;242;252;48;2;0;249;251m▄\e[38;2;3;238;245;48;2;0;244;246m▄\e[38;2;1;233;239;48;2;0;240;240m▄\e[38;2;0;231;234;48;2;0;239;235m▄\e[38;2;0;231;228;48;2;0;243;234m▄\e[38;2;0;232;226;48;2;0;246;235m▄\e[38;2;0;231;226;48;2;0;246;233m▄\e[38;2;0;232;228;48;2;0;246;235m▄\e[38;2;0;246;243;48;2;4;255;255m▄\e[38;2;0;249;245;48;2;1;255;254m▄\e[38;2;0;252;244;48;2;3;255;245m▄\e[m'
printf '%b\n' '\e[49m      \e[49;38;2;40;206;204m▀\e[38;2;34;225;226;48;2;11;242;235m▄\e[38;2;13;247;246;48;2;6;251;242m▄\e[38;2;0;255;250;48;2;0;255;242m▄\e[38;2;0;255;248;48;2;0;255;242m▄\e[38;2;0;254;246;48;2;0;255;242m▄\e[38;2;11;249;244;48;2;5;251;238m▄\e[38;2;28;255;250;48;2;24;255;247m▄\e[38;2;32;255;244;48;2;39;255;246m▄\e[38;2;23;254;237;48;2;36;255;241m▄\e[38;2;17;250;242;48;2;24;251;238m▄\e[38;2;0;219;211;48;2;7;225;213m▄\e[38;2;0;185;168;48;2;2;199;178m▄\e[38;2;0;174;150;48;2;0;190;164m▄\e[38;2;4;204;175;48;2;16;226;196m▄\e[38;2;0;210;187;48;2;14;236;216m▄\e[38;2;1;218;211;48;2;8;238;235m▄\e[38;2;6;224;228;48;2;2;236;241m▄\e[38;2;9;217;227;48;2;12;238;246m▄\e[38;2;8;214;224;48;2;10;232;239m▄\e[38;2;5;212;222;48;2;7;227;234m▄\e[38;2;2;212;221;48;2;4;223;229m▄\e[38;2;0;210;220;48;2;0;218;223m▄\e[38;2;0;213;223;48;2;0;220;224m▄\e[38;2;4;219;229;48;2;2;224;229m▄\e[38;2;4;226;233;48;2;1;228;231m▄\e[38;2;14;246;250;48;2;9;248;250m▄\e[38;2;13;250;252;48;2;10;253;253m▄\e[38;2;13;250;252;48;2;14;255;253m▄\e[m'
printf '%b\n' '\e[49m     \e[38;2;243;239;245;49m▄\e[49m  \e[49;38;2;30;239;242m▀\e[38;2;0;254;254;48;2;0;255;254m▄\e[38;2;0;254;255;48;2;0;255;254m▄\e[38;2;0;252;255;48;2;0;252;254m▄\e[38;2;12;248;255;48;2;11;248;255m▄\e[38;2;16;253;255;48;2;19;255;255m▄\e[38;2;3;250;255;48;2;12;255;251m▄\e[38;2;0;235;235;48;2;5;245;237m▄\e[38;2;0;203;200;48;2;9;228;222m▄\e[38;2;0;181;175;48;2;0;199;191m▄\e[38;2;0;167;153;48;2;0;172;155m▄\e[38;2;0;166;147;48;2;0;162;141m▄\e[38;2;0;167;147;48;2;0;168;143m▄\e[38;2;0;173;158;48;2;0;177;156m▄\e[38;2;0;181;175;48;2;0;183;176m▄\e[38;2;1;190;192;48;2;0;195;199m▄\e[38;2;0;179;192;48;2;4;190;205m▄\e[38;2;0;181;200;48;2;5;191;208m▄\e[38;2;1;190;206;48;2;4;195;210m▄\e[38;2;0;196;209;48;2;2;200;213m▄\e[38;2;0;207;219;48;2;0;205;218m▄\e[38;2;0;216;225;48;2;0;213;223m▄\e[38;2;2;226;232;48;2;5;222;231m▄\e[38;2;4;233;238;48;2;5;229;236m▄\e[38;2;10;244;247;48;2;14;246;250m▄\e[38;2;9;245;247;48;2;11;247;250m▄\e[38;2;9;245;247;48;2;12;249;251m▄\e[m'
printf '%b\n' '\e[49m   \e[49;38;2;239;238;241m▀\e[49m \e[49;38;2;230;238;235m▀\e[49m   \e[38;2;22;244;240;48;2;3;253;251m▄\e[38;2;8;250;246;48;2;0;255;255m▄\e[38;2;3;251;252;48;2;1;253;255m▄\e[38;2;10;252;255;48;2;13;249;255m▄\e[38;2;6;240;255;48;2;7;238;255m▄\e[38;2;0;227;242;48;2;0;223;238m▄\e[38;2;0;215;228;48;2;0;208;218m▄\e[38;2;6;205;213;48;2;0;179;182m▄\e[38;2;10;201;203;48;2;0;173;170m▄\e[38;2;2;199;196;48;2;0;169;161m▄\e[38;2;2;196;194;48;2;0;165;155m▄\e[38;2;8;192;194;48;2;7;181;172m▄\e[38;2;11;193;195;48;2;5;182;174m▄\e[38;2;5;195;197;48;2;0;184;181m▄\e[38;2;1;196;201;48;2;0;184;189m▄\e[38;2;0;198;208;48;2;4;196;206m▄\e[38;2;0;201;213;48;2;3;199;213m▄\e[38;2;0;208;217;48;2;3;206;217m▄\e[38;2;0;213;221;48;2;2;212;221m▄\e[48;2;0;218;223m \e[38;2;0;222;225;48;2;0;223;225m▄\e[38;2;0;229;230;48;2;0;230;230m▄\e[38;2;0;233;232;48;2;0;235;234m▄\e[38;2;0;235;235;48;2;2;239;238m▄▄▄\e[m'
printf '%b\n' '\e[49m    \e[38;2;242;242;244;49m▄\e[49m    \e[49;38;2;58;225;223m▀\e[38;2;38;231;223;48;2;26;240;229m▄\e[38;2;11;244;236;48;2;7;250;238m▄\e[38;2;2;250;248;48;2;1;252;250m▄\e[38;2;0;250;252;48;2;0;249;253m▄\e[38;2;3;246;250;48;2;0;239;246m▄\e[38;2;6;239;247;48;2;0;230;238m▄\e[38;2;5;224;234;48;2;16;226;235m▄\e[38;2;4;220;234;48;2;15;221;229m▄\e[38;2;0;220;230;48;2;6;221;226m▄\e[38;2;0;216;227;48;2;2;217;224m▄\e[38;2;0;200;215;48;2;1;202;214m▄\e[38;2;0;200;213;48;2;3;201;212m▄\e[38;2;0;202;211;48;2;0;204;212m▄\e[38;2;0;202;209;48;2;0;204;211m▄\e[38;2;0;201;210;48;2;0;200;211m▄\e[48;2;0;201;213m \e[38;2;2;205;216;48;2;0;206;216m▄\e[38;2;7;210;221;48;2;5;210;221m▄\e[38;2;9;212;223;48;2;6;214;223m▄\e[38;2;11;214;225;48;2;6;217;225m▄\e[38;2;16;219;230;48;2;9;222;230m▄\e[38;2;13;224;232;48;2;7;227;232m▄\e[38;2;3;225;230;48;2;0;231;232m▄\e[38;2;0;227;230;48;2;0;233;232m▄▄\e[m'
printf '%b\n' '\e[49m           \e[38;2;5;227;238;48;2;8;235;238m▄\e[38;2;5;233;249;48;2;3;238;247m▄\e[38;2;4;233;249;48;2;1;239;250m▄\e[38;2;9;232;245;48;2;6;236;247m▄\e[38;2;9;232;245;48;2;9;235;245m▄\e[38;2;5;233;247;48;2;9;235;247m▄\e[38;2;3;230;247;48;2;7;230;246m▄\e[38;2;0;225;240;48;2;0;224;237m▄\e[38;2;1;222;234;48;2;0;220;232m▄\e[38;2;0;216;226;48;2;0;211;223m▄\e[38;2;0;214;221;48;2;0;207;217m▄\e[38;2;0;211;216;48;2;0;201;206m▄\e[38;2;0;207;211;48;2;0;197;202m▄\e[38;2;0;204;211;48;2;0;198;205m▄\e[38;2;0;203;211;48;2;0;199;207m▄\e[48;2;0;206;214m \e[38;2;1;207;215;48;2;5;211;219m▄\e[38;2;9;212;221;48;2;10;214;222m▄\e[38;2;7;210;219;48;2;9;212;221m▄\e[38;2;5;209;218;48;2;8;211;220m▄\e[38;2;5;209;218;48;2;8;214;222m▄\e[38;2;5;209;218;48;2;5;216;222m▄\e[38;2;4;208;216;48;2;4;215;221m▄\e[38;2;2;205;214;48;2;2;212;219m▄\e[m'
printf '%b\n' '\e[49m         \e[49;38;2;178;240;235m▀\e[49m \e[49;38;2;3;224;236m▀\e[49;38;2;2;229;246m▀\e[49;38;2;0;230;246m▀\e[49;38;2;5;228;242m▀▀\e[49;38;2;2;229;244m▀\e[49;38;2;2;229;246m▀\e[49;38;2;2;227;243m▀\e[49;38;2;4;225;237m▀\e[49;38;2;0;219;229m▀\e[49;38;2;1;216;223m▀\e[49;38;2;1;214;220m▀\e[49;38;2;2;213;217m▀\e[49;38;2;1;209;216m▀\e[49;38;2;0;206;214m▀\e[49;38;2;0;205;213m▀▀\e[49;38;2;5;209;218m▀\e[49;38;2;4;208;216m▀▀\e[49;38;2;3;207;215m▀\e[49;38;2;2;205;214m▀\e[49;38;2;1;204;213m▀\e[49;38;2;0;202;211m▀\e[m'
printf '%b\n' ''
# figlet oida | cowsay -n
export PATH=$PATH:$HOME/go/bin
alias sudo="run0"
alias yay="paru"
alias itsi="cp -r ~/obsidianschule/latex/template/itsi/* ."
alias nwt="cp -r ~/obsidianschule/latex/template/nwt/* ."


if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi # added by Nix installer
. ~/.gns3util-complete.zsh
export PATH="$HOME/.local/bin:$PATH"

if [ -f "$HOME/.local/share/dnvm/env" ]; then
    . "$HOME/.local/share/dnvm/env"
fi
export PATH=/home/veya/.local/share/mise/installs/codex/0.123.0:/home/veya/.local/share/mise/installs/television/0.15.5/tv-0.15.5-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.5:/home/veya/.config/carapace/bin:/home/veya/.local/share/mise/installs/television/0.15.4/tv-0.15.4-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.4:/home/veya/.bun/bin:/home/veya/.cache/.bun/bin:/home/veya/.dotnet/tools:/home/veya/.local/share/dnvm:/home/veya/.go/bin:/home/veya/.local/bin:/home/veya/.cargo/bin:/home/veya/.nix-profile/bin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin:/home/veya/.local/funcheck/host:~/.boot
export PATH=/home/veya/.local/share/mise/installs/codex/0.123.0:/home/veya/.local/share/mise/installs/television/0.15.5/tv-0.15.5-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.5:/home/veya/.config/carapace/bin:/home/veya/.local/share/mise/installs/television/0.15.4/tv-0.15.4-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.4:/home/veya/.bun/bin:/home/veya/.cache/.bun/bin:/home/veya/.dotnet/tools:/home/veya/.local/share/dnvm:/home/veya/.go/bin:/home/veya/.local/bin:/home/veya/.cargo/bin:/home/veya/.nix-profile/bin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin:/home/veya/.local/funcheck/host:~/.boot
export PATH=/home/veya/.local/share/mise/installs/codex/0.123.0:/home/veya/.local/share/mise/installs/television/0.15.5/tv-0.15.5-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.5:/home/veya/.config/carapace/bin:/home/veya/.local/share/mise/installs/television/0.15.4/tv-0.15.4-x86_64-unknown-linux-musl:/home/veya/.local/share/mise/installs/yq/4.52.4:/home/veya/.bun/bin:/home/veya/.cache/.bun/bin:/home/veya/.dotnet/tools:/home/veya/.local/share/dnvm:/home/veya/.go/bin:/home/veya/.local/bin:/home/veya/.cargo/bin:/home/veya/.nix-profile/bin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin:/home/veya/.local/funcheck/host:~/.boot

alias mstest="bash /home/veya/42_minishell_tester/tester.sh"

if [[ -d /usr/lib/emscripten ]]; then
    export PATH="/usr/lib/emscripten:$PATH"
fi

# >>> vr shell integration >>>
export VR_SHIM_DIR="/home/veya/.local/share/vr/shims"
export VR_COMMAND="/home/veya/.local/bin/vr"
_vr_update_path() {
  path=(${path:#$VR_SHIM_DIR})
  if "$VR_COMMAND" shell active >/dev/null 2>&1; then path=($VR_SHIM_DIR $path); fi
}
typeset -ga chpwd_functions
(( ${chpwd_functions[(I)_vr_update_path]} )) || chpwd_functions+=(_vr_update_path)
_vr_update_path
autoload -Uz compinit && compinit
source <("$VR_COMMAND" completion zsh)
# <<< vr shell integration <<<
