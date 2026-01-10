// swift-tools-version:6.2
import PackageDescription

var defaultSwiftSettings: [SwiftSetting] =
[
    .swiftLanguageMode(.v6),
//    .enableExperimentalFeature("AvailabilityMacro=featherDatabase 1.0:macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),

]

let package = Package(
    name: "feather-database",
    // NOTE: platfroms is needed because of dependencies, remove when remove pg & sqlite
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "FeatherDatabase", targets: ["FeatherDatabase"]),
        .library(name: "FeatherDatabaseTesting", targets: ["FeatherDatabaseTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
//        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.27.0"),
        .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.12.0"),
        .package(url: "https://github.com/vapor/async-kit", from: "1.21.0"),
    ],
    targets: [
        .target(
            name: "FeatherDatabase",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
//                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "SQLiteNIO", package: "sqlite-nio"),
                .product(name: "AsyncKit", package: "async-kit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "FeatherDatabaseTesting",
            dependencies: [
                .target(name: "FeatherDatabase"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FeatherDatabaseTests",
            dependencies: [
                .target(name: "FeatherDatabaseTesting"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
