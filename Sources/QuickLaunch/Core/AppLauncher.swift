import AppKit
import OSLog

/// Opens apps normally, then makes their existing windows available again.
@MainActor
final class AppLauncher {
    static let shared = AppLauncher()

    private let logger = Logger(subsystem: "com.quicklaunch.app", category: "AppLauncher")
    private var latestRequest = UUID()

    func launch(_ shortcut: AppShortcut) {
        let request = UUID()
        latestRequest = request
        let previousApp = NSWorkspace.shared.frontmostApplication
        let savedURL = URL(fileURLWithPath: shortcut.appPath)
        guard let url = FileManager.default.fileExists(atPath: savedURL.path)
            ? savedURL
            : NSWorkspace.shared.urlForApplication(withBundleIdentifier: shortcut.bundleID)
        else { return }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        config.createsNewApplicationInstance = false

        Task {
            do {
                // Keep the normal open/reopen event: apps with no windows can
                // create one, and browser web apps keep their usual launch path.
                let app = try await NSWorkspace.shared.openApplication(at: url, configuration: config)
                guard shouldContinue(request, app: app, previousApp: previousApp) else { return }
                bringForward(app)

                guard UserDefaults.standard.bool(forKey: PrefKey.restoreMinimizedWindows),
                      WindowRestorer.hasPermission else { return }
                let pid = app.processIdentifier
                // Accessibility reads can block when another app is unresponsive.
                let window = await Task.detached(priority: .userInitiated) {
                    WindowRestorer.preferredWindow(processIdentifier: pid)
                }.value

                guard shouldContinue(request, app: app, previousApp: previousApp),
                      UserDefaults.standard.bool(forKey: PrefKey.restoreMinimizedWindows),
                      WindowRestorer.hasPermission,
                      let window else { return }
                WindowRestorer.restoreAndRaise(window)
                bringForward(app)
            } catch {
                logger.error("Unable to open app: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func bringForward(_ app: NSRunningApplication) {
        app.unhide()
        if NSApp.isActive {
            NSApp.yieldActivation(to: app)
            app.activate(from: .current, options: [.activateAllWindows])
        } else {
            app.activate(options: [.activateAllWindows])
        }
    }

    private func shouldContinue(_ request: UUID, app: NSRunningApplication,
                                previousApp: NSRunningApplication?) -> Bool {
        guard request == latestRequest, !app.isTerminated else { return false }
        let frontmost = NSWorkspace.shared.frontmostApplication
        // Do not raise an old target after another hotkey or a manual app switch.
        return frontmost == nil || frontmost == app || frontmost == previousApp
            || frontmost == NSRunningApplication.current
    }
}
