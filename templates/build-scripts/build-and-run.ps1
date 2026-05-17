# Build and deploy Godot VR project to Meta Quest (PowerShell)
# Usage: .\build-and-run.ps1 [Build|Install|Launch|Logs|All]

$GODOT = $env:GODOT -or "$env:USERPROFILE\bin\godot.exe"
$KEYSTORE = $env:KEYSTORE -or "$env:USERPROFILE\.android\debug.keystore"
$APK_NAME = $env:APK_NAME -or "myapp"
$PACKAGE = $env:PACKAGE -or "com.yourcompany.yourapp"
$ACTIVITY = $env:ACTIVITY -or "com.godot.game.GodotApp"
$EXPORT_PRESET = $env:EXPORT_PRESET -or "Android Quest"

function Build-APK {
    Write-Host "[build] Exporting APK..." -ForegroundColor Green
    & $GODOT --headless --export-release $EXPORT_PRESET "${APK_NAME}-unsigned.apk"

    Write-Host "[build] Signing APK..." -ForegroundColor Green
    apksigner sign --ks $KEYSTORE --ks-pass pass:android `
        --key-pass pass:android --out "${APK_NAME}.apk" "${APK_NAME}-unsigned.apk"

    Write-Host "[build] Verifying APK..." -ForegroundColor Green
    apksigner verify "${APK_NAME}.apk"

    Write-Host "[build] Built: ${APK_NAME}.apk" -ForegroundColor Green
}

function Install-APK {
    Write-Host "[build] Installing to Quest..." -ForegroundColor Green
    adb install -r "${APK_NAME}.apk"
}

function Launch-APK {
    Write-Host "[build] Launching on Quest..." -ForegroundColor Green
    adb shell am start -n "${PACKAGE}/${ACTIVITY}"
}

function Show-Logs {
    Write-Host "[build] Streaming logs (Ctrl+C to stop)..." -ForegroundColor Green
    adb logcat -s godot:V XR:V VrApi:V DEBUG:V *:S
}

$command = $args[0] -or "All"

switch ($command) {
    "Build" { Build-APK }
    "Install" { Build-APK; Install-APK }
    "Launch" { Build-APK; Install-APK; Launch-APK }
    "Logs" { Show-Logs }
    "All" { Build-APK; Install-APK; Launch-APK; Show-Logs }
    default {
        Write-Host "Usage: .\build-and-run.ps1 [Build|Install|Launch|Logs|All]"
    }
}
