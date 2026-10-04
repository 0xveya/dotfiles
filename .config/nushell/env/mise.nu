use cache.nu save-init

export const MISE_INIT_PATH = ($nu.cache-dir | path join mise init.nu)

export def init-mise [] {
    mut output = (^mise activate nu | complete)
    if $output.exit_code == 0 {
        # Activation embeds the generating shell's PATH and env. Use this shell's instead.
        let start = ($output.stdout | str index-of 'export-env {')
        let end = ($output.stdout | str index-of '$env.MISE_SHELL = "nu"')
        if $start < 0 or $end < $start {
            error make {msg: 'Unexpected mise activation script; check `mise activate nu`.'}
        }
        $output.stdout = (($output.stdout | str substring 0..<$start) + 'export-env {
  if ($env.__dotfiles_mise?.pid? | default 0) == $nu.pid { return }
  $env.__dotfiles_mise = {pid: $nu.pid}
  $env.__MISE_ORIG_PATH = ($env.PATH | str join (char esep))
  ' + ($output.stdout | str substring $end..))
        $output.stdout = ($output.stdout | str replace 'add-hook hooks.env_change.PWD $mise_hook' 'add-hook hooks.env_change.PWD $mise_hook
  mise_hook')
    }
    save-init $MISE_INIT_PATH $output
}
