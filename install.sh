#!/bin/bash
# Hermes VR DevKit -- Full Stack Installer
# Installs: Godot 4.5, Blender 4.3+, Android SDK, MCP servers, debug keystore
# Target: Ubuntu 22.04+ / 25.10
# Run: curl -sSL .../install.sh | bash
# Or: ./install.sh

set -euo pipefail

GODOT_VERSION="4.5-stable"
BLENDER_VERSION="4.3"
ANDROID_API="33"
ANDROID_BUILD_TOOLS="34.0.0"
ANDROID_NDK="25.2.9519653"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[vr-devkit]${NC} $*"; }
warn() { echo -e "${YELLOW}[vr-devkit]${NC} $*"; }
err() { echo -e "${RED}[vr-devkit]${NC} $*"; }

# Detect Blender version from installed binary
BLENDER_VERSION="${BLENDER_VERSION:-$(blender --version 2>/dev/null | head -1 | grep -oP 'Blender \K[0-9]+\.[0-9]+' || echo "4.3")}"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) GODOT_ARCH="linux.x86_64" ;;
  aarch64) GODOT_ARCH="linux.arm64" ;;
  *) err "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Check Ubuntu version
if ! grep -qE "Ubuntu (22\.04|24\.04|25\.)" /etc/os-release 2>/dev/null; then
  warn "This installer is tested on Ubuntu 22.04+, 24.04, 25.10. Your OS may vary."
fi

# Ask for install confirmation
echo "Hermes VR DevKit Full Stack Installer"
echo "======================================"
echo "This will install:"
echo "  - Godot $GODOT_VERSION + export templates"
echo "  - Android SDK, NDK, build tools"
echo "  - OpenJDK 17, ADB, apksigner, scrcpy, gltfpack"
echo "  - Blender $BLENDER_VERSION with MCP addon"
echo "  - Godot-MCP and Blender-MCP servers"
echo "  - Debug keystore for APK signing"
echo ""
read -rp "Continue? [Y/n] " CONFIRM
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  log "Aborted."
  exit 0
fi

# 1. System packages
log "Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
  openjdk-17-jdk \
  adb \
  apksigner \
  scrcpy \
  gltfpack \
  git-lfs \
  unzip \
  wget \
  curl \
  nodejs \
  npm \
  blender \
  python3-pip \
  python3-numpy \
  || { err "Failed to install system packages"; exit 1; }

# Install uv if not present
if ! command -v uv >/dev/null 2>&1; then
  log "Installing uv (Python package manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 2. Android SDK
log "Installing Android SDK..."
ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
mkdir -p "$ANDROID_HOME/cmdline-tools"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
  cd /tmp
  wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
  unzip -q commandlinetools-linux-11076708_latest.zip
  mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  rm -f commandlinetools-linux-11076708_latest.zip
fi

export ANDROID_HOME
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "build-tools;$ANDROID_BUILD_TOOLS" "platforms;android-$ANDROID_API" "ndk;$ANDROID_NDK"

# 3. Godot
log "Installing Godot $GODOT_VERSION..."
GODOT_BIN="$HOME/bin/godot"
mkdir -p "$HOME/bin"

if [ ! -f "$GODOT_BIN" ]; then
  cd /tmp
  wget -q "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
  unzip -q "Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
  mv "Godot_v$GODOT_VERSION_$GODOT_ARCH" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -f "Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
fi

# Export templates
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/$GODOT_VERSION"
if [ ! -d "$TEMPLATE_DIR" ]; then
  cd /tmp
  wget -q "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v$GODOT_VERSION_export_templates.tpz"
  mkdir -p "$TEMPLATE_DIR"
  unzip -q "Godot_v$GODOT_VERSION_export_templates.tpz" -d "$TEMPLATE_DIR"
  # tpz extracts into "templates/" subdir -- move up one level
  if [ -d "$TEMPLATE_DIR/templates" ]; then
    mv "$TEMPLATE_DIR/templates"/* "$TEMPLATE_DIR/" 2>/dev/null || true
    rmdir "$TEMPLATE_DIR/templates" 2>/dev/null || true
  fi
  rm -f "Godot_v$GODOT_VERSION_export_templates.tpz"
fi

# 4. Debug keystore
log "Creating debug keystore..."
KEYSTORE="$HOME/.android/debug.keystore"
mkdir -p "$HOME/.android"
if [ ! -f "$KEYSTORE" ]; then
  keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android \
    -keystore "$KEYSTORE" -storepass android \
    -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12 \
    2>/dev/null || { err "Failed to create debug keystore. Is keytool installed?"; exit 1; }
fi

# 5. Godot editor settings
log "Configuring Godot editor settings..."
GODOT_CONFIG="$HOME/.config/godot/editor_settings-4.5.tres"
mkdir -p "$HOME/.config/godot"
cat > "$GODOT_CONFIG" <<EOF
[resource]
export/android/android_sdk_path = "$ANDROID_HOME"
export/android/java_sdk_path = "/usr/lib/jvm/java-17-openjdk-amd64"
export/android/debug_keystore = "$KEYSTORE"
export/android/debug_keystore_pass = "android"
EOF

# 6. Blender MCP addon
log "Installing Blender MCP addon..."
BLENDER_ADDON_DIR="$HOME/.config/blender/$BLENDER_VERSION/scripts/addons"
mkdir -p "$BLENDER_ADDON_DIR"

if [ ! -f "$BLENDER_ADDON_DIR/addon.py" ]; then
  cd /tmp
  wget -q "https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py"
  cp addon.py "$BLENDER_ADDON_DIR/"
  rm -f addon.py
fi

# 7. Godot-MCP server
log "Installing Godot-MCP server..."
GODOT_MCP_DIR="$HOME/.local/share/godot-mcp"
if [ ! -d "$GODOT_MCP_DIR/dist" ]; then
  cd /tmp
  git clone --depth 1 https://github.com/ee0pdt/Godot-MCP.git
  cd Godot-MCP/server
  npm install && npm run build || { err "Failed to build Godot-MCP server. Is Node.js installed?"; exit 1; }
  mkdir -p "$GODOT_MCP_DIR"
  cp -r dist node_modules package.json "$GODOT_MCP_DIR/"
  cd /tmp && rm -rf Godot-MCP
fi

# Apply protocol fix for Godot 4.5
if [ -f "$GODOT_MCP_DIR/dist/utils/godot_connection.js" ]; then
  sed -i "/protocol: 'json',/d" "$GODOT_MCP_DIR/dist/utils/godot_connection.js"
  log "Applied Godot 4.5 WebSocket protocol fix"
fi

# 8. Hermes MCP config snippet
log "Generating Hermes MCP config snippet..."
cat > "$HOME/.local/share/hermes-vr-devkit-mcp-config.yaml" <<EOF
# Add this to your ~/.hermes/config.yaml under mcp_servers:
  godot:
    command: node
    args: [$HOME/.local/share/godot-mcp/dist/index.js]
    connect_timeout: 30
    timeout: 120
  blender:
    command: uvx
    args: [blender-mcp]
EOF

# 9. Environment exports
log "Adding environment variables to shell profile..."
SHELL_RC="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"; fi

if ! grep -q "ANDROID_HOME" "$SHELL_RC"; then
  cat >> "$SHELL_RC" <<EOF

# Hermes VR DevKit environment
export ANDROID_HOME="$ANDROID_HOME"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="\$HOME/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
fi

# Summary
log "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Source your shell profile: source $SHELL_RC"
echo "  2. Add MCP config to ~/.hermes/config.yaml:"
echo "     cat $HOME/.local/share/hermes-vr-devkit-mcp-config.yaml"
echo "  3. Restart Hermes: /reload"
echo "  4. Verify: hermes mcp test godot && hermes mcp test blender"
echo ""
echo "Installed tools:"
echo "  Godot:     $GODOT_BIN"
echo "  Blender:   $(which blender)"
echo "  ADB:       $(which adb)"
echo "  apksigner: $(which apksigner)"
echo "  scrcpy:    $(which scrcpy)"
echo "  gltfpack:  $(which gltfpack)"
echo ""
echo "To create a new VR project:"
echo "  cp -r $(dirname "$0")/templates/godot-quest-vr ~/Projects/my-vr-app"
echo "  # Or if installed via curl: cp -r /path/to/hermes-vr-devkit/templates/godot-quest-vr ~/Projects/my-vr-app"
