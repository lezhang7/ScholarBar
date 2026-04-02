// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScholarCite",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "ScholarCite",
            path: "Sources/ScholarCite",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
