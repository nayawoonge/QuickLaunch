import AppKit

struct InstalledApp: Identifiable, Hashable {
    var id: String { path }
    let name: String
    let bundleID: String
    let path: String
}

/// Finds installed applications in the standard locations.
enum AppScanner {
    private static let searchDirectories = [
        "/Applications",
        "/Applications/Utilities",
        "/System/Applications",
        "/System/Applications/Utilities",
        NSHomeDirectory() + "/Applications",
    ]

    static func scan() -> [InstalledApp] {
        var seen: Set<String> = []
        var apps: [InstalledApp] = []

        for directory in searchDirectories {
            let entries = (try? FileManager.default
                .contentsOfDirectory(atPath: directory)) ?? []
            for entry in entries where entry.hasSuffix(".app") {
                let path = directory + "/" + entry
                if let app = installedApp(at: path), seen.insert(app.bundleID).inserted {
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
