---
name: hermes-vr-devkit
description: Use the hermes-vr-devkit resource repo to set up a complete Godot 4.5 + Blender MCP + Meta Quest 3/3S VR development stack. Covers installation, project creation, MCP server configuration, and build/deploy workflows.
category: software-development
version: 1.0.0
author: Hermes VR DevKit
license: MIT
metadata:
  hermes:
    tags: [vr, quest, godot, blender, mcp, devkit, setup]
    related_skills: [godot-quest-dev, blender-godot-pipeline, godot-xr-interactions, quest-native-toolchain, mcp-server-setup]
---

# Hermes VR DevKit

The fastest path from zero to a running VR app on Meta Quest using AI-driven development.

## When to Use

- Setting up a new machine for Quest VR development
- Starting a new Godot VR project
- Connecting Blender and Godot MCP servers to Hermes
- Building and deploying an APK to Quest
- Troubleshooting the dev stack

## Quick Start

### 1. Install Everything

```bash
curl -sSL https://raw.githubusercontent.com/buckster123/hermes-vr-devkit/main/install.sh | bash
```

Or clone and run locally:
```bash
git clone https://github.com/buckster123/hermes-vr-devkit.git
cd hermes-vr-devkit
./install.sh
```

### 2. Create a Project

```bash
cp -r hermes-vr-devkit/templates/godot-quest-vr ~/Projects/my-vr-app
cd ~/Projects/my-vr-app
```

Templates available:
- `godot-quest-vr` -- Standard VR with teleport locomotion
- `godot-quest-ar` -- AR passthrough (mixed reality)
- `godot-quest-handtracking` -- Hand tracking only (no controllers)

### 3. Configure Hermes MCP

Add to `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  godot:
    command: node
    args: [$HOME/.local/share/godot-mcp/dist/index.js]
    connect_timeout: 30
    timeout: 120
  blender:
    command: uvx
    args: [blender-mcp]
```

Restart Hermes (`/reload`).

### 4. Build and Deploy

```bash
cd ~/Projects/my-vr-app
GODOT=$HOME/bin/godot hermes-vr-devkit/templates/build-scripts/build-and-run.sh all
```

## Repository Layout

```
hermes-vr-devkit/
├── install.sh              # Full stack installer
├── install-minimal.sh      # Godot + Android SDK only
├── install-mcp.sh          # MCP servers only
├── skills/                 # 5 Hermes skills
│   ├── godot-quest-dev/
│   ├── blender-godot-pipeline/
│   ├── godot-xr-interactions/
│   ├── quest-native-toolchain/
│   └── mcp-server-setup/
├── templates/              # Starter projects
│   ├── godot-quest-vr/
│   ├── godot-quest-ar/
│   └── godot-quest-handtracking/
├── mcp-servers/            # MCP helpers
│   ├── godot-mcp/
│   └── blender-mcp/
└── docs/                   # Reference docs
    ├── troubleshooting.md
    ├── performance-budgets.md
    └── scene-composition-patterns.md
```

## Workflow: AI-Driven VR Development

1. **Plan** -- Write the plan to a file before touching Blender or Godot
2. **Asset Creation** -- Use Blender MCP to create/modify 3D assets
3. **Export** -- Export GLB from Blender, optimize with gltfpack
4. **Scene Assembly** -- Use Godot MCP to import assets, create nodes, set properties
5. **Code** -- Attach GDScript for interactions (locomotion, grab, UI)
6. **Export APK** -- Headless Godot export → manual sign with apksigner
7. **Deploy** -- ADB install and launch on Quest
8. **Debug** -- Filtered logcat streaming

## One-Command Workflows

```bash
# Full pipeline (export + sign + install + launch + logs)
./build-and-run.sh all

# Just build
./build-and-run.sh build

# Install existing APK
./build-and-run.sh install

# Stream logs only
./build-and-run.sh logs
```

## Critical Fixes (Apply Once)

### Godot-MCP WebSocket Protocol

Godot 4.5 doesn't negotiate subprotocols. Run after every `npm run build`:

```bash
./mcp-servers/godot-mcp/fix-protocol.sh
```

### Meta OpenXR Vendors Plugin Extraction

The zip has an `asset/` prefix:

```bash
unzip -q godotopenxrvendorsaddon.zip
mv asset/addons ./
rm -rf asset
```

## Verification Checklist

After installation:
- [ ] `hermes mcp test godot` shows "Connected"
- [ ] `hermes mcp test blender` shows "Connected"
- [ ] `adb devices` shows Quest in dev mode
- [ ] `godot --version` shows 4.5-stable
- [ ] `apksigner --version` works
- [ ] `gltfpack -v` works

After first export:
- [ ] APK > 5MB
- [ ] `apksigner verify` passes
- [ ] Manifest contains `com.oculus.intent.category.VR`
- [ ] App launches in immersive VR (not 2D)

## References

- Full repo: https://github.com/buckster123/hermes-vr-devkit
- Upstream PR: https://github.com/NousResearch/hermes-agent/pull/27388
- Blender MCP: https://github.com/ahujasid/blender-mcp
- Godot-MCP: https://github.com/ee0pdt/Godot-MCP
