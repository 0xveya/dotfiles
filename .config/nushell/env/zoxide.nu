use cache.nu save-init

export const ZOXIDE_INIT_PATH = ($nu.cache-dir | path join zoxide init.nu)

export def init-zoxide [] {
    save-init $ZOXIDE_INIT_PATH (^zoxide init nushell --hook prompt --cmd cd | complete)
}
