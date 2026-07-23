import Foundation
import Carbon.HIToolbox

/// A single "hotkey → app" mapping, persisted as JSON in UserDefaults.
struct AppShortcut: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var appName: String
    var bundleID: String
    var appPath: String
    var keyCode: UInt16
    var carbonModifiers: UInt32
    var keyDisplay: String

    /// e.g. "⌃⌥⇧⌘A"
    var displayString: String { modifierSymbols + keyDisplay }

    var modifierSymbols: String {
        var s = ""
        if carbonModifiers & UInt32(controlKey) != 0 { s += "⌃" }
        if carbonModifiers & UInt32(optionKey) != 0 { s += "⌥" }
        if carbonModifiers & UInt32(shiftKey) != 0 { s += "⇧" }
        if carbonModifiers & UInt32(cmdKey) != 0 { s += "⌘" }
        return s
    }

    func hasSameCombo(as other: AppShortcut) -> Bool {
        keyCode == other.keyCode && carbonModifiers == other.carbonModifiers
    }
}
