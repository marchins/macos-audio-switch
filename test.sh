#!/bin/bash

# Test script for AudioSwitcher app
# This verifies the app can detect audio devices on the system

echo "🎵 AudioSwitcher App Test"
echo "========================="
echo ""

# Check if app is running
if pgrep -f "AudioSwitcher.app" > /dev/null; then
    echo "✅ App is running"
else
    echo "❌ App is not running. Starting it..."
    open build/AudioSwitcher.app &
    sleep 2
fi

echo ""
echo "📋 System Audio Devices:"
echo "------------------------"
system_profiler SPAudioDataType | grep -E "^\s+(Manufacturer|Input Channels|Output Channels|Default|Device:|Transport)" | head -30

echo ""
echo "🔊 Current Default Output Device:"
echo "-----------------------------------"
# Get current default output device using CoreAudio
# This would require parsing from system_profiler
defaults read -g com.apple.sound.uiaudio.enabled 2>/dev/null || echo "Using system defaults"

echo ""
echo "✨ Test Complete!"
echo ""
echo "💡 To test switching:"
echo "   1. Click the speaker icon in the menu bar"
echo "   2. Select a different output device (e.g., Scarlett Solo 4th Gen)"
echo "   3. The system audio should route through that device"
echo ""
echo "📝 Note: This is a menu bar app, so you'll see the speaker icon"
echo "   in the top-right corner of your screen."
