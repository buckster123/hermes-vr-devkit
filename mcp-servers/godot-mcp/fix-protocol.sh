#!/bin/bash
# Fix Godot-MCP WebSocket protocol handshake for Godot 4.5
# Godot's WebSocketPeer does not negotiate subprotocols, so 'protocol: json' breaks the handshake
# Run this after any 'npm run build' to re-apply the fix

set -e

SERVER_DIR="${1:-$HOME/.local/share/godot-mcp}"

if [ ! -f "$SERVER_DIR/dist/utils/godot_connection.js" ]; then
    echo "Error: godot_connection.js not found at $SERVER_DIR/dist/utils/"
    echo "Usage: $0 [path/to/server/dist]"
    exit 1
fi

# Remove the protocol option from compiled JS
sed -i "/protocol: 'json',/d" "$SERVER_DIR/dist/utils/godot_connection.js"
echo "Patched: $SERVER_DIR/dist/utils/godot_connection.js"

# Also patch source if available
SRC="$SERVER_DIR/../Godot-MCP/server/src/utils/godot_connection.ts"
if [ -f "$SRC" ]; then
    sed -i "/protocol: 'json',/d" "$SRC"
    echo "Patched source: $SRC"
fi

echo "Protocol fix applied. Restart Hermes MCP to pick up changes."
