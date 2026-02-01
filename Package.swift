// swift-tools-version: 6.0

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
        .systemLibrary(
            name: "CWhisper"
        ),
        .executableTarget(
            name: "OpenFlow",
            dependencies: ["CWhisper"],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "External/whisper.cpp/include",
                    "-I", "External/whisper.cpp/ggml/include"
                ])
            ],
            linkerSettings: [
                .linkedLibrary("whisper"),
                .unsafeFlags([
                    "-L", "External/whisper.cpp/build/src"
                ])
            ]
        ),
    ]
)
