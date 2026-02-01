#!/bin/bash

set -e

APP_NAME="OpenFlow"
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DIR=".build/release"
OUTPUT_DIR="dist"

echo "Building $APP_NAME v$VERSION..."

swift build -c release

echo "Creating app bundle..."

mkdir -p "$OUTPUT_DIR"

APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.openflow.dictation</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>OpenFlow needs microphone access to transcribe your speech.</string>
</dict>
</plist>
EOF

echo "Build complete: $APP_BUNDLE"
echo "To run: open $APP_BUNDLE"
