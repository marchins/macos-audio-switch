# macOS Audio Switcher

A lightweight macOS menu bar app for quickly switching between audio input and output devices. Perfect for switching between internal speakers and external audio interfaces like the Scarlett Solo.

## Features

- **Fast Audio Switching**: Instantly switch between audio devices with a single click
- **Global Keyboard Shortcuts**: Switch devices without touching the menu bar
- **Quick Toggle**: Instantly toggle between your last two used devices
- **Launch at Login**: Optional auto-start when you log in to macOS
- **Menu Bar Integration**: Lives in your menu bar for quick access
- **Separate Input/Output Control**: Independently manage input and output devices
- **Real-time Updates**: Automatically detects when audio devices are connected/disconnected
- **Visual Notifications**: Get feedback when switching via keyboard shortcuts
- **Minimal Resource Usage**: Native Swift app with no background overhead
- **No Permissions Required**: Uses standard CoreAudio APIs

## Screenshots

The app appears as a speaker icon in your menu bar. Click it to see all available audio devices:

```
🔊 Audio Switcher
├── Audio Devices
├──────────────────
├── Output Devices:
│   ✓ MacBook Pro Speakers  ⌘⌥1
│     Scarlett Solo USB  ⌘⌥2
│     HDMI Output  ⌘⌥3
├──────────────────
├── Input Devices:
│     MacBook Pro Microphone
│   ✓ Scarlett Solo USB
├──────────────────
├── Keyboard Shortcuts:
│     ⌘⇧A - Toggle Last Two
├──────────────────
│ ✓ Launch at Login
├──────────────────
└── Quit
```

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools (for building)

## Installation

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/macos-audio-switch.git
   cd macos-audio-switch
   ```

2. Build the app:
   ```bash
   make build
   # or
   ./build.sh
   ```

3. Run the app:
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

### Option 2: Quick Build Script

```bash
./build.sh
open build/AudioSwitcher.app
```

## Usage

1. **Launch the app**: Double-click AudioSwitcher.app or run it from Applications
2. **Access the menu**: Click the speaker icon in your menu bar
3. **Switch devices**: Click on any audio device to make it the default
4. **Check current device**: The active device has a checkmark (✓)

### Tips

- The app runs in the background and uses minimal resources
- Audio devices are automatically detected when plugged/unplugged
- Enable "Launch at Login" from the menu to start the app automatically when you log in
- The checkmark (✓) shows which device is currently active

## Keyboard Shortcuts

AudioSwitcher includes powerful global keyboard shortcuts that work system-wide:

### Quick Toggle
- **⌘⇧A** (Cmd+Shift+A) - Toggle between your last two used output devices
  - Perfect for quickly switching between speakers and headphones
  - Example: Scarlett Solo → Internal Speakers → Scarlett Solo

### Numbered Device Shortcuts
- **⌘⌥1** (Cmd+Option+1) - Switch to output device #1
- **⌘⌥2** (Cmd+Option+2) - Switch to output device #2
- **⌘⌥3** (Cmd+Option+3) - Switch to output device #3
- **⌘⌥4** (Cmd+Option+4) - Switch to output device #4
- **⌘⌥5** (Cmd+Option+5) - Switch to output device #5

Device numbers correspond to the order shown in the menu (top to bottom). The keyboard shortcuts are displayed next to each device name in the menu bar dropdown.

### Visual Feedback

When switching via keyboard shortcuts, you'll see a macOS notification showing:
- The type of switch (Output/Input)
- The device name you switched to

This confirms the switch was successful without needing to check the menu.

## Launch at Login

AudioSwitcher can automatically start when you log in to macOS:

1. **Enable**: Click "Launch at Login" in the menu (a checkmark will appear)
2. **Disable**: Click "Launch at Login" again to disable
3. **Status**: The checkmark shows whether auto-start is enabled

When enabled, the app will:
- Start automatically when you log in
- Appear in your menu bar ready to use
- Not show any windows or dialogs (silent start)

This is perfect for daily use - set it once and never think about it again. Your audio switching shortcuts will always be available.

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
│   ├── main.swift                      # App entry point
│   ├── AppDelegate.swift               # Menu bar UI and event handling
│   ├── AudioDeviceManager.swift        # CoreAudio integration
│   ├── KeyboardShortcutManager.swift   # Global hotkey management
│   ├── LaunchAtLoginManager.swift      # Login item management
│   └── Info.plist                      # App configuration
├── Makefile                            # Build automation
├── build.sh                            # Build script
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

- **AppDelegate.swift**: Change UI, modify menu structure, add features
- **AudioDeviceManager.swift**: Modify CoreAudio behavior, add device filtering
- **KeyboardShortcutManager.swift**: Customize keyboard shortcuts, add new hotkeys
- **LaunchAtLoginManager.swift**: Modify login item behavior, update registration logic
- **Info.plist**: Change app bundle ID, version, or system requirements

### Adding Features

Some ideas for future enhancements:

1. **Customizable Keyboard Shortcuts**: Allow users to configure their own hotkeys
2. **Favorite Devices**: Pin frequently used devices to the top of the menu
3. **Auto-switching**: Automatically switch when specific devices connect
4. **Device Profiles**: Save and restore complete audio setups with one click
5. **Volume Control**: Add per-device volume management directly in the menu
6. **Sample Rate Control**: Switch sample rates for professional audio work
7. **Input/Output Pairing**: Remember and restore input/output pairs

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
