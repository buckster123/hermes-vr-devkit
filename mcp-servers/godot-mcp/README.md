# Godot-MCP Server Helper

MCP server for live Godot editor manipulation.

## Quick Setup

```bash
# 1. Build server
git clone --depth 1 https://github.com/ee0pdt/Godot-MCP.git
cd Godot-MCP/server
npm install && npm run build

# 2. Deploy
mkdir -p ~/.local/share/godot-mcp
cp -r dist node_modules package.json ~/.local/share/godot-mcp/

# 3. Fix protocol for Godot 4.5
./fix-protocol.sh

# 4. Install addon in your project
cp -r Godot-MCP/addons/godot_mcp /path/to/project/addons/
```

## Hermes Config Snippet

```yaml
mcp_servers:
  godot:
    command: node
    args: [$HOME/.local/share/godot-mcp/dist/index.js]
    connect_timeout: 30
    timeout: 120
```

## Usage

1. Open Godot editor with your project
2. Project -> Project Settings -> Plugins -> enable Godot MCP
3. Restart Hermes (`/reload`)
4. Tools appear as `mcp_godot_*`

## Critical Fix

Godot 4.5's `WebSocketPeer` does not negotiate subprotocols. The upstream client sends `protocol: 'json'`, breaking the handshake.

Run `fix-protocol.sh` after every `npm run build`.
