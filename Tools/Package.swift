// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.54.0"),
        .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.2.4"),
    ]
)
