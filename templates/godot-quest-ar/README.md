# Quest AR Passthrough Starter

Godot 4.5 starter template for Meta Quest AR passthrough mixed reality.

## Setup

1. Open the project in Godot 4.5 or later.
2. Install the Android export templates.
3. Set a unique package name in `export_presets.cfg`.
4. Export using the **Android Quest AR** preset.

## Scene Layout

- `main.tscn` — Root scene with WorldEnvironment (transparent background), a platform, a floating cube, and the passthrough script.
- `player.tscn` — XROrigin3D with XRCamera3D and left/right XRController3D nodes.
- `passthrough.gd` — Enables OpenXR alpha_blend passthrough mode and makes the viewport transparent.

## Key Settings

- `xr_features/passthrough=1` in the Android export preset.
- Environment `background_mode = 3` (Canvas) in `main.tscn`.
- `get_viewport().transparent_bg = true` is set at runtime by `passthrough.gd`.
- `XRInterface.set_environment_blend_mode(XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND)` activates alpha blending.

## Notes

- The ground plane is removed so the real world shows through.
- 3D objects are placed in front of the user for mixed-reality interaction.
- Controller input works normally over the passthrough view.
