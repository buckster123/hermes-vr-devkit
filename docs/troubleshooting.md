# Troubleshooting Matrix

Symptom-to-fix lookup for common Quest VR development issues.

## App Launches as 2D Screen (Flat Panel)

| Check | Command | Expected |
|-------|---------|----------|
| App Category | Export Preset -> Package -> App Category | `Game` (NOT Accessibility) |
| Manifest VR category | `aapt dump xmltree app.apk AndroidManifest.xml \| grep VR` | `com.oculus.intent.category.VR` |
| Manifest focusaware | `aapt dump xmltree app.apk AndroidManifest.xml \| grep focusaware` | `com.oculus.vr.focusaware` |
| Manifest headtracking | `aapt dump xmltree app.apk AndroidManifest.xml \| grep headtracking` | `android.hardware.vr.headtracking` |
| Logcat isVrApplication | `adb logcat -d \| grep isVrApplication` | `true` |

**Fix:** Set App Category to `Game` in export preset, re-export, reinstall.

## Black Screen in Headset

| Check | Fix |
|-------|-----|
| `use_xr = true` on viewport | Add to `_ready()`: `get_viewport().use_xr = true` |
| Renderer is Mobile | Project Settings -> Rendering -> Renderer -> Mobile |
| OpenXR initialized | `adb logcat -s godot` for "OpenXR initialized" |
| Shader compilation | `adb logcat -s godot` for shader errors |
| Sky dome opaque | Remove dome or assign transparent material |

## `XR_ERROR_FORM_FACTOR_UNSUPPORTED`

| Cause | Fix |
|-------|-----|
| Missing `libopenxr_loader.so` | Enable Meta OpenXR Vendors plugin |
| Missing headtracking feature | Verify manifest has `android.hardware.vr.headtracking` |
| Missing VR intent category | Verify manifest has `com.oculus.intent.category.VR` |
| `isGame="false"` | Set App Category to `Game` |

## Controller Input Not Firing

| Check | Fix |
|-------|-----|
| OpenXR action map | Project Settings -> XR -> OpenXR -> Action Map |
| Controller tracker names | Left=`left_hand`, Right=`right_hand` |
| Button names | `trigger_click`, `grip_click`, `primary` (Vector2) |

## Frame Drops / Stuttering

| Check | Fix |
|-------|-----|
| Draw calls | `adb logcat -s VrApi \| grep FPS` |
| Too many objects | Merge meshes, use MultiMeshInstance3D |
| Complex shaders | Simplify, avoid transparency overdraw |
| Foveated rendering | Enable in vendor plugin settings |

## Godot-MCP Issues

| Symptom | Fix |
|---------|-----|
| "socket hang up" | Run `fix-protocol.sh` to remove `protocol: 'json'` |
| Tools not appearing | Restart Hermes with `/reload` |
| Stale data | `kill $(pgrep -f "godot-mcp/dist/index.js")` |
| Changes not persisting | Call `save_scene` after modifications |
| `execute_editor_script` no data | Use `get_node_properties` or write to temp file |

## Blender-MCP Issues

| Symptom | Fix |
|---------|-----|
| Addon greyed out | Restart Blender |
| `No module named 'numpy'` | `sudo pip install numpy --break-system-packages` |
| glTF export fails | Same as above |
| Connection refused | Click "Connect to Claude" in sidebar |

## Build / Export Issues

| Symptom | Fix |
|---------|-----|
| "Android build template not installed" | Run `--install-android-build-template` |
| "OpenXR requires Use Gradle Build" | Set `gradle_build/use_gradle_build=true` |
| Export ignores keystore | Set `package/signed=false`, sign manually with `apksigner` |
| Export templates not found | Move files from `templates/` subdir up one level |
| APK install fails | `adb uninstall com.yourcompany.yourapp` then reinstall |
| Missing `icon.svg` | Create minimal SVG in project root |
