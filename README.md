# Feather Database

An abstract database component for Feather CMS.

## Getting started

### Adding the dependency

To add a dependency on the package, declare it in your `Package.swift`:

```swift
.package(url: "https://github.com/feather-framework/feather-database", exact: "1.0.0-beta.1"),
```

and to your application target, add `FeatherDatabase` to your dependencies:

```swift
.product(name: "FeatherDatabase", package: "feather-database")
```

Example `Package.swift` file with `FeatherDatabase` as a dependency:

```swift
// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "my-application",
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-database", exact: "1.0.0-beta.1"),
    ],
    targets: [
        .target(name: "MyApplication", dependencies: [
            .product(name: "FeatherDatabase", package: "feather-database")
        ]),
        .testTarget(name: "MyApplicationTests", dependencies: [
            .target(name: "MyApplication"),
        ]),
    ]
)
```


# Notes

- Avoid calling database.execute when you're in a transaction, use connection

