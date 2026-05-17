#!/bin/bash
# Hermes VR DevKit -- Minimal Installer
# Installs: Godot 4.5, Android SDK, debug keystore
# No Blender, no MCP servers. For users who only need Godot + Quest.

set -euo pipefail

GODOT_VERSION="4.5-stable"
ANDROID_API="33"
ANDROID_BUILD_TOOLS="34.0.0"

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[vr-devkit]${NC} $*"; }

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) GODOT_ARCH="linux.x86_64" ;;
  aarch64) GODOT_ARCH="linux.arm64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

read -rp "Install Godot $GODOT_VERSION + Android SDK? [Y/n] " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && exit 0

log "Installing system packages..."
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk adb apksigner unzip wget curl

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
sdkmanager "platform-tools" "build-tools;$ANDROID_BUILD_TOOLS" "platforms;android-$ANDROID_API"

log "Installing Godot $GODOT_VERSION..."
mkdir -p "$HOME/bin"
GODOT_BIN="$HOME/bin/godot"
if [ ! -f "$GODOT_BIN" ]; then
  cd /tmp
  wget -q "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
  unzip -q "Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
  mv "Godot_v$GODOT_VERSION_$GODOT_ARCH" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -f "Godot_v$GODOT_VERSION_$GODOT_ARCH.zip"
fi

TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/$GODOT_VERSION"
if [ ! -d "$TEMPLATE_DIR" ]; then
  cd /tmp
  wget -q "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v$GODOT_VERSION_export_templates.tpz"
  mkdir -p "$TEMPLATE_DIR"
  unzip -q "Godot_v$GODOT_VERSION_export_templates.tpz" -d "$TEMPLATE_DIR"
  [ -d "$TEMPLATE_DIR/templates" ] && { mv "$TEMPLATE_DIR/templates"/* "$TEMPLATE_DIR/" 2>/dev/null || true; rmdir "$TEMPLATE_DIR/templates" 2>/dev/null || true; }
  rm -f "Godot_v$GODOT_VERSION_export_templates.tpz"
fi

log "Creating debug keystore..."
KEYSTORE="$HOME/.android/debug.keystore"
mkdir -p "$HOME/.android"
[ ! -f "$KEYSTORE" ] && keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android \
  -keystore "$KEYSTORE" -storepass android \
  -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12 2>/dev/null || true

mkdir -p "$HOME/.config/godot"
cat > "$HOME/.config/godot/editor_settings-4.5.tres" <<EOF
[resource]
export/android/android_sdk_path = "$ANDROID_HOME"
export/android/java_sdk_path = "/usr/lib/jvm/java-17-openjdk-amd64"
export/android/debug_keystore = "$KEYSTORE"
export/android/debug_keystore_pass = "android"
EOF

SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
if ! grep -q "ANDROID_HOME" "$SHELL_RC"; then
  cat >> "$SHELL_RC" <<EOF
export ANDROID_HOME="$ANDROID_HOME"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="\$HOME/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
fi

log "Minimal install complete!"
echo "Source your profile: source $SHELL_RC"
