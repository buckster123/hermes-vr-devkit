# Scene Composition Patterns for VR

Reusable patterns for organizing Godot VR scenes.

## Player Rig Pattern

```
Player (Node3D)
└── XROrigin3D                    <- Move THIS for locomotion
    ├── XRCamera3D                <- Head tracking (never move directly)
    ├── XRController3D (Left)
    │   └── OpenXRRenderModel     <- Platform-native controller mesh
    ├── XRController3D (Right)
    │   └── OpenXRRenderModel
    └── Locomotion (Node3D + script)
```

**Rule:** Move `XROrigin3D`, never the camera. The camera is driven by headset tracking.

## Room / Environment Pattern

```
Room (Node3D)
├── Visuals
│   ├── Walls (MeshInstance3D)
│   ├── Floor (MeshInstance3D)
│   └── Ceiling (MeshInstance3D)
├── Collision
│   └── StaticBody3D + CollisionShape3D
├── Lighting
│   ├── OmniLight3D
│   └── WorldEnvironment
└── Interactive
    ├── GrabbableObjects (Node3D)
    └── Buttons (Area3D)
```

**Rule:** One scene = one responsibility. If you can't name it in two words, split it.

## Concentric Ring Layout (Memory Palace / Exhibition)

```
Center (Node3D)                  <- Focal point, highest detail
└── ...

Ring1 (Node3D)                   <- 2-5m radius, mid detail
└── Artifact1, Artifact2, ...

Ring2 (Node3D)                   <- 5-10m radius, low detail / impostors
└── ...

Colonnade/Portal (Node3D)        <- Framing structure
└── ArchMesh, PillarMesh, ...
```

**Rule:** Detail decreases with distance. Use LOD or impostors for outer rings.

## Interactive Object Pattern

```
GrabbableObject (RigidBody3D)
├── MeshInstance3D              <- Visual mesh
├── CollisionShape3D            <- Physics collision
└── GrabPoint (Marker3D)        <- Optional: precise grab offset
```

Enable `freeze = true` on grab, restore on release. Apply controller velocity on release for throw physics.

## XR UI Pattern

```
UIAnchor (Node3D)                <- Positioned at comfortable distance
└── UIQuad (MeshInstance3D)     <- Displays SubViewport texture
│   └── QuadMesh + StandardMaterial3D (unshaded)
└── SubViewport                 <- Contains Control nodes
    └── ... Button, Label, etc.
```

**Placement rules:**
- Distance: 1.0-2.0m (1.5m sweet spot)
- Minimum text: 50px at 1m (subtends ~1deg visual arc)
- Critical content: within 30deg of center gaze
- Curved panels: for wide surfaces >0.6m at viewing distance
- Never closer than 0.5m (vergence-accommodation conflict)

## WorldEnvironment Setup for VR

```gdscript
var env := Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0.05, 0.05, 0.1)
env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
env.ambient_light_color = Color(0.2, 0.2, 0.3)
env.ambient_light_energy = 0.5
# No SSAO -- Mobile renderer does not support it
$WorldEnvironment.environment = env
```
