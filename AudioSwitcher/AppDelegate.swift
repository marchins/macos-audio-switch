import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    let audioManager = AudioDeviceManager()

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
        for device in outputDevices {
            let item = NSMenuItem(
                title: "  \(device.name)",
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

        // Quit option
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    @objc func switchOutputDevice(_ sender: NSMenuItem) {
        if let deviceID = sender.representedObject as? AudioDeviceID {
            audioManager.setDefaultOutputDevice(deviceID)
            buildMenu() // Rebuild menu to update checkmarks
        }
    }

    @objc func switchInputDevice(_ sender: NSMenuItem) {
        if let deviceID = sender.representedObject as? AudioDeviceID {
            audioManager.setDefaultInputDevice(deviceID)
            buildMenu() // Rebuild menu to update checkmarks
        }
    }

    @objc func audioDevicesChanged() {
        buildMenu()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
