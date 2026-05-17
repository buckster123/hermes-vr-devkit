# Blender-MCP Server Helper

MCP server for AI-driven Blender automation.

## Quick Setup

```bash
# Server (via uv)
uvx blender-mcp

# Addon
mkdir -p ~/.config/blender/4.3/scripts/addons
cp /path/to/blender-mcp/addon.py ~/.config/blender/4.3/scripts/addons/
```

In Blender: Edit -> Preferences -> Add-ons -> Install -> select addon.py -> Enable "Interface: Blender MCP"

In 3D View sidebar (N): click "Connect to Claude"

## Hermes Config Snippet

```yaml
mcp_servers:
  blender:
    command: uvx
    args: [blender-mcp]
```

## Capabilities

- Scene inspection, object creation/deletion
- Material control, lighting setup
- Python execution in Blender context
- Poly Haven asset download
- Hyper3D Rodin 3D generation
- Viewport screenshots
- GLB export
