$env.EDITOR = "nvim"
$env.GOPATH = ($env.HOME | path join ".go")
$env.DOCKER_HOST = $"unix://($env.XDG_RUNTIME_DIR)/podman/podman.sock"
$env.INFISICAL_API_URL = "https://secrets.saygex.xyz"

$env.PATH = [
    "/home/veya/.local/share/mise/installs/television/0.15.4/tv-0.15.4-x86_64-unknown-linux-musl"
    "/home/veya/.local/share/mise/installs/yq/4.52.4"
    "/home/veya/.bun/bin"
    "/home/veya/.cache/.bun/bin"
    "/home/veya/.dotnet/tools"
    "/home/veya/.local/share/dnvm"
    ($env.GOPATH | path join "bin")
    "/home/veya/.local/bin"
    "/home/veya/.cargo/bin"
    "/home/veya/.nix-profile/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/usr/bin/site_perl"
    "/usr/bin/vendor_perl"
    "/usr/bin/core_perl"
    "/usr/lib/rustup/bin"
    "/home/veya/.local/funcheck/host"
]
