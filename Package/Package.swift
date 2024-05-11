// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Package",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "AnalyticsImpl",
            targets: ["AnalyticsImpl"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.4.0"))
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"]),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("DeprecateApplicationMain")
            ]
        ),
        .target(
            name: "Analytics",
            dependencies: [
                "Core"
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"]),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("DeprecateApplicationMain")
            ]
        ),
        .target(
            name: "AnalyticsImpl",
            dependencies: [
                "Analytics",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"]),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("DeprecateApplicationMain")
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "Core",
                "Analytics",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"]),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("DeprecateApplicationMain")
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "Quick",
                "Nimble"
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"]),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("DeprecateApplicationMain")
            ]
        )
    ]
)
