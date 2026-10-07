import Foundation

/// Independent pause reasons must all clear before global hotkeys are registered again.
struct HotKeySuspensionState: Equatable {
    var pauseInRemoteApps = true
    var isManuallyPaused = false
    var frontmostBundleID: String?
    var recordingSessions: Set<UUID> = []

    var isPausedForRemoteApp: Bool {
        pauseInRemoteApps && frontmostBundleID.map(Self.remoteAppBundleIDs.contains) == true
    }

    var isSuspended: Bool {
        isManuallyPaused || isPausedForRemoteApp || !recordingSessions.isEmpty
    }

    // Use bundle IDs, not localized display names or the names of guest operating systems.
    // Parallels runs guest windows in separate apps from its Control Center.
    private static let remoteAppBundleIDs: Set<String> = [
        "com.microsoft.rdc.macos", // Windows App / Microsoft Remote Desktop
        "com.parallels.desktop.console",
        "com.parallels.vm",
        "com.parallels.macvm",
        "com.vmware.fusion",
    ]
}
