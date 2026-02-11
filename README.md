# Feather Database

Abstract database component, providing a shared API surface for database drivers written in Swift.

[![Release: 1.0.0-beta.5](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E5-F05138)](https://github.com/feather-framework/feather-database/releases/tag/1.0.0-beta.5)

## Features

- Database-agnostic abstraction layer
- Designed for modern Swift concurrency
- DocC-based API Documentation
- Unit tests and code coverage

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: Linux, macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-Linux_%7C_macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)

- Swift 6.1+

- Platforms:
  - Linux
  - macOS 15+
  - iOS 18+
  - tvOS 18+
  - watchOS 11+
  - visionOS 2+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/feather-framework/feather-database", exact: "1.0.0-beta.5"),
```

Then add `FeatherDatabase` to your target dependencies:

```swift
.product(name: "FeatherDatabase", package: "feather-database"),
```

## Usage

[![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)](https://feather-framework.github.io/feather-database/)

API documentation is available at the following link. Refer to the mock objects in the Tests directory if you want to build a custom database driver implementation.

> [!WARNING]  
> This repository is a work in progress, things can break until it reaches v1.0.0.

## Database drivers

The following database driver implementations are available for use:

- [SQLite](https://github.com/feather-framework/feather-sqlite-database)
- [Postgres](https://github.com/feather-framework/feather-postgres-database)
- [MySQL](https://github.com/feather-framework/feather-mysql-database)

## Development

- Build: `swift build`
- Test:
  - local: `swift test`
  - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/feather-framework/feather-database/pulls) are welcome. Please keep changes focused and include tests for new logic.
