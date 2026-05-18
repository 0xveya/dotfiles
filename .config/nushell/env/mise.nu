export const MISE_INIT_PATH = ($nu.cache-dir | path join mise init.nu)

export def init-mise [] {
	mkdir ($MISE_INIT_PATH | path dirname)
	mise activate nu | save --force $MISE_INIT_PATH
}
