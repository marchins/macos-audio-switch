#!/bin/bash

# Script to create a DMG installer for AudioSwitcher
# This creates a distributable disk image that users can download and install

set -e

APP_NAME="AudioSwitcher"
VERSION="1.0.0"
BUILD_DIR="build"
DMG_DIR="dmg"
BUNDLE_NAME="${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"

echo "📦 Creating DMG for ${APP_NAME} v${VERSION}..."
echo ""

# Step 1: Build the app if it doesn't exist
if [ ! -d "${BUILD_DIR}/${BUNDLE_NAME}" ]; then
    echo "⚠️  App not found. Building first..."
    ./build.sh
    echo ""
fi

# Step 2: Clean up any existing DMG artifacts
echo "🧹 Cleaning up old DMG artifacts..."
# Unmount any existing volume from previous runs
if [ -d "/Volumes/${VOLUME_NAME}" ]; then
    echo "   Found stale mount, unmounting..."
    hdiutil detach "/Volumes/${VOLUME_NAME}" -force 2>/dev/null || diskutil unmount force "/Volumes/${VOLUME_NAME}" 2>/dev/null || true
    sleep 2
fi
rm -rf "${DMG_DIR}"
rm -f "${DMG_NAME}"
rm -f "${DMG_NAME}.temp.dmg"

# Step 3: Create DMG staging directory
echo "📁 Creating DMG staging directory..."
mkdir -p "${DMG_DIR}"

# Step 4: Copy the app bundle
echo "📋 Copying ${BUNDLE_NAME}..."
cp -R "${BUILD_DIR}/${BUNDLE_NAME}" "${DMG_DIR}/"

# Step 5: Create a symbolic link to Applications folder
echo "🔗 Creating Applications symlink..."
ln -s /Applications "${DMG_DIR}/Applications"

# Step 6: Create a README file for the DMG
echo "📝 Creating README..."
cat > "${DMG_DIR}/README.txt" << 'EOF'
AudioSwitcher
=============

Quick Audio Device Switching for macOS

INSTALLATION:
1. Drag AudioSwitcher.app to the Applications folder
2. Open AudioSwitcher from Applications
3. The app will appear in your menu bar

USAGE:
- Click the menu bar icon to switch devices
- Use keyboard shortcuts:
  • ⌘⇧A - Toggle between last two devices
  • ⌘⌥1-5 - Switch to device 1-5
- Enable "Launch at Login" to start automatically

FEATURES:
✓ Instant audio device switching
✓ Global keyboard shortcuts
✓ Menu bar integration
✓ Auto-start at login
✓ No permissions required

For more information, visit:
https://github.com/yourusername/macos-audio-switch

Enjoy!
EOF

# Step 7: Create the DMG
echo "💿 Creating DMG file..."

# Create a temporary read-write DMG
hdiutil create -volname "${VOLUME_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDRW \
    -fs HFS+ \
    "${DMG_NAME}.temp.dmg"

# Mount the temporary DMG
echo "📂 Mounting temporary DMG..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME}.temp.dmg" | \
    egrep '^/dev/' | sed 1q | awk '{print $1}')
MOUNT_DIR="/Volumes/${VOLUME_NAME}"

# Wait for mount
sleep 2

# Set the DMG window properties (optional - requires AppleScript)
echo "🎨 Configuring DMG appearance..."
if [ -n "${MOUNT_DIR}" ]; then
    osascript << EOD
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 600, 400}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "${BUNDLE_NAME}" of container window to {125, 150}
        set position of item "Applications" of container window to {375, 150}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOD
fi

# Unmount the temporary DMG
echo "💾 Finalizing DMG..."
# Close any Finder windows for this volume
osascript -e "tell application \"Finder\" to close every window" 2>/dev/null || true
sleep 1
# Force detach the device (more reliable than using mount path)
hdiutil detach "${DEVICE}" -force 2>/dev/null || hdiutil detach "${MOUNT_DIR}" -force 2>/dev/null || true
# Wait for the detach to complete
sleep 3
# Verify unmounted
if [ -d "${MOUNT_DIR}" ]; then
    echo "⚠️  Volume still mounted, forcing unmount..."
    diskutil unmount force "${MOUNT_DIR}" 2>/dev/null || true
    sleep 2
fi

# Convert to compressed read-only DMG
hdiutil convert "${DMG_NAME}.temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "${DMG_NAME}"

# Clean up
rm -f "${DMG_NAME}.temp.dmg"
rm -rf "${DMG_DIR}"

echo ""
echo "✅ DMG created successfully!"
echo ""
echo "📍 Location: ${DMG_NAME}"
echo "📊 Size: $(du -h "${DMG_NAME}" | cut -f1)"
echo ""
echo "To test the DMG:"
echo "  open ${DMG_NAME}"
echo ""
echo "To distribute:"
echo "  1. Test the DMG by mounting and installing"
echo "  2. Upload to GitHub Releases"
echo "  3. Share the download link"
echo ""
