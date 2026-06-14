# Run Valgrind with XML output, print target program's output,
# and return structured, queryable tables of memory/resource errors.
#
# This wrapper executes Valgrind under the hood, parsing its XML reports
# into a clean, Nushell-native table while preserving the target program's
# standard output and error streams. It provides convenient flags to manage
# memory leak checks, file descriptors, child process tracking, and threading analysis.
#
# Flags:
#   --no-out            - Suppress stdout and stderr from the target program.
#   --leaks             - Filter results to show only memory leaks and open file descriptors.
#   --childs            - Alias for --children.
#   --children          - Enable tracing of child processes (passes --trace-children=yes).
#   --origins           - Track origins of uninitialized values (passes --track-origins=yes).
#   --helgrind          - Shortcut for --tool=helgrind (data races & deadlocks detection).
#   --drd               - Shortcut for --tool=drd (alternative thread error detector).
#   --readline          - Auto-generate and apply a suppression file for readline/add_history leaks.
#
# Parameters:
#   --tool <string>     - Specify the Valgrind tool (memcheck, helgrind, drd, massif, etc. Default: memcheck).
#   --suppressions <f>  - Specify a custom suppression file path.
#   --exitcode <int>    - Exit with this error code if errors are found (passes --error-exitcode=<int>).
#   ...args             - The target binary and its command-line arguments.
#
# Examples:
#   1. Debug memory leaks and open file descriptors:
#      ❯ valg --leaks ./buggy_test
#
#   2. Track the origin of uninitialized memory values:
#      ❯ valg --origins ./buggy_test
#
#   3. Debug data races and deadlocks in multithreaded programs:
#      ❯ valg --helgrind ./my_thread_program
#
#   4. Run interactive CLI programs without seeing internal readline library leaks:
#      ❯ valg --readline ./cli_app
#
#   5. Find only leaked file descriptors:
#      ❯ valg ./my_program | where kind == "FD Leak"
#
#   6. Query uninitialized memory access in a specific function:
#      ❯ valg --origins ./my_program | where fn == "my_func"
#
#   7. Group errors by source file and count occurrences:
#      ❯ valg ./my_program | group-by file | transpose file errors | insert count { $in.errors | length } | select file count
def --wrapped valg [
    --no-out                  # Suppress stdout and stderr from the target program
    --leaks                   # Filter the output to only return memory leaks and open FDs
    --childs                  # Trace child processes (forks)
    --children                # Trace child processes (forks)
    --origins                 # Track origins of uninitialized values
    --helgrind                # Shortcut for --tool=helgrind (thread debugger)
    --drd                     # Shortcut for --tool=drd (thread debugger)
    --readline                # Auto-suppress readline/add_history memory leaks
    --tool: string            # Specify Valgrind tool (default: memcheck)
    --suppressions: string    # Custom suppression file
    --exitcode: int           # Set exit code if errors are found
    ...args                   # The target binary and its command-line arguments
] {
    # If the user asks for help/documentation explicitly inside the wrapped args, show help
    if ($args | any {$in == "--help" or $in == "-h"}) {
        return (help valg)
    }

    let xml_file = (mktemp --suffix .xml)
    
    # Determine which tool to run
    let tool_name = (if $helgrind {
        "helgrind"
    } else if $drd {
        "drd"
    } else {
        $tool | default "memcheck"
    })

    # Construct base valgrind arguments
    mut valg_flags = [
        "--xml=yes"
        $"--xml-file=($xml_file)"
        $"--tool=($tool_name)"
    ]

    # Tool-specific defaults
    if $tool_name == "memcheck" {
        $valg_flags = ($valg_flags | append [
            "--leak-check=full"
            "--show-leak-kinds=all"
            "--track-fds=yes"
        ])
        
        if $origins {
            $valg_flags = ($valg_flags | append "--track-origins=yes")
        }
    }

    # Trace children flags
    if $childs or $children {
        $valg_flags = ($valg_flags | append "--trace-children=yes")
    }

    # Exit code configuration
    if ($exitcode | is-not-empty) {
        $valg_flags = ($valg_flags | append $"--error-exitcode=($exitcode)")
    }

    # Custom suppression file
    if ($suppressions | is-not-empty) {
        $valg_flags = ($valg_flags | append $"--suppressions=($suppressions)")
    }

    # Handle automatic readline suppressions
    mut temp_supp_file = ""
    if $readline {
        let supp_content = '
{
   readline_leak
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:readline
}
{
   add_history_leak
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:add_history
}
'
        $temp_supp_file = (mktemp --suffix .supp)
        $supp_content | save -f $temp_supp_file
        $valg_flags = ($valg_flags | append $"--suppressions=($temp_supp_file)")
    }

    let valg_args = $valg_flags
    let result = (
        try {
            with-env {
                DEBUGINFOD_URLS: "https://debuginfod.archlinux.org"
            } {
                ^valgrind ...$valg_args ...$args | complete
            }
        } catch {|err|
            {
                stdout: ""
                stderr: $"[valg] Process terminated or crashed: ($err.msg? | default '')"
                exit_code: 139
            }
        }
    )

    # Cleanup temp suppression file if created
    if ($temp_supp_file | is-not-empty) {
        rm -f $temp_supp_file
    }

    if not $no_out {
        if ($result.stdout | is-not-empty) {
            print -n $result.stdout
        }
        if ($result.stderr | is-not-empty) {
            print -e -n $result.stderr
        }
    }

    let data = (try { open $xml_file } catch { null })
    rm --force $xml_file

    if ($data | is-empty) {
        return []
    }

    let raw_errors = ($data.content | where tag == 'error' or tag == 'fatal_signal')
    let parsed = ($raw_errors | each {|error|
        let error_content = $error.content
        let unique = ($error_content | where tag == 'unique' | get -o 0?.content?.0?.content?)
        let tid = ($error_content | where tag == 'tid' | get -o 0?.content?.0?.content?)
        
        let kind = (if $error.tag == 'fatal_signal' {
            let signame = ($error_content | where tag == 'signame' | get -o 0?.content?.0?.content? | default "UNKNOWN")
            $"FatalSignal_($signame)"
        } else {
            $error_content | where tag == 'kind' | get -o 0?.content?.0?.content?
        })

        let clean_kind = (match $kind {
            "InvalidWrite" => "Invalid Write"
            "InvalidRead" => "Invalid Read"
            "UninitValue" => "Uninitialized Value"
            "UninitCondition" => "Uninitialized Condition"
            "Leak_DefinitelyLost" => "Leak"
            "Leak_IndirectlyLost" => "Leak"
            "Leak_PossiblyLost" => "Leak"
            "Leak_StillReachable" => "Leak"
            "FdNotClosed" => "FD Leak"
            _ => (if ($kind | str starts-with "FatalSignal_") {
                let sig = ($kind | str replace "FatalSignal_" "")
                $"Fatal Signal ($sig)"
            } else {
                $kind
            })
        })

        let leak = (match $kind {
            "Leak_DefinitelyLost" => "definitely lost"
            "Leak_IndirectlyLost" => "indirectly lost"
            "Leak_PossiblyLost" => "possibly lost"
            "Leak_StillReachable" => "still reachable"
            "FdNotClosed" => "file descriptor"
            _ => null
        })

        let what = (if $error.tag == 'fatal_signal' {
            let event = ($error_content | where tag == 'event' | get -o 0?.content?.0?.content? | default "")
            let siaddr = ($error_content | where tag == 'siaddr' | get -o 0?.content?.0?.content? | default "")
            $"($event) at ($siaddr)"
        } else {
            let what_val = ($error_content | where tag == 'what' | get -o 0?.content?.0?.content?)
            if ($what_val | is-empty) {
                $error_content | where tag == 'xwhat' | get -o 0?.content | where tag == 'text' | get -o 0?.content?.0?.content?
            } else {
                $what_val
            }
        })

        let stacks = ($error_content | where tag == 'stack' | each {|stack|
            $stack.content | where tag == 'frame' | each {|frame|
                let fc = $frame.content
                {
                    fn: ($fc | where tag == 'fn' | get -o 0?.content?.0?.content?)
                    file: ($fc | where tag == 'file' | get -o 0?.content?.0?.content?)
                    line: (try { $fc | where tag == 'line' | get -o 0?.content?.0?.content? | into int } catch { null })
                    dir: ($fc | where tag == 'dir' | get -o 0?.content?.0?.content?)
                    obj: ($fc | where tag == 'obj' | get -o 0?.content?.0?.content?)
                    ip: ($fc | where tag == 'ip' | get -o 0?.content?.0?.content?)
                }
            }
        })

        let auxwhat = ($error_content | where tag == 'auxwhat' | get -o 0?.content?.0?.content?)

        let first_stack = ($stacks | get -o 0)
        let target_frame = (if ($first_stack | is-empty) {
            null
        } else {
            let local_frames = ($first_stack | where {|f|
                let is_sys = (($f.obj | default "" | str starts-with "/usr") or ($f.dir | default "" | str starts-with "/usr") or ($f.file | default "" | str starts-with "/usr"))
                let has_file = ($f.file | is-not-empty)
                $has_file and (not $is_sys)
            })
            if ($local_frames | is-empty) {
                $first_stack | get 0
            } else {
                $local_frames | get 0
            }
        })

        let stack_trace = ($stacks | each {|stack|
            $stack | each {|f|
                let file_line = (if ($f.file | is-not-empty) {
                    $" at ($f.file):($f.line)"
                } else {
                    ""
                })
                $"($f.fn)($file_line)"
            } | str join "\n"
        } | str join "\n---\n")

        {
            unique: $unique
            tid: (try { $tid | into int } catch { null })
            kind: $clean_kind
            leak: $leak
            what: $what
            file: ($target_frame.file? | default null)
            line: ($target_frame.line? | default null)
            fn: ($target_frame.fn? | default null)
            auxwhat: $auxwhat
            stack_trace: $stack_trace
        }
    })

    if $leaks {
        $parsed | where leak != null
    } else {
        $parsed
    }
}
