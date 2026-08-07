import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) static var shared: AppDelegate!

    func applicationWillFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        applyActivationPolicy()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = ShortcutStore.shared // load + register hotkeys

        // Give SwiftUI a run-loop cycle to set up the Window scene,
        // then make sure it is visible and the app is active.
        DispatchQueue.main.async {
            self.openMainWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows: Bool) -> Bool {
        openMainWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Window helpers

    func openMainWindow() {
        // Find the SwiftUI-managed main window and bring it forward.
        if let window = NSApp.windows.first(where: {
            $0.identifier?.rawValue.contains("main") == true
                || $0.title == L("app.name")
        }) {
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Dock icon visibility

    func applyActivationPolicy() {
        let hideDock = UserDefaults.standard.bool(forKey: PrefKey.hideDockIcon)
        NSApp.setActivationPolicy(hideDock ? .accessory : .regular)
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
