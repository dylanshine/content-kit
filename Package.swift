// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "content-kit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "content-kit",
            targets: ["content-kit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.41.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.2.0"),
    ],
    targets: [
        .target(
            name: "content-kit",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
            ]),
        .testTarget(
            name: "content-kitTests",
            dependencies: ["content-kit"]),
    ]
)
