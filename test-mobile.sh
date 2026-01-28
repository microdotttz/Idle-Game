#!/bin/bash
# Quick mobile testing script
# Exports to web and serves locally - access from your phone on the same WiFi

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_DIR="$PROJECT_DIR/exports/web"
PORT=8080

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get local IP address
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

echo -e "${YELLOW}=== Potion Shop Mobile Test ===${NC}"
echo ""

# Check if Godot is installed
GODOT_CMD=""
if command -v godot &> /dev/null; then
    GODOT_CMD="godot"
elif command -v godot4 &> /dev/null; then
    GODOT_CMD="godot4"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="/Applications/Godot.app/Contents/MacOS/Godot"
else
    echo "Godot not found in PATH."
    echo "Please either:"
    echo "  1. Add Godot to your PATH"
    echo "  2. Set GODOT_CMD environment variable"
    echo ""
    echo "Example: GODOT_CMD=/path/to/godot ./test-mobile.sh"
    exit 1
fi

# Export to web
echo "Exporting to web..."
mkdir -p "$EXPORT_DIR"
$GODOT_CMD --headless --export-release "Web" "$EXPORT_DIR/index.html" 2>/dev/null || {
    echo "Export failed. Make sure export templates are installed."
    echo "In Godot: Editor → Manage Export Templates → Download"
    exit 1
}

echo -e "${GREEN}Export complete!${NC}"
echo ""

# Start web server
echo "Starting web server..."
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Open this URL on your phone:${NC}"
echo ""
echo -e "  ${YELLOW}http://${LOCAL_IP}:${PORT}${NC}"
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "(Make sure phone is on same WiFi network)"
echo "Press Ctrl+C to stop"
echo ""

cd "$EXPORT_DIR"

# Try different server options
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
elif command -v php &> /dev/null; then
    php -S 0.0.0.0:$PORT
elif command -v npx &> /dev/null; then
    npx serve -p $PORT
else
    echo "No web server found. Install Python 3 or Node.js"
    exit 1
fi
