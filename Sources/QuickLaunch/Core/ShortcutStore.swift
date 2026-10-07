import AppKit
import Combine

/// Owns the list of shortcuts: persistence (UserDefaults JSON),
/// hotkey (re)registration, and app launching.
final class ShortcutStore: ObservableObject {
    static let shared = ShortcutStore()

    @Published var shortcuts: [AppShortcut] = [] {
        didSet {
            save()
            registerAll()
        }
    }

    /// IDs of shortcuts whose hotkey registration was refused by the system.
    @Published private(set) var failedShortcutIDs: Set<UUID> = []

    @Published private var suspension = HotKeySuspensionState()

    var pauseInRemoteApps: Bool {
        get { suspension.pauseInRemoteApps }
        set {
            defaults.set(newValue, forKey: PrefKey.pauseInRemoteApps)
            updateSuspension { $0.pauseInRemoteApps = newValue }
        }
    }

    /// Session-only: restarting QuickLaunch clears a manual pause.
    var isManuallyPaused: Bool {
        get { suspension.isManuallyPaused }
        set { updateSuspension { $0.isManuallyPaused = newValue } }
    }

    var isPausedForRemoteApp: Bool { suspension.isPausedForRemoteApp }
    var areHotKeysPaused: Bool { suspension.isSuspended }

    private let defaults: UserDefaults
    private let hotKeyManager: HotKeyRegistering
    private let defaultsKey = "shortcuts"
    private var activationObserver: NSObjectProtocol?

    init(defaults: UserDefaults = .standard,
         hotKeyManager: HotKeyRegistering = HotKeyManager.shared,
         observeWorkspace: Bool = true) {
        self.defaults = defaults
        self.hotKeyManager = hotKeyManager
        suspension.pauseInRemoteApps = defaults.object(forKey: PrefKey.pauseInRemoteApps) as? Bool ?? true

        if observeWorkspace {
            suspension.frontmostBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
            activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                self?.updateFrontmostApplication(bundleID: app?.bundleIdentifier)
            }
        }

        if let data = defaults.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([AppShortcut].self, from: data) {
            shortcuts = decoded
        }
        registerAll()
    }

    deinit {
        if let activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(activationObserver)
        }
        hotKeyManager.unregisterAll()
    }

    // MARK: - Hotkey registration

    func registerAll() {
        // Skipping the handler alone is not enough: a registered Carbon hotkey still
        // consumes the combination before a remote desktop or VM can receive it.
        hotKeyManager.unregisterAll()
        guard !areHotKeysPaused else {
            failedShortcutIDs = []
            return
        }

        var failed: Set<UUID> = []
        for shortcut in shortcuts {
            let ok = hotKeyManager.register(
                keyCode: UInt32(shortcut.keyCode),
                carbonModifiers: shortcut.carbonModifiers
            ) { [weak self] in
                guard let self, !self.areHotKeysPaused else { return }
                self.launch(shortcut)
            }
            if !ok { failed.insert(shortcut.id) }
        }
        failedShortcutIDs = failed
    }

    func updateFrontmostApplication(bundleID: String?) {
        updateSuspension { $0.frontmostBundleID = bundleID }
    }

    /// Each recorder owns a pause so closing one cannot resume another recorder's keys.
    func beginRecordingHotKey() -> UUID {
        let session = UUID()
        updateSuspension { $0.recordingSessions.insert(session) }
        return session
    }

    func endRecordingHotKey(_ session: UUID) {
        updateSuspension { $0.recordingSessions.remove(session) }
    }

    private func updateSuspension(_ change: (inout HotKeySuspensionState) -> Void) {
        let wasSuspended = suspension.isSuspended
        var updated = suspension
        change(&updated)
        guard updated != suspension else { return }
        suspension = updated
        // Ordinary app switches do not needlessly release and re-register every key.
        if wasSuspended != updated.isSuspended {
            registerAll()
        }
    }

    // MARK: - Launching

    func launch(_ shortcut: AppShortcut) {
        Task { @MainActor in
            AppLauncher.shared.launch(shortcut)
        }
    }

    // MARK: - CRUD

    func add(_ shortcut: AppShortcut) {
        shortcuts.append(shortcut)
    }

    func update(_ shortcut: AppShortcut) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) else { return }
        shortcuts[index] = shortcut
    }

    func remove(_ shortcut: AppShortcut) {
        shortcuts.removeAll { $0.id == shortcut.id }
    }

    func isComboTaken(_ shortcut: AppShortcut) -> Bool {
        shortcuts.contains { $0.id != shortcut.id && $0.hasSameCombo(as: shortcut) }
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(shortcuts) else { return }
        defaults.set(data, forKey: defaultsKey)
    }
}
