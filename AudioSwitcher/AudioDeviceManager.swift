import CoreAudio
import Foundation

struct AudioDevice {
    let id: AudioDeviceID
    let name: String
}

class AudioDeviceManager {

    // MARK: - Get All Devices

    func getAllDevices() -> [AudioDevice] {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        // Get size of device list
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize
        )

        if status != noErr {
            print("Error getting device list size: \(status)")
            return []
        }

        // Get device list
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceIDs
        )

        if status != noErr {
            print("Error getting device list: \(status)")
            return []
        }

        // Convert to AudioDevice objects
        return deviceIDs.compactMap { deviceID in
            guard let name = getDeviceName(deviceID) else { return nil }
            return AudioDevice(id: deviceID, name: name)
        }
    }

    // MARK: - Get Output Devices

    func getOutputDevices() -> [AudioDevice] {
        return getAllDevices().filter { hasOutputStreams($0.id) }
    }

    // MARK: - Get Input Devices

    func getInputDevices() -> [AudioDevice] {
        return getAllDevices().filter { hasInputStreams($0.id) }
    }

    // MARK: - Get Device Name

    private func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var propertySize: UInt32 = 256
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceName: CFString = "" as CFString
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceName
        )

        if status != noErr {
            return nil
        }

        return deviceName as String
    }

    // MARK: - Check Device Streams

    private func hasOutputStreams(_ deviceID: AudioDeviceID) -> Bool {
        return getStreamCount(deviceID, scope: kAudioDevicePropertyScopeOutput) > 0
    }

    private func hasInputStreams(_ deviceID: AudioDeviceID) -> Bool {
        return getStreamCount(deviceID, scope: kAudioDevicePropertyScopeInput) > 0
    }

    private func getStreamCount(_ deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize
        )

        if status != noErr {
            return 0
        }

        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propertySize))
        defer { bufferList.deallocate() }

        let getStatus = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            bufferList
        )

        if getStatus != noErr {
            return 0
        }

        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        return buffers.reduce(0) { $0 + Int($1.mNumberChannels) }
    }

    // MARK: - Get Default Devices

    func getDefaultOutputDevice() -> AudioDeviceID? {
        return getDefaultDevice(scope: kAudioObjectPropertyScopeOutput)
    }

    func getDefaultInputDevice() -> AudioDeviceID? {
        return getDefaultDevice(scope: kAudioObjectPropertyScopeInput)
    }

    private func getDefaultDevice(scope: AudioObjectPropertyScope) -> AudioDeviceID? {
        var propertySize: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceID: AudioDeviceID = 0

        let selector = scope == kAudioObjectPropertyScopeOutput ?
            kAudioHardwarePropertyDefaultOutputDevice :
            kAudioHardwarePropertyDefaultInputDevice

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        if status != noErr {
            return nil
        }

        return deviceID
    }

    // MARK: - Set Default Devices

    func setDefaultOutputDevice(_ deviceID: AudioDeviceID) {
        setDefaultDevice(deviceID, scope: kAudioObjectPropertyScopeOutput)
    }

    func setDefaultInputDevice(_ deviceID: AudioDeviceID) {
        setDefaultDevice(deviceID, scope: kAudioObjectPropertyScopeInput)
    }

    private func setDefaultDevice(_ deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) {
        var deviceID = deviceID
        let propertySize: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)

        let selector = scope == kAudioObjectPropertyScopeOutput ?
            kAudioHardwarePropertyDefaultOutputDevice :
            kAudioHardwarePropertyDefaultInputDevice

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            propertySize,
            &deviceID
        )

        if status != noErr {
            print("Error setting default device: \(status)")
        } else {
            print("Successfully switched to device ID: \(deviceID)")
        }
    }

    // MARK: - Device Change Monitoring

    func startMonitoring() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            deviceChangeListener,
            nil
        )

        propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice
        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            deviceChangeListener,
            nil
        )

        propertyAddress.mSelector = kAudioHardwarePropertyDevices
        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            deviceChangeListener,
            nil
        )
    }
}

// Listener callback for device changes
private func deviceChangeListener(
    inObjectID: AudioObjectID,
    inNumberAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    inClientData: UnsafeMutableRawPointer?
) -> OSStatus {
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name("AudioDevicesChanged"), object: nil)
    }
    return noErr
}
