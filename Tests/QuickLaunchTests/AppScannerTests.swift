import Foundation
import XCTest
@testable import QuickLaunch

final class AppScannerTests: XCTestCase {
    func testFindsBrowserWebAppInNestedLocalizedDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let appURL = root
            .appendingPathComponent("Chrome Apps.localized", isDirectory: true)
            .appendingPathComponent("YouTube Music.app", isDirectory: true)
        let contentsURL = appURL.appendingPathComponent("Contents", isDirectory: true)
        try FileManager.default.createDirectory(
            at: contentsURL,
            withIntermediateDirectories: true
        )

        let info: [String: Any] = [
            "CFBundleIdentifier": "com.google.Chrome.app.youtube-music-test",
            "CFBundleName": "YouTube Music",
            "CFBundlePackageType": "APPL",
        ]
        let plist = try PropertyListSerialization.data(
            fromPropertyList: info,
            format: .xml,
            options: 0
        )
        try plist.write(to: contentsURL.appendingPathComponent("Info.plist"))

        let apps = AppScanner.scan(in: [root.path])

        XCTAssertEqual(apps.count, 1)
        XCTAssertEqual(apps.first?.name, "YouTube Music")
        XCTAssertEqual(apps.first?.bundleID, "com.google.Chrome.app.youtube-music-test")
        XCTAssertEqual(
            apps.first.map { URL(fileURLWithPath: $0.path).resolvingSymlinksInPath() },
            appURL.resolvingSymlinksInPath()
        )
    }
}
