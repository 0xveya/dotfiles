$env.EDITOR = "nvim"
$env.GOPATH = ($env.HOME | path join ".go")
$env.DOCKER_HOST = $"unix://($env.XDG_RUNTIME_DIR)/podman/podman.sock"
$env.INFISICAL_API_URL = "https://secrets.saygex.xyz"

export const ENV_DIR = path self './env/mod.nu'

$env.PATH = [
    ($env.HOME | path join ".local/share/mise/installs/television/0.15.4/tv-0.15.4-x86_64-unknown-linux-musl")
    ($env.HOME | path join ".local/share/mise/installs/yq/4.52.4")
    ($env.HOME | path join ".bun/bin")
    ($env.HOME | path join ".cache/.bun/bin")
    ($env.HOME | path join ".dotnet/tools")
    ($env.HOME | path join ".local/share/dnvm")
    ($env.GOPATH | path join "bin")
    ($env.HOME | path join ".local/bin")
    ($env.HOME | path join ".cargo/bin")
    ($env.HOME | path join ".nix-profile/bin")
    "/usr/local/bin"
    "/usr/bin"
    "/usr/bin/site_perl"
    "/usr/bin/vendor_perl"
    "/usr/bin/core_perl"
    "/usr/lib/rustup/bin"
    ($env.HOME | path join ".local/funcheck/host")
]

let init_jobs = [
	{
		use $ENV_DIR atuin init-atuin
		init-atuin
	}
	{
		use $ENV_DIR carapace init-carapace
		init-carapace
	}
	{
		use $ENV_DIR zoxide init-zoxide
		init-zoxide
	}
	{
		use $ENV_DIR mise init-mise
		init-mise
	}
	{
		use $ENV_DIR starship init-starship
		init-starship
	}
	{
		use $ENV_DIR starship gen-completions-starship
		gen-completions-starship
	}
]
$init_jobs
  | par-each --threads ($init_jobs | length) { try { do $in } catch { {} } }
  | reduce --fold {} {|env_vars, acc| $acc | merge $env_vars }
  | reject --optional PWD
  | load-env
