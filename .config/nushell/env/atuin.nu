use cache.nu save-init

export const ATUIN_INIT_PATH = ($nu.cache-dir | path join atuin init.nu)

export def init-atuin [] {
    mut output = (^atuin init nu --disable-up-arrow --disable-ctrl-r | complete)
    if $output.exit_code == 0 {
        # Replace our previous hooks when the config is sourced again.
        $output.stdout = ($output.stdout
            | str replace 'append $_atuin_pre_execution' "where {|hook| if (($hook | describe) starts-with 'record') { not ($hook.dotfiles_atuin? | default false) } else { true }} | append {dotfiles_atuin: true, code: $_atuin_pre_execution}"
            | str replace 'append $_atuin_pre_prompt' "where {|hook| if (($hook | describe) starts-with 'record') { not ($hook.dotfiles_atuin? | default false) } else { true }} | append {dotfiles_atuin: true, code: $_atuin_pre_prompt}")
    }
    save-init $ATUIN_INIT_PATH $output
}
