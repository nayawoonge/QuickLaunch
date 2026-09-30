import AppKit
import ApplicationServices

enum WindowRestorer {
    struct WindowState {
        let isMinimized: Bool?
        let isFocused: Bool
        let isMain: Bool
    }

    static var hasPermission: Bool { AXIsProcessTrusted() }

    /// Called only from the explicit permission button, never by a hotkey.
    static func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// Prefer an existing unminimized window. If every known window is minimized,
    /// restore just one, favoring the focused/main window when the app reports it.
    static func preferredIndex(in windows: [WindowState]) -> Int? {
        let visible = windows.indices.filter { windows[$0].isMinimized == false }
        let candidates = visible.isEmpty
            ? windows.indices.filter { windows[$0].isMinimized == true }
            : visible
        return candidates.first { windows[$0].isFocused }
            ?? candidates.first { windows[$0].isMain }
            ?? candidates.first
    }

    static func preferredWindow(processIdentifier: pid_t) -> AXUIElement? {
        guard hasPermission, processIdentifier > 0 else { return nil }
        let app = AXUIElementCreateApplication(processIdentifier)
        AXUIElementSetMessagingTimeout(app, 0.2)
        guard let windows = attribute(kAXWindowsAttribute, of: app) as? [AXUIElement]
        else { return nil }
        let focused = attribute(kAXFocusedWindowAttribute, of: app)
        let main = attribute(kAXMainWindowAttribute, of: app)
        let deadline = ProcessInfo.processInfo.systemUptime + 1
        var states: [WindowState] = []
        for window in windows {
            // Bound both per-message latency and the full scan of an unresponsive app.
            guard ProcessInfo.processInfo.systemUptime < deadline else { return nil }
            AXUIElementSetMessagingTimeout(window, 0.2)
            states.append(WindowState(
                isMinimized: attribute(kAXMinimizedAttribute, of: window) as? Bool,
                isFocused: focused.map { CFEqual($0, window) } ?? false,
                isMain: main.map { CFEqual($0, window) } ?? false
            ))
        }
        guard let index = preferredIndex(in: states) else { return nil }
        return windows[index]
    }

    static func restoreAndRaise(_ window: AXUIElement) {
        guard hasPermission else { return }
        if attribute(kAXMinimizedAttribute, of: window) as? Bool == true {
            guard AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString,
                                              kCFBooleanFalse) == .success else { return }
        }
        AXUIElementPerformAction(window, kAXRaiseAction as CFString)
    }

    private static func attribute(_ name: String, of element: AXUIElement) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success
        else { return nil }
        return value
    }
}
