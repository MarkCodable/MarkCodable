// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "mark-codable",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .executable(
            name: "marktest",
            targets: [
                "MarkTestApp"
            ]
        ),
        .library(
            name: "MarkCodable",
            targets: ["MarkCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", revision: "d6cd065a7e4b6c3fad615dcd39890e095a2f63a2")
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
