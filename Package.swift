// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "obs-ws-swift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OBSWebSocket",
            targets: ["OBSWebSocket"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/edonv/JSONValue.git", from: "1.1.3"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.1"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.1"),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OBSWebSocket"
        ),
        // Generator CLI
        .executableTarget(
            name: "obs-ws-swift-generator",
            dependencies: [
                .product(name: "JSONValue", package: "JSONValue"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "OBSWebSocketTests",
            dependencies: ["OBSWebSocket"]
        ),
    ]
)
