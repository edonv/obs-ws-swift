// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "obs-ws-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OBSWebSocket",
            targets: ["OBSWebSocket"]
        ),
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
            dependencies: []
        ),
        .testTarget(
            name: "OBSWebSocketTests",
            dependencies: ["OBSWebSocket"]
        ),
    ]
)
