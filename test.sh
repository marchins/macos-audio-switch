#!/bin/bash

# Test script for AudioSwitcher development
# This script helps test the keyboard shortcuts functionality

set -e

APP_NAME="AudioSwitcher"
BUILD_DIR="build"
BUNDLE_NAME="${APP_NAME}.app"

echo "🧪 AudioSwitcher Test Script"
echo "=============================="
echo ""

# Check if app is built
if [ ! -d "${BUILD_DIR}/${BUNDLE_NAME}" ]; then
    echo "❌ App not built yet. Building now..."
    ./build.sh
    echo ""
fi

echo "📋 Testing Checklist:"
echo ""
echo "1. Launch the app:"
echo "   open ${BUILD_DIR}/${BUNDLE_NAME}"
echo ""
echo "2. Check menu bar icon appears (speaker icon)"
echo ""
echo "3. Click menu bar icon and verify:"
echo "   - Output devices are listed"
echo "   - Input devices are listed"
echo "   - Keyboard shortcuts are shown (⌘⌥1-5 next to first 5 devices)"
echo "   - Quick toggle shortcut shown (⌘⇧A)"
echo ""
echo "4. Test keyboard shortcuts:"
echo "   - Press ⌘⌥1 to switch to first device"
echo "   - Press ⌘⌥2 to switch to second device"
echo "   - Press ⌘⇧A to toggle back to first device"
echo "   - Press ⌘⇧A again to toggle to second device"
echo ""
echo "5. Verify notifications appear when switching via keyboard"
echo ""
echo "6. Test device detection:"
echo "   - Plug/unplug an audio device"
echo "   - Verify menu updates automatically"
echo ""
echo "7. Check console output:"
echo "   - Should see '✅ Registered global keyboard shortcuts'"
echo "   - Should see device switch messages when using hotkeys"
echo ""
echo "To view console output:"
echo "   log stream --predicate 'process == \"AudioSwitcher\"' --level debug"
echo ""
echo "To launch and test:"
read -p "Press Enter to launch the app now, or Ctrl+C to exit..."

echo ""
echo "🚀 Launching ${APP_NAME}..."
open "${BUILD_DIR}/${BUNDLE_NAME}"

echo ""
echo "📊 Monitoring console output..."
echo "Press Ctrl+C to stop monitoring"
echo ""

# Monitor console output
log stream --predicate 'process == "AudioSwitcher"' --level debug
