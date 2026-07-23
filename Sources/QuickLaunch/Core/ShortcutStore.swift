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

    private let defaultsKey = "shortcuts"

    private init() {
        load()
        registerAll()
    }

    // MARK: - Hotkey registration

    func registerAll() {
        HotKeyManager.shared.unregisterAll()
        var failed: Set<UUID> = []
        for shortcut in shortcuts {
            let ok = HotKeyManager.shared.register(
                keyCode: UInt32(shortcut.keyCode),
                carbonModifiers: shortcut.carbonModifiers
            ) { [weak self] in
                self?.launch(shortcut)
            }
            if !ok { failed.insert(shortcut.id) }
        }
        failedShortcutIDs = failed
    }

    /// Temporarily release all hotkeys (used while recording a new combo).
    func suspendHotKeys() {
        HotKeyManager.shared.unregisterAll()
    }

    // MARK: - Launching

    func launch(_ shortcut: AppShortcut) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        let url = URL(fileURLWithPath: shortcut.appPath)
        if FileManager.default.fileExists(atPath: shortcut.appPath) {
            NSWorkspace.shared.openApplication(at: url, configuration: config)
        } else if let resolved = NSWorkspace.shared
            .urlForApplication(withBundleIdentifier: shortcut.bundleID) {
            // The app moved since it was registered; fall back to its bundle ID.
            NSWorkspace.shared.openApplication(at: resolved, configuration: config)
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

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([AppShortcut].self, from: data)
        else { return }
        shortcuts = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(shortcuts) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
