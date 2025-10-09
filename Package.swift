// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MouseToucher",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MouseToucherLib",
            targets: ["MouseToucherLib"]
        )
    ],
    targets: [
        .target(
            name: "MouseToucherLib",
            dependencies: [],
            path: "Sources",
            sources: ["TapDetector.swift", "AppDelegate.swift"]
        ),
        .testTarget(
            name: "MouseToucherTests",
            dependencies: ["MouseToucherLib"],
            path: "Tests"
        )
    ]
)
