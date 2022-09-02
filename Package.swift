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
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "MarkTestApp",
            dependencies: [
                "MarkCodable"
            ]),
        .target(
            name: "MarkCodable",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ]),
        .testTarget(
            name: "MarkCodableTests",
            dependencies: ["MarkCodable"]
        ),
    ]
)
