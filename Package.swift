// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenFlow",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "OpenFlow",
            targets: ["OpenFlow"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "OpenFlow",
            dependencies: []
        ),
    ]
)
