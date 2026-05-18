export const ZOXIDE_INIT_PATH = ($nu.cache-dir | path join zoxide init.nu)

export def init-zoxide [] {
	mkdir ($ZOXIDE_INIT_PATH | path dirname)
	zoxide init nushell --hook prompt --cmd cd | save -f $ZOXIDE_INIT_PATH
}
