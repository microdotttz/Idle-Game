#!/bin/bash
# Auto-rebuild on file changes + serve to mobile
# Requires: inotifywait (Linux) or fswatch (macOS)

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_DIR="$PROJECT_DIR/exports/web"
PORT=8080

# Get local IP
get_local_ip() {
    if command -v ip &> /dev/null; then
        ip route get 1 | awk '{print $7; exit}'
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
    else
        hostname -I | awk '{print $1}'
    fi
}

LOCAL_IP=$(get_local_ip)

# Find Godot
GODOT_CMD="${GODOT_CMD:-godot}"
if ! command -v $GODOT_CMD &> /dev/null; then
    if command -v godot4 &> /dev/null; then
        GODOT_CMD="godot4"
    fi
fi

build() {
    echo "[$(date +%H:%M:%S)] Building..."
    mkdir -p "$EXPORT_DIR"
    if $GODOT_CMD --headless --export-release "Web" "$EXPORT_DIR/index.html" 2>/dev/null; then
        echo "[$(date +%H:%M:%S)] ✓ Build complete - Refresh your phone!"
    else
        echo "[$(date +%H:%M:%S)] ✗ Build failed"
    fi
}

# Initial build
build

echo ""
echo "════════════════════════════════════════"
echo "  Phone URL: http://${LOCAL_IP}:${PORT}"
echo "════════════════════════════════════════"
echo ""
echo "Watching for changes... (Ctrl+C to stop)"
echo ""

# Start server in background
cd "$EXPORT_DIR"
python3 -m http.server $PORT &
SERVER_PID=$!
trap "kill $SERVER_PID 2>/dev/null" EXIT

cd "$PROJECT_DIR"

# Watch for changes
if command -v inotifywait &> /dev/null; then
    # Linux
    while true; do
        inotifywait -q -r -e modify,create,delete \
            --exclude '(\.git|exports|\.import)' \
            "$PROJECT_DIR/scripts" "$PROJECT_DIR/scenes" "$PROJECT_DIR/resources" 2>/dev/null
        sleep 0.5
        build
    done
elif command -v fswatch &> /dev/null; then
    # macOS
    fswatch -o -r --exclude '\.git' --exclude 'exports' --exclude '\.import' \
        "$PROJECT_DIR/scripts" "$PROJECT_DIR/scenes" "$PROJECT_DIR/resources" | while read; do
        build
    done
else
    echo "Auto-rebuild not available."
    echo "Install inotifywait (Linux) or fswatch (macOS) for auto-rebuild."
    echo ""
    echo "For now, just refresh your phone after making changes in Godot."
    echo "Server running at http://${LOCAL_IP}:${PORT}"
    wait $SERVER_PID
fi
