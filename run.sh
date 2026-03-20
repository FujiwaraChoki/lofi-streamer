#!/bin/bash
set -e

APP_NAME="Lofi Streamer"
BUNDLE_DIR="build/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean and create bundle structure
rm -r build 2>/dev/null || true
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

# Copy Info.plist
cp LofiStreamer/Info.plist "${CONTENTS_DIR}/Info.plist"

# Copy icon if it exists
if [ -f AppIcon.icns ]; then
    cp AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"
fi

# Compile
swiftc LofiStreamer/main.swift \
    -o "${MACOS_DIR}/LofiStreamer" \
    -framework Cocoa \
    -framework WebKit \
    -target arm64-apple-macosx13.0

echo "✅ Built ${APP_NAME}"
echo "🎵 Launching..."

# Launch
open "${BUNDLE_DIR}"
