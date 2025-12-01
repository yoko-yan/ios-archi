// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"]),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ImportObjcForwardDeclarations"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("DeprecateApplicationMain"),
    .enableUpcomingFeature("IsolatedDefaultValues"),
    .enableUpcomingFeature("GlobalConcurrency")
]

let package = Package(
    name: "Package",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "AnalyticsImpl",
            targets: ["AnalyticsImpl"]
        ),
        .library(
            name: "Macros",
            targets: ["Macros"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.4.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-prerelease-2025-04-10")
    ],
    targets: [
        .macro(
            name: "MacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Macros",
            dependencies: ["MacrosPlugin"]
        ),
        .target(
            name: "Core",
            dependencies: ["Macros"],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Analytics",
            dependencies: [
                "Macros"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "AnalyticsImpl",
            dependencies: [
                "Analytics",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "Core",
                "Analytics",
                "AnalyticsImpl",
                "Macros",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "Quick",
                "Nimble",
                "Macros"
            ],
            swiftSettings: swiftSettings
        )
    ]
)
