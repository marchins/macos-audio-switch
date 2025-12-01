import Cocoa
import Carbon

// Keyboard shortcut handler
class KeyboardShortcutManager {

    private var hotKeys: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    weak var delegate: KeyboardShortcutDelegate?

    // Hotkey IDs
    private enum HotKeyID: UInt32 {
        case toggleLastTwo = 1
        case device1 = 2
        case device2 = 3
        case device3 = 4
        case device4 = 5
        case device5 = 6
    }

    init() {
        setupEventHandler()
    }

    deinit {
        unregisterAllHotKeys()
    }

    // MARK: - Setup

    func registerDefaultHotKeys() {
        // Quick toggle: Cmd+Shift+A
        registerHotKey(
            id: .toggleLastTwo,
            keyCode: UInt32(kVK_ANSI_A),
            modifiers: UInt32(cmdKey | shiftKey)
        )

        // Device shortcuts: Cmd+Opt+1 through Cmd+Opt+5
        registerHotKey(
            id: .device1,
            keyCode: UInt32(kVK_ANSI_1),
            modifiers: UInt32(cmdKey | optionKey)
        )

        registerHotKey(
            id: .device2,
            keyCode: UInt32(kVK_ANSI_2),
            modifiers: UInt32(cmdKey | optionKey)
        )

        registerHotKey(
            id: .device3,
            keyCode: UInt32(kVK_ANSI_3),
            modifiers: UInt32(cmdKey | optionKey)
        )

        registerHotKey(
            id: .device4,
            keyCode: UInt32(kVK_ANSI_4),
            modifiers: UInt32(cmdKey | optionKey)
        )

        registerHotKey(
            id: .device5,
            keyCode: UInt32(kVK_ANSI_5),
            modifiers: UInt32(cmdKey | optionKey)
        )

        print("✅ Registered global keyboard shortcuts:")
        print("   ⌘⇧A - Toggle between last two devices")
        print("   ⌘⌥1-5 - Switch to device 1-5")
    }

    private func registerHotKey(id: HotKeyID, keyCode: UInt32, modifiers: UInt32) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType("swat".fourCharCodeValue), id: id.rawValue)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr {
            hotKeys.append(hotKeyRef)
        } else {
            print("⚠️ Failed to register hotkey \(id): \(status)")
        }
    }

    private func setupEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetEventDispatcherTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    theEvent,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard let manager = userData?.assumingMemoryBound(to: KeyboardShortcutManager.self).pointee else {
                    return OSStatus(eventNotHandledErr)
                }

                manager.handleHotKey(id: hotKeyID.id)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    // MARK: - Handle Hotkeys

    private func handleHotKey(id: UInt32) {
        guard let hotKeyID = HotKeyID(rawValue: id) else { return }

        DispatchQueue.main.async { [weak self] in
            switch hotKeyID {
            case .toggleLastTwo:
                self?.delegate?.toggleLastTwoDevices()
            case .device1:
                self?.delegate?.switchToDevice(index: 0)
            case .device2:
                self?.delegate?.switchToDevice(index: 1)
            case .device3:
                self?.delegate?.switchToDevice(index: 2)
            case .device4:
                self?.delegate?.switchToDevice(index: 3)
            case .device5:
                self?.delegate?.switchToDevice(index: 4)
            }
        }
    }

    // MARK: - Cleanup

    private func unregisterAllHotKeys() {
        for hotKey in hotKeys {
            if let hotKey = hotKey {
                UnregisterEventHotKey(hotKey)
            }
        }
        hotKeys.removeAll()

        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}

// MARK: - Delegate Protocol

protocol KeyboardShortcutDelegate: AnyObject {
    func toggleLastTwoDevices()
    func switchToDevice(index: Int)
}

// MARK: - Helper Extension

extension String {
    var fourCharCodeValue: Int {
        var result: Int = 0
        for char in self.utf8 {
            result = result << 8 + Int(char)
        }
        return result
    }
}
