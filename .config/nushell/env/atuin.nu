export const ATUIN_INIT_PATH = ($nu.cache-dir | path join atuin init.nu)


export def init-atuin [] {
	mkdir ($ATUIN_INIT_PATH | path dirname)
	atuin init nu --disable-up-arrow | save --force $ATUIN_INIT_PATH
}
