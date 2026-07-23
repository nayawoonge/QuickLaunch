import Foundation

/// Shorthand for localized strings from the package resource bundle.
func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

enum PrefKey {
    static let showMenuBarIcon = "showMenuBarIcon"
    static let hideDockIcon = "hideDockIcon"
}
