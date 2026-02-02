#!/bin/bash

# Simple build script for AudioSwitcher
# This script compiles the Swift app and creates a proper macOS app bundle

set -e

APP_NAME="AudioSwitcher"
BUILD_DIR="build"
BUNDLE_NAME="${APP_NAME}.app"

echo "🔨 Building ${APP_NAME}..."

# Create bundle structure
mkdir -p "${BUILD_DIR}/${BUNDLE_NAME}/Contents/MacOS"
mkdir -p "${BUILD_DIR}/${BUNDLE_NAME}/Contents/Resources"

# Compile Swift sources
echo "📦 Compiling Swift sources..."
swiftc \
    AudioSwitcher/main.swift \
    AudioSwitcher/AppDelegate.swift \
    AudioSwitcher/AudioDeviceManager.swift \
    AudioSwitcher/KeyboardShortcutManager.swift \
    AudioSwitcher/LaunchAtLoginManager.swift \
    -o "${BUILD_DIR}/${BUNDLE_NAME}/Contents/MacOS/${APP_NAME}" \
    -framework Cocoa \
    -framework CoreAudio \
    -framework Carbon \
    -framework ServiceManagement \
    -Xlinker -rpath -Xlinker @executable_path/../Frameworks

# Copy Info.plist
cp AudioSwitcher/Info.plist "${BUILD_DIR}/${BUNDLE_NAME}/Contents/"

echo "✅ Build complete!"
echo "📍 App bundle created at: ${BUILD_DIR}/${BUNDLE_NAME}"
echo ""
echo "To run the app:"
echo "  open ${BUILD_DIR}/${BUNDLE_NAME}"
echo ""
echo "To install to /Applications:"
echo "  sudo cp -r ${BUILD_DIR}/${BUNDLE_NAME} /Applications/"
