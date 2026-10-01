import AppKit

struct InstalledApp: Identifiable, Hashable {
    var id: String { path }
    let name: String
    let bundleID: String
    let path: String
}

/// Finds installed applications in the standard locations, including browser
/// web apps such as Chrome PWAs stored below `~/Applications/Chrome Apps.localized`.
enum AppScanner {
    private static let searchDirectories = [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications",
    ]

    static func scan() -> [InstalledApp] {
        // Finder lives outside the Applications directories. Include only this
        // user-facing app, rather than exposing CoreServices helpers in the picker.
        scan(in: searchDirectories, including: ["/System/Library/CoreServices/Finder.app"])
    }

    /// Separated for deterministic tests with temporary application folders.
    static func scan(in directories: [String], including applicationPaths: [String] = []) -> [InstalledApp] {
        var seen: Set<String> = []
        var apps: [InstalledApp] = []

        for path in applicationPaths {
            if let app = installedApp(at: path), seen.insert(app.bundleID).inserted {
                apps.append(app)
            }
        }

        for directory in directories {
            let rootURL = URL(fileURLWithPath: directory, isDirectory: true)
            guard let enumerator = FileManager.default.enumerator(
                at: rootURL,
                includingPropertiesForKeys: [.isApplicationKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let url as URL in enumerator where url.pathExtension == "app" {
                if let app = installedApp(at: url.path), seen.insert(app.bundleID).inserted {
                    apps.append(app)
                }
            }
        }

        return apps.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    static func installedApp(at path: String) -> InstalledApp? {
        guard let bundle = Bundle(path: path),
              let bundleID = bundle.bundleIdentifier
        else { return nil }
        let name = FileManager.default.displayName(atPath: path)
            .replacingOccurrences(of: ".app", with: "")
        return InstalledApp(name: name, bundleID: bundleID, path: path)
    }
}
