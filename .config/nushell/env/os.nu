$env.PATH = [
    ($env.HOME | path join ".local/share/mise/shims")
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
] | append $env.PATH | uniq

