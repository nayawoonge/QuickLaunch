import Foundation

private let appBundle: Bundle = {
    let bundleName = "QuickLaunch_QuickLaunch.bundle"

    // 1. App bundle: Contents/Resources/ (standard macOS location)
    if let url = Bundle.main.resourceURL?.appendingPathComponent(bundleName),
       let bundle = Bundle(url: url) {
        return bundle
    }
    // 2. SPM dev build: resource bundle next to executable
    let execDir = Bundle.main.bundleURL
    if let bundle = Bundle(url: execDir.appendingPathComponent(bundleName)) {
        return bundle
    }
    // 3. Fallback: main bundle directly (lproj files in Contents/Resources/)
    return Bundle.main
}()

func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: appBundle, comment: "")
}

enum PrefKey {
    static let showMenuBarIcon = "showMenuBarIcon"
    static let hideDockIcon = "hideDockIcon"
}
