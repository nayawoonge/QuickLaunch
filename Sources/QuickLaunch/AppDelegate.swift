import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) static var shared: AppDelegate!

    private var mainWindow: NSWindow?

    func applicationWillFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        applyActivationPolicy()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = ShortcutStore.shared // load + register hotkeys
        showMainWindow()
    }

    /// Launching the app again while it is running (the escape hatch when both
    /// the menu bar icon and the Dock icon are hidden) lands here.
    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows: Bool) -> Bool {
        showMainWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false // keep hotkeys alive with no windows open
    }

    // MARK: - Main window

    func showMainWindow() {
        if mainWindow == nil {
            let hosting = NSHostingController(rootView: ContentView())
            let window = NSWindow(contentViewController: hosting)
            window.title = L("app.name")
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 540, height: 620))
            window.center()
            mainWindow = window
        }
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Dock icon visibility

    func applyActivationPolicy() {
        let hideDock = UserDefaults.standard.bool(forKey: PrefKey.hideDockIcon)
        NSApp.setActivationPolicy(hideDock ? .accessory : .regular)
        // Switching policy can drop key-window status; restore it.
        if mainWindow?.isVisible == true {
            NSApp.activate(ignoringOtherApps: true)
            mainWindow?.makeKeyAndOrderFront(nil)
        }
    }
}
