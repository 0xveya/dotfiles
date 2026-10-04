export def init-carapace [] {
    let bin = ($env.HOME | path join .config carapace bin)
    {
        PATH: ($env.PATH | where {|entry| $entry != $bin} | prepend $bin)
        CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
    }
}
