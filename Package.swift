// swift-tools-version: 5.6

import PackageDescription

#if compiler(>=5.7)
let swiftMarkdownVersion = "release/5.7"
#elseif compiler(>=5.6)
let swiftMarkdownVersion = "release/5.6"
#else
fatalError("This version of MarkCodable requires Swift >= 5.6.")
#endif

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
        .package(url: "https://github.com/apple/swift-markdown.git", branch: swiftMarkdownVersion),
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
