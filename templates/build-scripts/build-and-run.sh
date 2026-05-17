#!/bin/bash
# Build and deploy Godot VR project to Meta Quest
# Usage: ./build-and-run.sh [install|launch|logs|all]

set -euo pipefail

GODOT="${GODOT:-$HOME/bin/godot}"
KEYSTORE="${KEYSTORE:-$HOME/.android/debug.keystore}"
APK_NAME="${APK_NAME:-myapp}"
PACKAGE="${PACKAGE:-com.yourcompany.yourapp}"
ACTIVITY="${ACTIVITY:-com.godot.game.GodotApp}"
EXPORT_PRESET="${EXPORT_PRESET:-Android Quest}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[build]${NC} $*"; }
warn() { echo -e "${YELLOW}[build]${NC} $*"; }
err() { echo -e "${RED}[build]${NC} $*"; }

build() {
  log "Exporting APK..."
  $GODOT --headless --export-release "$EXPORT_PRESET" "${APK_NAME}-unsigned.apk"

  log "Signing APK..."
  apksigner sign --ks "$KEYSTORE" --ks-pass pass:android \
    --key-pass pass:android --out "${APK_NAME}.apk" "${APK_NAME}-unsigned.apk"

  log "Verifying APK..."
  apksigner verify "${APK_NAME}.apk"

  log "Built: ${APK_NAME}.apk"
}

install_apk() {
  log "Installing to Quest..."
  adb install -r "${APK_NAME}.apk"
}

launch() {
  log "Launching on Quest..."
  adb shell am start -n "${PACKAGE}/${ACTIVITY}"
}

logs() {
  log "Streaming logs (Ctrl+C to stop)..."
  adb logcat -s godot:V XR:V VrApi:V DEBUG:V *:S
}

case "${1:-all}" in
  build)
    build
    ;;
  install)
    build
    install_apk
    ;;
  launch)
    build
    install_apk
    launch
    ;;
  logs)
    logs
    ;;
  all)
    build
    install_apk
    launch
    logs
    ;;
  *)
    echo "Usage: $0 [build|install|launch|logs|all]"
    echo ""
    echo "  build   - Export and sign APK only"
    echo "  install - Export, sign, and install"
    echo "  launch  - Export, sign, install, and launch"
    echo "  logs    - Stream filtered logcat"
    echo "  all     - Full pipeline + logs (default)"
    exit 1
    ;;
esac
