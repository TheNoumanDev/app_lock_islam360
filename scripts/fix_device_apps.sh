#!/bin/bash
# Script to fix namespace issues in outdated Flutter packages
# Run this after: flutter pub get

echo "🔧 Fixing namespace issues in Flutter packages..."

# Fix device_apps
DEVICE_APPS_PATH="$HOME/.pub-cache/hosted/pub.dev/device_apps-2.2.0/android/build.gradle"
if [ -f "$DEVICE_APPS_PATH" ]; then
    if ! grep -q "namespace" "$DEVICE_APPS_PATH"; then
        sed -i '' '/android {/a\
    namespace '\''fr.g123k.deviceapps'\''
' "$DEVICE_APPS_PATH"
        echo "✅ Fixed device_apps namespace"
    fi
fi

# Fix system_alert_window
SYSTEM_ALERT_PATH="$HOME/.pub-cache/hosted/pub.dev/system_alert_window-1.3.0/android/build.gradle"
if [ -f "$SYSTEM_ALERT_PATH" ]; then
    if ! grep -q "namespace" "$SYSTEM_ALERT_PATH"; then
        sed -i '' '/android {/a\
    namespace '\''in.jvapps.system_alert_window'\''
' "$SYSTEM_ALERT_PATH"
        echo "✅ Fixed system_alert_window namespace"
    fi
fi

echo "✨ Done! Try building again."
