$env.EDITOR = "nvim"
$env.GOPATH = ($env.HOME | path join ".go")
$env.DOCKER_HOST = $"unix://($env.XDG_RUNTIME_DIR)/podman/podman.sock"
$env.INFISICAL_API_URL = "https://secrets.saygex.xyz"

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
