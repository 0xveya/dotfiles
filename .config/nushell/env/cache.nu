# Publish complete integration scripts without exposing partially written files.
export def save-init [path: string output: record<exit_code: int, stdout: string, stderr: string>] {
    if $output.exit_code != 0 {
        error make {msg: $"Failed to generate ($path): ($output.stderr | str trim)"}
    }
    if ($output.stdout | str trim | is-empty) {
        error make {msg: $"Generated integration is empty: ($path)"}
    }
    if not ($output.stdout | nu-check) {
        error make {msg: $"Generated integration is invalid: ($path)"}
    }
    mkdir ($path | path dirname)
    let temporary = $"($path).($nu.pid).tmp"
    try {
        $output.stdout | save --force $temporary
        mv --force $temporary $path
    } catch {|failure|
        rm --force $temporary
        error make {msg: $"Failed to publish ($path): ($failure.msg)"}
    }
}
