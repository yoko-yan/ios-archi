// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-archi",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        )
    ]
)
