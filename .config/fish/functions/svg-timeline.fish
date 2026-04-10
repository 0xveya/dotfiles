# SVG Timeline Server Function for Fish Shell
# Usage: svg-timeline <cast-file> [port]

function svg-timeline
    if test (count $argv) -lt 1
        echo "Usage: svg-timeline <cast-file> [port]"
        echo "Example: svg-timeline alpine-setup-slop.cast"
        echo "Example: svg-timeline alpine-setup-slop.cast 3001"
        return 1
    end
    
    set cast_file $argv[1]
    set port $argv[2]
    
    # Default port
    if test -z "$port"
        set port 3000
    end
    
    # Check if cast file exists
    if not test -f "$cast_file"
        echo "Error: Cast file '$cast_file' not found"
        return 1
    end
    
    # Get absolute path to cast file
    set cast_file (realpath "$cast_file")
    
    echo "Starting SVG Timeline Server..."
    echo "Cast file: $cast_file"
    echo "Port: $port"
    echo "Opening http://localhost:$port"
    
    set project_dir "$HOME/coding/ermgamba3/svg-term-cli"
    
    # Verify the directory exists and contains timeline-server.ts
    if not test -d "$project_dir"
        echo "Error: svg-term-cli directory not found at $project_dir"
        echo "Please update project_dir in the script"
        return 1
    end
    
    if not test -f "$project_dir/timeline-server.ts"
        echo "Error: timeline-server.ts not found in $project_dir"
        return 1
    end
    
    # Change to the project directory
    cd "$project_dir"
    
    # Open browser (works on most systems)
    if command -v xdg-open >/dev/null
        xdg-open "http://localhost:$port" &
    else if command -v open >/dev/null
        open "http://localhost:$port" &
    else if command -v start >/dev/null
        start "http://localhost:$port" &
    end
    
    # Start the server
    bun run timeline-server.ts "$cast_file" --port "$port"
end
