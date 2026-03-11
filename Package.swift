// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MagicTap",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MagicTapLib",
            targets: ["MagicTapLib"]
        )
    ],
    targets: [
        .target(
            name: "MagicTapLib",
            dependencies: [],
            path: "Sources",
            sources: ["TapDetector.swift", "AppDelegate.swift"]
        ),
        .testTarget(
            name: "MagicTapTests",
            dependencies: ["MagicTapLib"],
            path: "Tests"
        )
    ]
)
