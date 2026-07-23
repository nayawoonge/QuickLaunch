// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuickLaunch",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "QuickLaunch",
            path: "Sources/QuickLaunch",
            resources: [.process("Resources")]
        )
    ]
)
