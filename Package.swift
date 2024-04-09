// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-database",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherDatabase", targets: ["FeatherDatabase"]),
        .library(name: "FeatherDatabaseTesting", targets: ["FeatherDatabaseTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-component", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/vapor/sql-kit", from: "3.0.0"),
        .package(url: "https://github.com/binarybirds/swift-nanoid", from: "1.0.0"),
        .package(url: "https://github.com/vapor/sqlite-kit", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sqlite-nio", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FeatherDatabase",
            dependencies: [
                .product(name: "FeatherComponent", package: "feather-component"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SQLKit", package: "sql-kit"),
                .product(name: "NanoID", package: "swift-nanoid"),
            ]
        ),
        .target(
            name: "FeatherDatabaseTesting",
            dependencies: [
                .target(name: "FeatherDatabase"),
            ]
        ),
        .testTarget(
            name: "FeatherDatabaseTests",
            dependencies: [
                .target(name: "FeatherDatabase"),
                .product(name: "SQLiteKit", package: "sqlite-kit"),
                .product(name: "SQLiteNIO", package: "sqlite-nio"),
            ]
        ),
        .testTarget(
            name: "FeatherDatabaseTestingTests",
            dependencies: [
                .target(name: "FeatherDatabaseTesting"),
            ]
        ),
    ]
)
