import Cocoa
import CoreAudio

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    let audioManager = AudioDeviceManager()
    let keyboardManager = KeyboardShortcutManager()

    // Track last devices for quick toggle
    private var lastOutputDevice: AudioDeviceID?
    private var currentOutputDevice: AudioDeviceID?
    private var lastInputDevice: AudioDeviceID?
    private var currentInputDevice: AudioDeviceID?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "Audio Switcher")
            button.image?.isTemplate = true
        }

        // Create menu
        menu = NSMenu()
        buildMenu()
        statusItem?.menu = menu

        // Setup keyboard shortcuts
        keyboardManager.delegate = self
        keyboardManager.registerDefaultHotKeys()

        // Initialize device tracking
        currentOutputDevice = audioManager.getDefaultOutputDevice()
        currentInputDevice = audioManager.getDefaultInputDevice()

        // Listen for audio device changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioDevicesChanged),
            name: NSNotification.Name("AudioDevicesChanged"),
            object: nil
        )

        // Setup device change monitoring
        audioManager.startMonitoring()
    }

    func buildMenu() {
        menu?.removeAllItems()

        // Add title
        let titleItem = NSMenuItem(title: "Audio Devices", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu?.addItem(titleItem)
        menu?.addItem(NSMenuItem.separator())

        // Get current devices
        let currentOutputID = audioManager.getDefaultOutputDevice()
        let currentInputID = audioManager.getDefaultInputDevice()

        // Output devices section
        let outputTitle = NSMenuItem(title: "Output Devices:", action: nil, keyEquivalent: "")
        outputTitle.isEnabled = false
        menu?.addItem(outputTitle)

        let outputDevices = audioManager.getOutputDevices()
        for (index, device) in outputDevices.enumerated() {
            // Add keyboard shortcut hint for first 5 devices
            let shortcutHint = index < 5 ? "  ⌘⌥\(index + 1)" : ""
            let item = NSMenuItem(
                title: "  \(device.name)\(shortcutHint)",
                action: #selector(switchOutputDevice(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = device.id
            item.state = device.id == currentOutputID ? .on : .off
            menu?.addItem(item)
        }

        menu?.addItem(NSMenuItem.separator())

        // Input devices section
        let inputTitle = NSMenuItem(title: "Input Devices:", action: nil, keyEquivalent: "")
        inputTitle.isEnabled = false
        menu?.addItem(inputTitle)

        let inputDevices = audioManager.getInputDevices()
        for device in inputDevices {
            let item = NSMenuItem(
                title: "  \(device.name)",
                action: #selector(switchInputDevice(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = device.id
            item.state = device.id == currentInputID ? .on : .off
            menu?.addItem(item)
        }

        menu?.addItem(NSMenuItem.separator())

        // Keyboard shortcuts info
        let shortcutsTitle = NSMenuItem(title: "Keyboard Shortcuts:", action: nil, keyEquivalent: "")
        shortcutsTitle.isEnabled = false
        menu?.addItem(shortcutsTitle)

        let toggleItem = NSMenuItem(title: "  ⌘⇧A - Toggle Last Two", action: nil, keyEquivalent: "")
        toggleItem.isEnabled = false
        menu?.addItem(toggleItem)

        menu?.addItem(NSMenuItem.separator())

        // Launch at Login option
        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        launchAtLoginItem.state = LaunchAtLoginManager.shared.isEnabled ? .on : .off
        menu?.addItem(launchAtLoginItem)

        menu?.addItem(NSMenuItem.separator())

        // Quit option
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    @objc func switchOutputDevice(_ sender: NSMenuItem) {
        if let deviceID = sender.representedObject as? AudioDeviceID {
            switchToOutputDevice(deviceID)
        }
    }

    @objc func switchInputDevice(_ sender: NSMenuItem) {
        if let deviceID = sender.representedObject as? AudioDeviceID {
            switchToInputDevice(deviceID)
        }
    }

    private func switchToOutputDevice(_ deviceID: AudioDeviceID, showNotification: Bool = false) {
        // Track last device
        if let current = currentOutputDevice, current != deviceID {
            lastOutputDevice = current
        }

        audioManager.setDefaultOutputDevice(deviceID)
        currentOutputDevice = deviceID
        buildMenu()

        // Show notification if requested
        if showNotification, let deviceName = getDeviceName(deviceID) {
            showSwitchNotification(deviceName: deviceName, type: "Output")
        }
    }

    private func switchToInputDevice(_ deviceID: AudioDeviceID, showNotification: Bool = false) {
        // Track last device
        if let current = currentInputDevice, current != deviceID {
            lastInputDevice = current
        }

        audioManager.setDefaultInputDevice(deviceID)
        currentInputDevice = deviceID
        buildMenu()

        // Show notification if requested
        if showNotification, let deviceName = getDeviceName(deviceID) {
            showSwitchNotification(deviceName: deviceName, type: "Input")
        }
    }

    private func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        let allDevices = audioManager.getOutputDevices() + audioManager.getInputDevices()
        return allDevices.first { $0.id == deviceID }?.name
    }

    private func showSwitchNotification(deviceName: String, type: String) {
        let notification = NSUserNotification()
        notification.title = "Audio \(type) Switched"
        notification.informativeText = deviceName
        notification.soundName = nil // Silent notification
        NSUserNotificationCenter.default.deliver(notification)
    }

    @objc func audioDevicesChanged() {
        // Update current device tracking
        currentOutputDevice = audioManager.getDefaultOutputDevice()
        currentInputDevice = audioManager.getDefaultInputDevice()
        buildMenu()
    }

    @objc func toggleLaunchAtLogin() {
        LaunchAtLoginManager.shared.toggle()
        buildMenu() // Rebuild menu to update checkmark
        LaunchAtLoginManager.shared.showStatusAlert()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - Keyboard Shortcut Delegate

extension AppDelegate: KeyboardShortcutDelegate {

    func toggleLastTwoDevices() {
        print("🔄 Toggle last two devices")

        if let last = lastOutputDevice {
            switchToOutputDevice(last, showNotification: true)
        } else {
            print("⚠️ No previous device to toggle to")
        }
    }

    func switchToDevice(index: Int) {
        let outputDevices = audioManager.getOutputDevices()

        guard index < outputDevices.count else {
            print("⚠️ Device index \(index + 1) out of range")
            return
        }

        let device = outputDevices[index]
        print("🎵 Switching to device \(index + 1): \(device.name)")
        switchToOutputDevice(device.id, showNotification: true)
    }
}
