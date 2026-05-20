# Audit and Verification Plan

This repository aims to automate a large VR development stack. That is useful,
but it also means the installer and MCP setup should be reviewed carefully.

## Static Review Checklist

Before running installer scripts on a primary workstation:

- Read `install.sh`, `install-minimal.sh`, `install-mcp.sh`, and scripts under
  `templates/build-scripts/`.
- Check every command using `sudo`.
- Check every download URL and confirm the upstream project is expected.
- Check any `rm -rf` usage and ensure it is scoped to a known temp directory.
- Check shell startup modifications, environment variables, and PATH changes.
- Confirm no script requires a GitHub token or cloud secret.

## First Safe Test

Prefer a disposable VM, container, or secondary Linux machine for the first full
installer test. If using a normal workstation, run the minimal path first:

```bash
git clone https://github.com/buckster123/hermes-vr-devkit.git
cd hermes-vr-devkit
less install-minimal.sh
./install-minimal.sh
```

Then verify expected tools without opening private projects:

```bash
godot --version || $HOME/bin/godot --version
adb version
java -version
```

## Godot Template Smoke Test

A first non-headset validation should prove the template loads headlessly before
attempting Quest deployment:

```bash
cd templates/godot-quest-vr
$HOME/bin/godot --headless --path . --quit-after 1
```

If export templates are installed, test an unsigned headless export and document
any missing SDK/template errors.

## Quest Hardware Verification

When a Quest device is available:

1. Enable developer mode on the headset.
2. Verify `adb devices` shows the device.
3. Build a debug APK from the template.
4. Install with `adb install -r`.
5. Launch from the headset UI.
6. Capture filtered logcat and note headset model, Godot version, plugin version,
   and Android SDK/NDK versions.

## MCP Verification

For Godot-MCP and Blender-MCP, verify both connection and data retrieval:

- Godot editor addon installed and enabled.
- MCP server starts without unresolved dependencies.
- Hermes config points to the built server path.
- Godot-MCP scene creation/save works.
- Data retrieval uses supported tools rather than assuming an editor script
  returns structured output.

## Documentation Standard

When a workflow passes, record:

- Host OS and version.
- Godot version.
- Blender version, if relevant.
- Quest model, if hardware was used.
- Exact commands run.
- Exact files generated.
- Any warnings that appeared but were harmless.
