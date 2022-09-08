// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "MarkCodable",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // The MarkCodable package offering the markdown codec.
        .library(
            name: "MarkCodable",
            targets: ["MarkCodable"]
        ),
        // A command line test app.
        .executable(
            name: "marktest",
            targets: [
                "MarkTestApp"
            ]
        ),
    ],
    dependencies: [
        // Using a fork for the faux semantic version.
        .package(url: "https://github.com/markcodable/swift-markdown.git", exact: "0.100.1"),
    ],
    targets: [
        .executableTarget(
            name: "MarkTestApp",
            dependencies: ["MarkCodable"]
        ),
        .target(
            name: "MarkCodable",
            dependencies: [.product(name: "Markdown", package: "swift-markdown")]
        ),
        .testTarget(
            name: "MarkCodableTests",
            dependencies: ["MarkCodable"]
        ),
    ]
)
