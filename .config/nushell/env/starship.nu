use cache.nu save-init

export const STARSHIP_INIT_PATH = ($nu.data-dir | path join vendor autoload starship.nu)

export const STARSHIP_COMPLETIONS_PATH = ($nu.cache-dir | path join starship completions.nu)

export def init-starship [] {
    save-init $STARSHIP_INIT_PATH (^starship init nu | complete)
}

export def gen-completions-starship [] {
    save-init $STARSHIP_COMPLETIONS_PATH (^starship completions nushell | complete)
}
