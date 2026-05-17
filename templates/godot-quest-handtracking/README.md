# Quest Hand Tracking Starter

Godot 4.5 starter template for Meta Quest hand tracking without controllers.

## Setup

1. Open the project in Godot 4.5 or later.
2. Install the Android export templates.
3. Set a unique package name in `export_presets.cfg`.
4. Export using the **Android Quest Hand** preset.

## Scene Layout

- `main.tscn` — Root scene with WorldEnvironment, ground plane, directional light, and the player.
- `player.tscn` — XROrigin3D with XRCamera3D and left/right `XRNode3D` hand trackers. Each hand has a sphere visualizer.
- `hand_tracking.gd` — Detects pinch gestures by measuring the distance between thumb-tip and index-finger-tip joints, and changes hand visualizer color on pinch.

## Key Settings

- `xr_features/hand_tracking=2` (Required) in the Android export preset.
- `xr_features/hand_tracking_frequency=1` (High) for responsive tracking.
- `XRNode3D` nodes with `tracker = &"left_hand"` / `&"right_hand"` drive hand position and orientation.
- `XRHandTracker` is queried at runtime for joint positions.

## How It Works

- `hand_tracking.gd` uses `XRServer.get_tracker()` to retrieve the active `XRHandTracker` for each hand.
- It reads `HAND_JOINT_THUMB_TIP` and `HAND_JOINT_INDEX_FINGER_TIP` positions.
- If the distance between them drops below `PINCH_THRESHOLD`, the pinch state becomes true.
- The sphere visualizer on each hand changes from red (idle) to green (pinched).

## Extending

- Replace the sphere visualizers with rigged hand models driven by `XRHandModifier3D` for full skeletal hand visualization.
- Map pinch events to grab, spawn, or UI selection logic.
