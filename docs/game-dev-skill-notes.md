# Game Development Skill Notes for Hermes Agent

These notes summarize patterns that have worked well in Hermes-assisted Godot
prototype work. They are intentionally project-agnostic so they can strengthen
VR, flat-screen, and hybrid Godot workflows.

## Playable-First Scope

For early prototypes, build a tiny playable loop before expanding content:

- One main scene.
- One player controller.
- One objective or win/loss condition.
- On-screen controls and status text.
- A hard quit shortcut such as `Q` or `Esc`.
- A restart path such as `R` after win/loss.

This keeps the project testable and prevents the agent from spending too long on
art, menus, or packaging before the core loop exists.

## Headless Proof Harnesses

Every serious Godot prototype should have a script-based smoke test that can run
without manual editor interaction. Good smoke tests:

- Load the main scene as a `PackedScene`.
- Instantiate it.
- Call a small debug API on the root node.
- Exercise one or two important gameplay transitions.
- Print clear `PASS` / `FAIL` messages.
- Call `quit(0)` explicitly when done.

Example APIs that make prototypes easier for agents to test:

```gdscript
func start_game() -> void: pass
func restart() -> void: pass
func get_debug_state() -> Dictionary: return {}
```

For VR templates, the same idea applies even if headset-only features cannot be
fully validated headlessly. The test can still prove scenes load, required nodes
exist, scripts parse, and export presets are present.

## Determinism Beats Hope

Avoid smoke tests that depend on random gameplay outcomes. Instead:

- Spawn test entities directly through debug methods.
- Choose deterministic upgrade options.
- Put test pickups far enough away that automatic collection does not race the
  assertion.
- Assert on simple state dictionaries rather than rendered pixels.

## Scene and Script Hygiene

Hermes and other agents work best when Godot projects stay text-friendly:

- Prefer `.tscn` and `.tres` text resources where practical.
- Keep gameplay scripts short and named by system.
- Put automation scripts under `tools/`.
- Put design notes under `docs/`.
- Keep generated logs ignored by Git, but preserve empty log directories with
  `.gitkeep` if needed.

## Prototype Documentation

A useful prototype README should include:

- What the prototype currently proves.
- Controls.
- Requirements.
- Run command.
- Smoke-test command.
- Known limitations.
- Next layers to build.

For VR projects, also include headset model, Godot version, renderer, OpenXR
plugin version, Android SDK/NDK versions, and whether deployment was actually
verified on hardware.

## Legal and Asset Safety

When using existing games as inspiration, extract neutral mechanics only:

- Camera feel.
- Readable UI structure.
- Progression pacing.
- Enemy/tower/weapon role categories.
- Level readability.

Do not copy proprietary characters, names, exact layouts, music, dialogue,
logos, store-page language, or commercial sprite sheets.
