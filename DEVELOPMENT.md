# AudioSwitcher Development Guide

This guide provides detailed information for developers working on AudioSwitcher.

## Quick Start

1. **Build the app**:
   ```bash
   make build
   # or
   ./build.sh
   ```

2. **Run the app**:
   ```bash
   make run
   # or
   open build/AudioSwitcher.app
   ```

3. **Test functionality**:
   ```bash
   ./test.sh
   ```

## Architecture

### Component Overview

```
┌─────────────────────────────────────────┐
│           AppDelegate                   │
│  (Menu bar UI & user interaction)       │
└─────────┬───────────────────────┬───────┘
          │                       │
          ▼                       ▼
┌─────────────────────┐  ┌──────────────────────┐
│ AudioDeviceManager  │  │ KeyboardShortcutMgr  │
│ (CoreAudio API)     │  │ (Global hotkeys)     │
└─────────────────────┘  └──────────────────────┘
```

### Key Components

#### 1. **main.swift**
- Entry point for the application
- Initializes NSApplication and AppDelegate
- Minimal code - just bootstraps the app

#### 2. **AppDelegate.swift**
- Manages menu bar status item
- Builds and updates the menu UI
- Handles user interactions (clicks, shortcuts)
- Tracks device history for quick toggle
- Shows notifications for keyboard shortcuts
- Implements `KeyboardShortcutDelegate` protocol

#### 3. **AudioDeviceManager.swift**
- Wraps CoreAudio framework APIs
- Enumerates all audio devices
- Gets/sets default input/output devices
- Monitors device changes
- Determines device capabilities (input/output)

#### 4. **KeyboardShortcutManager.swift**
- Registers global keyboard shortcuts using Carbon framework
- Handles hotkey events
- Delegates actions to AppDelegate
- Manages hotkey lifecycle

## Keyboard Shortcuts Implementation

### How Global Hotkeys Work

1. **Registration** (`KeyboardShortcutManager.swift`):
   - Uses Carbon's `RegisterEventHotKey` API
   - Registers shortcuts when app launches
   - Shortcuts work system-wide (even when app is in background)

2. **Event Handling**:
   - Carbon calls our event handler when hotkey is pressed
   - Handler identifies which shortcut was triggered
   - Calls appropriate delegate method on main thread

3. **Action Execution** (`AppDelegate.swift`):
   - Delegate methods switch audio devices
   - Shows macOS notifications for feedback
   - Updates menu to reflect new state

### Current Shortcuts

| Shortcut | Action | Implementation |
|----------|--------|----------------|
| ⌘⇧A | Toggle between last two devices | `toggleLastTwoDevices()` |
| ⌘⌥1-5 | Switch to device 1-5 | `switchToDevice(index:)` |

### Adding New Shortcuts

See the full guide in the file for detailed steps on adding custom shortcuts.

## Testing

Use `./test.sh` for manual testing checklist.

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [CoreAudio Programming Guide](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/)
