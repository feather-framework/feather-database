//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging
import SQLiteNIO

public struct SQLiteQuery: Sendable {

    public var sql: String
    public var bindings: [SQLiteData]

    public init(
        unsafeSQL sql: String,
        bindings: [SQLiteData] = []
    ) {
        self.sql = sql
        self.bindings = bindings
    }
}

extension SQLiteQuery: DatabaseQuery {
    public typealias Bindings = [SQLiteData]
}

extension SQLiteQuery: ExpressibleByStringInterpolation {

    public init(stringInterpolation: StringInterpolation) {
        self.sql = stringInterpolation.sql
        self.bindings = stringInterpolation.binds
    }

    public init(stringLiteral value: String) {
        self.sql = value
        self.bindings = []
    }
}

extension SQLiteQuery {

    public struct StringInterpolation: StringInterpolationProtocol, Sendable {

        public typealias StringLiteralType = String

        @usableFromInline
        var sql: String

        @usableFromInline
        var binds: [SQLiteData]

        public init(
            literalCapacity: Int,
            interpolationCount: Int
        ) {
            self.sql = ""
            self.sql.reserveCapacity(literalCapacity)
            self.binds = []
            self.binds.reserveCapacity(interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            self.sql.append(contentsOf: literal)
        }

        @inlinable
        public mutating func appendInterpolation(_ value: Int) throws {
            self.binds.append(.integer(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: Double) throws {
            self.binds.append(.float(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: String) throws {
            self.binds.append(.text(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: SQLiteData) throws {
            self.binds.append(value)
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: SQLiteData?) throws {
            switch value {
            case .none:
                self.binds.append(.null)
            case .some(let value):
                self.binds.append(value)
            }

            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(unescaped interpolated: String)
        {
            self.sql.append(contentsOf: interpolated)
        }
    }

}

// MARK: -

extension SQLiteConnection: DatabaseConnection {

    public func run<T: DatabaseResult, Q: DatabaseQuery>(
        query: Q
    ) async throws -> T {
        print(query.sql)
        print(query.bindings)

        let result = try await self.query(
            query.sql,
            query.bindings as! [SQLiteData]
        )

        return SQLiteResultSequence(elements: result) as! T
    }
}

public struct SQLiteResultSequence: DatabaseResult {
    public typealias Element = SQLiteRow
    public typealias AsyncIterator = Iterator

    let elements: [Element]

    public struct Iterator: AsyncIteratorProtocol {
        var index = 0
        let elements: [Element]

        public mutating func next() async -> Element? {
            guard index < elements.count else {
                return nil
            }
            defer { index += 1 }
            return elements[index]
        }
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(elements: elements)
    }

    public func collect() async throws -> [Element] {
        elements
    }
}

extension SQLiteRow: DatabaseRow {

    public func decode<T: Decodable>(
        column: String,
        as type: T.Type
    ) throws -> T {
        guard let data = self.column(column) else {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription: "Missing data for column \(column)."
                )
            )
        }
        //        if data.isNull {
        //            return nil
        //        }
        if let type = type as? any SQLiteDataConvertible.Type {
            guard let value = type.init(sqliteData: data) as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [],
                        debugDescription:
                            "Could not convert data to \(T.self): \(data)."
                    )
                )
            }
            return value
        }
        throw DecodingError.typeMismatch(
            T.self,
            .init(
                codingPath: [],
                debugDescription: "Data is not convertible to \(type)."
            )
        )
    }
}

public struct SQLiteDatabase: Sendable {

    public var eventLoopGroup: EventLoopGroup =
        .singletonMultiThreadedEventLoopGroup
    public var connection: SQLiteConnection
    public var logger: Logger

    public init(
        connection: SQLiteConnection,
        logger: Logger
    ) {
        self.connection = connection
        self.logger = logger
    }
}

extension SQLiteDatabase: Database {

    public typealias Query = SQLiteQuery
    public typealias Result = SQLiteResultSequence

    public func connection(
        _ closure:
            nonisolated(nonsending)(any DatabaseConnection) async throws ->
            sending Result
    ) async throws -> sending Result {
        try await closure(connection)
    }

    public func transaction(
        _ closure:
            nonisolated(nonsending)(any DatabaseConnection) async throws ->
            sending Result
    ) async throws -> sending Result {
        // TODO: implement proper transaction
        try await closure(connection)
    }

    public func shutdown() async throws {
        try await connection.close()
    }
}
