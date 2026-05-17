# Hermes VR DevKit

A complete, battle-tested development stack for building native VR experiences on Meta Quest using Godot 4.5, Blender MCP, and Hermes Agent. Designed for AI-assisted workflows where your agent controls both the 3D asset pipeline (Blender) and the game engine (Godot) via MCP, then exports and deploys to Quest automatically.

```
Blender MCP → Asset Creation
      ↓
   gltfpack → Optimization
      ↓
Godot MCP → Scene Assembly + Code
      ↓
Headless Export → Signed APK
      ↓
   ADB → Quest Runtime
```

## What's In The Box

| Component | Purpose |
|-----------|---------|
| **5 Hermes Skills** | Generalized, upstream-ready SKILL.md files for godot-quest-dev, blender-godot-pipeline, xr-interactions, native-toolchain, and mcp-server-setup |
| **One-Shot Installer** | `install.sh` sets up the entire stack: Godot 4.5, Blender, Android SDK, MCP servers, debug keystore |
| **Starter Template** | Pre-configured Godot VR project with XR origin, locomotion, and export presets ready for Quest |
| **Build Scripts** | `build-and-run.sh` — export → sign → install → launch → logcat in one command |
| **MCP Server Helpers** | Config snippets, protocol patches, and addon installers for Godot-MCP and Blender-MCP |
| **Reference Docs** | Troubleshooting matrix, performance budgets, scene composition patterns |

## Target Platform

- **Headset**: Meta Quest 3 / 3S (Quest 2 compatible with performance notes)
- **Engine**: Godot 4.5-stable (4.6-preview features documented)
- **OS**: Ubuntu 22.04+ (primary), with notes for other Linux distros
- **Renderer**: Mobile (Vulkan), Forward+ unavailable on Quest

## Quick Start

### 1. Install Everything

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_ORG/hermes-vr-devkit/main/install.sh | bash
# Or clone and run locally:
git clone https://github.com/YOUR_ORG/hermes-vr-devkit.git
cd hermes-vr-devkit
./install.sh
```

This installs:
- Godot 4.5 + export templates
- Blender 4.3+ with MCP addon
- Android SDK, NDK, ADB, apksigner
- gltfpack, scrcpy
- OpenJDK 17
- Hermes MCP config snippets for Godot + Blender

### 2. Create a Project from Template

```bash
cp -r templates/godot-quest-vr ~/Projects/my-vr-app
cd ~/Projects/my-vr-app
# Open in Godot editor, or edit .tscn files directly (text format)
```

### 3. Connect MCP Servers in Hermes

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

Restart Hermes (`/reload` or relaunch). Your agent now has:
- **13 Godot MCP tools**: create/open scenes, add/delete nodes, set properties, attach scripts, save
- **22 Blender MCP tools**: create objects, apply materials, export GLB, viewport screenshots, Poly Haven assets

### 4. Build and Deploy

```bash
cd ~/Projects/my-vr-app
GODOT=$HOME/bin/godot ./templates/build-scripts/build-and-run.sh all
```

This runs the full pipeline: headless export → manual APK signing → ADB install → launch on Quest → filtered logcat.

## Skills Overview

| Skill | Trigger | Key Content |
|-------|---------|-------------|
| `godot-quest-dev` | Building, exporting, or debugging Godot VR projects for Quest | Headless export, manifest requirements, symptom→fix tables, Godot 4.5+ XR features |
| `blender-godot-pipeline` | Importing 3D assets into Godot VR projects | Blender MCP automation, GLB export constraints, gltfpack optimization, Godot import settings |
| `godot-xr-interactions` | Implementing player interactions in Godot VR | Teleport + snap-turn, physics grab, hand tracking, passthrough, XR UI on quads |
| `quest-native-toolchain` | Setting up or validating the Quest dev environment | Tool inventory, Android SDK setup, native C++ sample validation, ADB workflows |
| `mcp-server-setup` | Configuring Hermes MCP for Godot or Blender | Hermes config snippets, Godot-MCP WebSocket protocol fix, Blender addon install |

Install the skills into Hermes:

```bash
# Copy to Hermes skills directory
cp -r skills/* ~/.hermes/skills/software-development/
# Or reference them directly from the repo
```

## Key Design Decisions

- **Headless-first**: Godot 4.5's `--install-android-build-template` and `--export-release` enable fully automated CI/CD without GUI interaction
- **Manual signing**: Godot headless ignores keystore paths for OpenXR presets; we export unsigned then sign with `apksigner`
- **MCP-native**: Asset creation and scene assembly happen through MCP tools, not manual GUI clicking. The agent drives the pipeline.
- **Text-format scenes**: Godot `.tscn` files are plain text — agents can read and edit them directly when MCP is unavailable

## Verified Environment

| Component | Version | Status |
|-----------|---------|--------|
| Godot | 4.5-stable | Vulkan crash on Quest 3 FIXED (was broken in 4.4.1) |
| Meta OpenXR Vendors plugin | 4.3.1-stable | Compatible with 4.5 (v5.0.1 requires 4.6+) |
| Android API level | 29+ | Required for OpenXR |
| Renderer | Mobile | Forward+ unavailable on Quest |
| Target FPS | 72 (Q2) / 90 (Q3/3S) | Must maintain consistent |

## Troubleshooting

See `docs/troubleshooting.md` for the full symptom→fix matrix. Common issues:

| Symptom | Likely Fix |
|---------|-----------|
| App launches as 2D screen | Set Export Preset → Package → App Category to `Game` |
| Black screen in headset | Verify Mobile renderer, `use_xr = true`, OpenXR plugin enabled |
| `XR_ERROR_FORM_FACTOR_UNSUPPORTED` | Missing VR manifest entries or `libopenxr_loader.so` |
| Controller input not firing | Check OpenXR action map bindings in Project Settings |
| Blender glTF export fails | `sudo pip install numpy --break-system-packages` |
| Godot-MCP won't connect | Run `fix-protocol.sh` — Godot 4.5 doesn't negotiate WebSocket subprotocols |

## Performance Budgets (Quest 3)

| Metric | Target |
|--------|--------|
| Draw calls | < 100 per eye |
| Tris per frame | < 500k total |
| Texture memory | < 1GB |
| CPU/GPU time | < 11ms/frame (90Hz) |

Use `gltfpack -si 0.5` for distant objects. See `docs/performance-budgets.md`.

## Contributing

This stack is built for the Hermes Agent community. PRs welcome:
- Skill improvements and new reference docs
- Additional starter templates (AR passthrough, multiplayer, etc.)
- Install script portability (macOS, other distros)
- Godot 4.6+ compatibility updates

## License

MIT — matches all upstream dependencies (Blender-MCP, Godot-MCP, godot-xr-tools, etc.).

## Acknowledgments

- [Blender MCP](https://github.com/ahujasid/blender-mcp) by ahujasid — 22-tool Blender automation
- [Godot-MCP](https://github.com/ee0pdt/Godot-MCP) by ee0pdt — Live Godot editor control
- [godot-xr-tools](https://github.com/GodotVR/godot-xr-tools) by GodotVR — XR interaction library
- [Meta OpenXR Vendors](https://github.com/GodotVR/godot_openxr_vendors) by GodotVR — Official Quest loader plugin
- [meshoptimizer/gltfpack](https://github.com/zeux/meshoptimizer) by zeux — Mesh and texture optimization
