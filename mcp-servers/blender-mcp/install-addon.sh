#!/bin/bash
# Install Blender MCP addon

BLENDER_VERSION="${BLENDER_VERSION:-4.3}"
ADDON_DIR="$HOME/.config/blender/$BLENDER_VERSION/scripts/addons"

mkdir -p "$ADDON_DIR"

if [ -f "$ADDON_DIR/addon.py" ]; then
    echo "Addon already installed at $ADDON_DIR/addon.py"
    exit 0
fi

# Download from upstream
cd /tmp
wget -q "https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py"
cp addon.py "$ADDON_DIR/"
rm -f addon.py

echo "Installed Blender MCP addon to $ADDON_DIR/addon.py"
echo "In Blender: Edit -> Preferences -> Add-ons -> Enable 'Interface: Blender MCP'"
echo "In 3D View sidebar (N): click 'Connect to Claude'"
