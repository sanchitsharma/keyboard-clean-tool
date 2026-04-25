#!/bin/bash
set -e

APP="KeyboardClean.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc keyboard_clean.swift -o "$APP/Contents/MacOS/KeyboardClean"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>KeyboardClean</string>
    <key>CFBundleDisplayName</key>
    <string>KeyboardClean</string>
    <key>CFBundleIdentifier</key>
    <string>local.keyboardclean</string>
    <key>CFBundleExecutable</key>
    <string>KeyboardClean</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

SIGN_ID="KeyboardClean Dev"
if security find-identity -v -p codesigning | grep -q "$SIGN_ID"; then
    codesign --force --deep --sign "$SIGN_ID" "$APP"
else
    echo "Note: '$SIGN_ID' identity not found — falling back to ad-hoc signing." >&2
    echo "      Run ./setup-signing.sh once for stable signing across rebuilds." >&2
    codesign --force --deep --sign - "$APP"
fi
echo "Built $APP"
