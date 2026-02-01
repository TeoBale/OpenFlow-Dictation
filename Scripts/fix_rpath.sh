#!/bin/bash

# Post-build script to fix library paths for whisper.cpp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/debug"
WHISPER_LIB_DIR="$PROJECT_DIR/External/whisper.cpp/build/src"

echo "Fixing library paths..."

if [ -f "$BUILD_DIR/OpenFlow" ]; then
    echo "Adding rpath for whisper library..."
    install_name_tool -add_rpath "$WHISPER_LIB_DIR" "$BUILD_DIR/OpenFlow" 2>/dev/null || true
    
    echo "Re-signing binary (required after modification)..."
    codesign --force --deep --sign - "$BUILD_DIR/OpenFlow"
    
    echo "Library paths fixed and binary re-signed!"
else
    echo "Executable not found at $BUILD_DIR/OpenFlow"
    exit 1
fi
