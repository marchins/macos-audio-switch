# macOS Audio Switcher

A lightweight macOS menu bar app for quickly switching between audio input and output devices. Perfect for switching between internal speakers and external audio interfaces, without opening MacOS Settings.

## Features

- **Fast Audio Switching**: Instantly switch between audio devices with a single click
- **Menu Bar Integration**: Lives in your menu bar for quick access
- **Separate Input/Output Control**: Independently manage input and output devices
- **Real-time Updates**: Automatically detects when audio devices are connected/disconnected
- **Minimal Resource Usage**: Native Swift app with no background overhead
- **No Permissions Required**: Uses standard CoreAudio APIs

## Screenshots

The app appears as a speaker icon in your menu bar. Click it to see all available audio devices:

```
🔊 Audio Switcher
├── Audio Devices
├──────────────────
├── Output Devices:
│   ✓ MacBook Pro Speakers
│     Scarlett Solo USB
├──────────────────
├── Input Devices:
│   ✓ MacBook Pro Microphone
│     Scarlett Solo USB
├──────────────────
└── Quit
```

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools (for building)

## Installation

### Option 1: Build from Source


1. Build the app:
   ```bash
   make build
   # or
   ./build.sh
   ```

2. Run the app:
   ```bash
   make run
   # or
   open build/AudioSwitcher.app
   ```

4. (Optional) Install to Applications folder:
   ```bash
   make install
   # or
   sudo cp -r build/AudioSwitcher.app /Applications/
   ```

## Usage

1. **Launch the app**: Double-click AudioSwitcher.app or run it from Applications
2. **Access the menu**: Click the speaker icon in your menu bar
3. **Switch devices**: Click on any audio device to make it the default
4. **Check current device**: The active device has a checkmark (✓)

### Tips

- The app runs in the background and uses minimal resources
- Audio devices are automatically detected when plugged/unplugged
- To start the app at login, add it to System Settings → Login Items

## How It Works

AudioSwitcher uses Apple's CoreAudio framework to:

1. **Enumerate devices**: Lists all connected audio input and output devices
2. **Read current settings**: Detects which device is currently active
3. **Switch devices**: Changes the system default audio device instantly
4. **Monitor changes**: Listens for device connections/disconnections

### Technical Details

- **Switching Speed**: <100ms (essentially instant)
- **Framework**: CoreAudio (native macOS audio API)
- **Language**: Swift 5
- **UI Framework**: Cocoa (NSStatusBar)
- **Architecture**: Agent-style menu bar app (LSUIElement = true)

## Development

### Project Structure

```
macos-audio-switch/
├── AudioSwitcher/
│   ├── main.swift                 # App entry point
│   ├── AppDelegate.swift          # Menu bar UI and event handling
│   ├── AudioDeviceManager.swift   # CoreAudio integration
│   └── Info.plist                 # App configuration
├── Makefile                       # Build automation
├── build.sh                       # Build script
└── README.md
```

### Building

The app can be built using either `make` or the `build.sh` script:

```bash
# Using make
make build    # Build the app
make run      # Build and run
make clean    # Remove build artifacts
make install  # Install to /Applications

# Using build script
./build.sh    # Build only
```

### Modifying the Code

Key files to modify:

- **AppDelegate.swift**: Change UI, add keyboard shortcuts, add features
- **AudioDeviceManager.swift**: Modify CoreAudio behavior, add device filtering
- **Info.plist**: Change app bundle ID, version, or system requirements

### Adding Features

Some ideas for enhancements:

1. **Keyboard Shortcuts**: Add global hotkeys for device switching
2. **Favorite Devices**: Pin frequently used devices to the top
3. **Auto-switching**: Automatically switch when specific devices connect
4. **Device Profiles**: Save and restore complete audio setups
5. **Volume Control**: Add per-device volume management
6. **Notifications**: Show alerts when devices are switched

## Troubleshooting

### The app won't build
- Ensure you have Xcode Command Line Tools installed:
  ```bash
  xcode-select --install
  ```

### The menu bar icon doesn't appear
- Check that the app is running (look in Activity Monitor)
- Try quitting and relaunching the app

### Audio devices aren't listed
- Make sure your audio devices are properly connected
- Check System Settings → Sound to verify devices are recognized by macOS

### Changes don't take effect
- Some apps may override system audio settings
- Try restarting the app that's using audio

## Known Limitations

- Cannot control app-specific audio routing (system-level only)
- Some professional audio apps may ignore system default device settings
- No sample rate or bit depth control (uses device defaults)

## Contributing

Contributions are welcome! Feel free to:

- Report bugs or issues
- Suggest new features
- Submit pull requests
- Improve documentation

## License

See [LICENSE](LICENSE) for details.

## Acknowledgments

Built with Apple's CoreAudio framework and inspired by the need for quick audio device switching during music production and streaming.

---

**Note**: This app provides the same functionality as going to System Settings → Sound and manually changing the input/output device, but much faster and more convenient.
