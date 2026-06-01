// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hidden_logo",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "hidden-logo", targets: ["hidden_logo"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "hidden_logo",
            dependencies: [],
            resources: []
        )
    ]
)
