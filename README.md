# Feather Database

Abstract database component, providing a shared API surface for database drivers written in Swift.

![Release: 1.0.0-beta.1](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E1-F05138)

## Features



- 🤝 Database-agnostic abstraction layer
- 🔀 Designed for modern Swift concurrency
- 📚 API Documentation is available using DocC
- ✅ Code coverage and unit tests

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: Linux, macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-Linux_%7C_macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)
        
- Swift 6.1+
- Swift Package Manager
- Platforms: 
    - Linux
    - macOS 15+
    - iOS 18+
    - tvOS 18+
    - watchOS 11+
    - visionOS 2+

## Installation

Add the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/feather-framework/feather-database", exact: "1.0.0-beta.1")
```

Then add `FeatherDatabase` to your target dependencies:

```swift
.product(name: "FeatherDatabase", package: "feather-database")
```

## Usage

![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)

> [!TIP]
> Avoid calling `database.execute` while in a transaction; use the transaction `connection` instead.

> [!WARNING]  
> This repository is a work in progress, things can break until it reaches v1.0.0.

## Development

- Build: `swift build`
- Test: `swift test`
- Format: `make format`
- Check: `make check`

## Contributing

Pull requests are welcome. Please keep changes focused and include tests for new logic.
