// swift-tools-version:6.2
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
var defaultSwiftSettings: [SwiftSetting] =
[
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0441-formalize-language-mode-terminology.md
    .swiftLanguageMode(.v6),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    // https://github.com/swiftlang/swift/pull/65218
    .enableExperimentalFeature("AvailabilityMacro=featherDatabase 1.0:macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0"),
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
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.0.0"),
        .package(url: "https://github.com/vapor/sqlite-nio", from: "1.0.0"),
        .package(url: "https://github.com/vapor/mysql-nio", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FeatherDatabase",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "SQLiteNIO", package: "sqlite-nio"),
                .product(name: "MySQLNIO", package: "mysql-nio"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FeatherDatabaseTests",
            dependencies: [
                .target(name: "FeatherDatabase"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
