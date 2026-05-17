#!/bin/bash
# Hermes VR DevKit -- MCP Server Installer
# Installs: Godot-MCP server + Blender-MCP addon
# Assumes Godot and Blender are already installed.

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[vr-devkit]${NC} $*"; }

read -rp "Install MCP servers for Godot and Blender? [Y/n] " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && exit 0

# Godot-MCP
log "Installing Godot-MCP server..."
GODOT_MCP_DIR="$HOME/.local/share/godot-mcp"
if [ ! -d "$GODOT_MCP_DIR/dist" ]; then
  cd /tmp
  git clone --depth 1 https://github.com/ee0pdt/Godot-MCP.git
  cd Godot-MCP/server
  npm install && npm run build
  mkdir -p "$GODOT_MCP_DIR"
  cp -r dist node_modules package.json "$GODOT_MCP_DIR/"
  cd /tmp && rm -rf Godot-MCP
fi

# Apply protocol fix
if [ -f "$GODOT_MCP_DIR/dist/utils/godot_connection.js" ]; then
  sed -i "/protocol: 'json',/d" "$GODOT_MCP_DIR/dist/utils/godot_connection.js"
  log "Applied Godot 4.5 WebSocket protocol fix"
fi

# Blender MCP addon
log "Installing Blender MCP addon..."
BLENDER_VERSION="${BLENDER_VERSION:-4.3}"
BLENDER_ADDON_DIR="$HOME/.config/blender/$BLENDER_VERSION/scripts/addons"
mkdir -p "$BLENDER_ADDON_DIR"
if [ ! -f "$BLENDER_ADDON_DIR/addon.py" ]; then
  cd /tmp
  wget -q "https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py"
  cp addon.py "$BLENDER_ADDON_DIR/"
  rm -f addon.py
fi

# Config snippet
mkdir -p "$HOME/.local/share"
cat > "$HOME/.local/share/hermes-vr-devkit-mcp-config.yaml" <<EOF
# Add this to your ~/.hermes/config.yaml under mcp_servers:
  godot:
    command: node
    args: [$HOME/.local/share/godot-mcp/dist/index.js]
    connect_timeout: 30
    timeout: 120
  blender:
    command: uvx
    args: [blender-mcp]
EOF

log "MCP servers installed!"
echo "Add the config to ~/.hermes/config.yaml and restart Hermes."
