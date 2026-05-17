# Upstream PR Notes

## Target Repository

`https://github.com/NousResearch/hermes-agent`

Branch: `main`
Destination: `skills/software-development/`

## Skills to PR

| Skill | File | Description |
|-------|------|-------------|
| `godot-quest-dev` | `skills/software-development/godot-quest-dev/SKILL.md` | Master skill for Quest VR development with Godot 4.5 |
| `blender-godot-pipeline` | `skills/software-development/blender-godot-pipeline/SKILL.md` | Asset pipeline from Blender MCP to Godot |
| `godot-xr-interactions` | `skills/software-development/godot-xr-interactions/SKILL.md` | VR interaction patterns (locomotion, grab, UI) |
| `quest-native-toolchain` | `skills/software-development/quest-native-toolchain/SKILL.md` | Toolchain installation and validation |
| `mcp-server-setup` | `skills/software-development/mcp-server-setup/SKILL.md` | Hermes MCP configuration for Godot + Blender |

## PR Checklist

- [ ] All skills pass frontmatter validation (name, description <= 1024 chars, starts at byte 0 with `---`)
- [ ] All skills <= 15k chars (references split out)
- [ ] All descriptions start with "Use when..."
- [ ] All `related_skills` reference in-repo skills only
- [ ] No user-specific paths or project codenames
- [ ] All GDScript syntax is valid
- [ ] All shell commands are tested
- [ ] License is MIT in all files

## PR Description Template

```
Add Godot + Blender + Quest VR development skill suite (5 skills)

This PR adds a complete skill set for AI-assisted VR development on Meta Quest
using Godot 4.5 and Blender MCP under Hermes Agent.

Skills included:
- godot-quest-dev: Master guide for export, manifest, debugging, XR features
- blender-godot-pipeline: Asset pipeline from Blender MCP through gltfpack to Godot
- godot-xr-interactions: Locomotion, grabbing, hand tracking, passthrough, XR UI
- quest-native-toolchain: Toolchain install, native validation, ADB workflows
- mcp-server-setup: Hermes MCP config, protocol fixes, troubleshooting

All skills are:
- Project-agnostic (no hardcoded paths or codenames)
- Tested on Ubuntu 22.04+ with Godot 4.5-stable
- Compatible with Meta Quest 3/3S
- Licensed MIT

Reference files (12 total) are split out from SKILL.md to keep skills under
the 15k char target while preserving deep technical content.
```

## Notable Technical Findings

1. **Godot-MCP WebSocket protocol fix**: Godot 4.5's WebSocketPeer doesn't negotiate subprotocols. The upstream client sends `protocol: 'json'` which breaks the handshake. We provide a `fix-protocol.sh` script.

2. **Meta OpenXR Vendors plugin zip extraction**: The plugin zip has an `asset/` prefix. Standard unzip places addons at wrong depth. Extraction pattern: `unzip -q zip; mv asset/addons .; rm -rf asset`.

3. **Godot headless export ignores keystore**: For OpenXR presets, Godot headless ignores keystore paths. Must export unsigned (`package/signed=false`) then sign manually with `apksigner`.

4. **App Category dropdown overrides manifest**: The export preset's "App Category" dropdown (defaulting to `Accessibility`) overrides any manual manifest patches. Must be set to `Game` for Quest immersive mode.

## Testing Performed

- Godot 4.5-stable headless export on Ubuntu 25.10
- APK signing with apksigner
- ADB install and launch on Meta Quest 3
- OpenXR initialization and Vulkan rendering validated
- Godot-MCP connection and tool discovery verified
- Blender-MCP addon installation and connection verified

## Related

- Meta Quest Agentic Tools: https://github.com/meta-quest/agentic-tools
- Blender MCP: https://github.com/ahujasid/blender-mcp
- Godot-MCP: https://github.com/ee0pdt/Godot-MCP
- godot-xr-tools: https://github.com/GodotVR/godot-xr-tools
