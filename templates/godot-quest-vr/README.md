# Godot Quest VR Starter Template

Pre-configured Godot 4.5 project for Meta Quest 3/3S VR development.

## What's Included

- `project.godot` -- Mobile renderer, OpenXR enabled, VSync disabled
- `export_presets.cfg` -- Android Quest preset with OpenXR, arm64, API 29
- `scenes/main.tscn` -- World environment, ground plane, directional light, player instance
- `scenes/player.tscn` -- XROrigin3D, XRCamera3D, left/right XRController3D, locomotion
- `scenes/locomotion.gd` -- Teleport + snap-turn locomotion on right controller
- `icon.svg` -- Minimal project icon
- `.gitignore` -- Excludes `.godot/`, APKs, blend backups

## Setup

1. Open this project in Godot 4.5
2. Project -> Install Android Build Template...
3. Download Meta OpenXR Vendors plugin 4.3.1 and extract to `addons/`
4. Project -> Project Settings -> Plugins -> enable `godotopenxrvendors`
5. Connect Quest via USB, enable Developer Mode
6. Run `./build-and-run.sh all` (from the hermes-vr-devkit templates)

## Scene Structure

```
Main (Node3D)
├── WorldEnvironment
├── Player (Node3D)
│   └── XROrigin3D
│       ├── XRCamera3D
│       ├── LeftController (XRController3D)
│       └── RightController (XRController3D)
│           └── Locomotion (Node3D + script)
│               ├── TeleportRay (RayCast3D)
│               └── TeleportMarker (MeshInstance3D)
├── Ground (StaticBody3D)
│   ├── CollisionShape3D
│   └── MeshInstance3D
└── DirectionalLight3D
```

## Controls

| Action | Input |
|--------|-------|
| Teleport | Hold right trigger, aim at ground, release |
| Snap Turn | Right thumbstick left/right (45deg) |

## Next Steps

- Add grabbable objects: `XRController3D` + `Area3D` + physics grab script
- Add XR UI: `SubViewport` + quad mesh + pointer interaction
- Enable passthrough: `environment_blend_mode = XR_ENVIRONMENT_BLEND_MODE_ALPHA_BLEND`
- Optimize assets: `gltfpack -tc -si 0.8` before importing
