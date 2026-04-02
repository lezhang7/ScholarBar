// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScholarBar",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "ScholarBar",
            path: "Sources/ScholarBar",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
