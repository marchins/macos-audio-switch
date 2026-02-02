import Cocoa
import ServiceManagement

class LaunchAtLoginManager {

    static let shared = LaunchAtLoginManager()

    // The bundle identifier for the main app
    private let appBundleIdentifier = "com.audioswitch.app"

    private init() {}

    // MARK: - Check Status

    /// Check if the app is set to launch at login
    var isEnabled: Bool {
        // For macOS 13+ we could use SMAppService, but for broader compatibility
        // we'll check the login items directly
        return isInLoginItems()
    }

    // MARK: - Enable/Disable

    /// Toggle launch at login on/off
    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }

    /// Enable launch at login
    func enable() {
        if #available(macOS 13.0, *) {
            enableModern()
        } else {
            enableLegacy()
        }
    }

    /// Disable launch at login
    func disable() {
        if #available(macOS 13.0, *) {
            disableModern()
        } else {
            disableLegacy()
        }
    }

    // MARK: - Modern Implementation (macOS 13+)

    @available(macOS 13.0, *)
    private func enableModern() {
        do {
            if SMAppService.mainApp.status == .enabled {
                print("✅ Already registered for login")
                return
            }

            try SMAppService.mainApp.register()
            print("✅ Successfully registered for launch at login")
        } catch {
            print("⚠️ Failed to register for launch at login: \(error.localizedDescription)")
            // Fall back to legacy method
            enableLegacy()
        }
    }

    @available(macOS 13.0, *)
    private func disableModern() {
        do {
            if SMAppService.mainApp.status == .notRegistered {
                print("✅ Already unregistered from login")
                return
            }

            try SMAppService.mainApp.unregister()
            print("✅ Successfully unregistered from launch at login")
        } catch {
            print("⚠️ Failed to unregister from launch at login: \(error.localizedDescription)")
            // Fall back to legacy method
            disableLegacy()
        }
    }

    // MARK: - Legacy Implementation (macOS 11-12)

    private func enableLegacy() {
        // Use AppleScript to add to login items
        let script = """
        tell application "System Events"
            make login item at end with properties {path:"\(Bundle.main.bundlePath)", hidden:false}
        end tell
        """

        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)

            if let error = error {
                print("⚠️ Failed to add login item: \(error)")
            } else {
                print("✅ Successfully added to login items")
            }
        }
    }

    private func disableLegacy() {
        // Use AppleScript to remove from login items
        let script = """
        tell application "System Events"
            delete login item "AudioSwitcher"
        end tell
        """

        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)

            if let error = error {
                print("⚠️ Failed to remove login item: \(error)")
            } else {
                print("✅ Successfully removed from login items")
            }
        }
    }

    // MARK: - Check Login Items

    private func isInLoginItems() -> Bool {
        // Check using AppleScript
        let script = """
        tell application "System Events"
            get the name of every login item
        end tell
        """

        if let scriptObject = NSAppleScript(source: script) {
            var error: NSDictionary?
            let output = scriptObject.executeAndReturnError(&error)

            if let error = error {
                print("⚠️ Failed to check login items: \(error)")
                return false
            }

            if let result = output.stringValue {
                // Check if our app name is in the list
                return result.contains("AudioSwitcher")
            }
        }

        return false
    }

    // MARK: - User Notification

    func showStatusNotification() {
        let notification = NSUserNotification()
        notification.title = "Launch at Login"
        notification.informativeText = isEnabled ? "Enabled" : "Disabled"
        notification.soundName = nil
        NSUserNotificationCenter.default.deliver(notification)
    }
}
