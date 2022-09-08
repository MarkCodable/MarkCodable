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
        // swift-markdown doesn't have semantic version tags
        // we should update the commit hash here from time to time.
        .package(
            url: "https://github.com/apple/swift-markdown.git",
            revision: "52563fc74a540b29854fde20e836b27394be2749"
        ),
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
