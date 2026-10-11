// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

// Newer Flutter SDKs provide this sibling package; Flutter 3.24 links the
// framework through the app instead. Keep both integration layouts supported.
// Preserve the manifest's symlink path in Flutter's generated package directory.
let flutterFrameworkManifest = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("FlutterFramework/Package.swift")
let hasFlutterFramework = FileManager.default.fileExists(atPath: flutterFrameworkManifest.path)

let package = Package(
    name: "hidden_logo",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "hidden-logo", targets: ["hidden_logo"])
    ],
    dependencies: hasFlutterFramework ? [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ] : [],
    targets: [
        .target(
            name: "hidden_logo",
            dependencies: hasFlutterFramework ? [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ] : [],
            resources: []
        )
    ]
)
