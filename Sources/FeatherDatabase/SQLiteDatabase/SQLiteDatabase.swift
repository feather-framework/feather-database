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
        public mutating func appendInterpolation(_ value: String?) {
            switch value {
            case .some(let value):
                self.binds.append(.text(value))
                self.sql.append(contentsOf: "?")
            case .none:
                self.sql.append(contentsOf: "NULL")
            }
        }

        @inlinable
        public mutating func appendInterpolation(_ value: Int) {
            self.binds.append(.integer(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: Double) {
            self.binds.append(.float(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: String) {
            self.binds.append(.text(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(_ value: SQLiteData) {
            self.binds.append(value)
            self.sql.append(contentsOf: "?")
        }

        //        @inlinable
        //        public mutating func appendInterpolation(_ value: SQLiteData?) throws {
        //            switch value {
        //            case .none:
        //                self.binds.append(.null)
        //            case .some(let value):
        //                self.binds.append(value)
        //            }
        //
        //            self.sql.append(contentsOf: "?")
        //        }

        @inlinable
        public mutating func appendInterpolation(unescaped interpolated: String)
        {
            self.sql.append(contentsOf: interpolated)
        }
    }

}

// MARK: -

extension SQLiteConnection: DatabaseConnection {

    public typealias Query = SQLiteQuery
    public typealias Result = SQLiteResultSequence

    @discardableResult
    public func execute(
        query: Query
    ) async throws -> Result {
        print(query.sql)
        print(query.bindings)

        let result = try await self.query(
            query.sql,
            query.bindings
        )

        return SQLiteResultSequence(elements: result)
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

    struct SingleValueDecoder: Decoder, SingleValueDecodingContainer {

        var codingPath: [any CodingKey] { [] }
        var userInfo: [CodingUserInfoKey: Any] { [:] }

        let data: SQLiteData

        func container<Key: CodingKey>(
            keyedBy: Key.Type
        ) throws(DecodingError) -> KeyedDecodingContainer<Key> {
            throw DecodingError.typeMismatch(
                KeyedDecodingContainer<Key>.self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Keyed decoding is not supported."
                )
            )
        }

        func unkeyedContainer() throws(DecodingError)
            -> any UnkeyedDecodingContainer
        {
            throw DecodingError.typeMismatch(
                (any UnkeyedDecodingContainer).self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unkeyed decoding is not supported."
                )
            )
        }

        func singleValueContainer() throws(DecodingError)
            -> any SingleValueDecodingContainer
        {
            self
        }

        func decodeNil() -> Bool {
            data.isNull
        }

        func decode<T: Decodable>(
            _ type: T.Type
        ) throws(DecodingError) -> T {
            if let convertible = type as? any SQLiteDataConvertible.Type {
                guard let value = convertible.init(sqliteData: data) else {
                    throw DecodingError.typeMismatch(
                        T.self,
                        .init(
                            codingPath: codingPath,
                            debugDescription:
                                "Could not convert data to \(T.self): \(data)."
                        )
                    )
                }
                return value as! T
            }

            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                        "Data is not convertible to \(T.self): \(data)."
                )
            )
        }
    }

    public func decode<T: Decodable>(
        column: String,
        as type: T.Type
    ) throws(DecodingError) -> T {
        guard let data = self.column(column) else {
            throw .dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Missing data for column \(column)."
                )
            )
        }
        do {
            return try T(from: SingleValueDecoder(data: data))
        }
        catch let error as DecodingError {
            throw error
        }
        catch {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription:
                        "Data is not convertible to \(T.self): \(data)."
                )
            )
        }
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


public struct SQLiteTransactionError: DatabaseTransactionError {

    public let file: String
    public let line: UInt

    public var beginError: Error?
    public var closureError: Error?
    public var commitError: Error?
    public var rollbackError: Error?

    public init(
        file: String = #fileID,
        line: UInt = #line,
        beginError: Error? = nil,
        closureError: Error? = nil,
        commitError: Error? = nil,
        rollbackError: Error? = nil
    ) {
        self.file = file
        self.line = line
        self.beginError = beginError
        self.closureError = closureError
        self.commitError = commitError
        self.rollbackError = rollbackError
    }
}

extension SQLiteDatabase: Database {

    public typealias Connection = SQLiteConnection

    @discardableResult
    public func connection(
        _ closure:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result
    ) async throws -> sending Connection.Result {
        try await closure(connection)
    }

    @discardableResult
    public func transaction(
        _ closure:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result
    ) async throws -> sending Connection.Result {

        do {
            try await connection.execute(query: "BEGIN;")
        }
        catch {
            throw DatabaseError.transaction(
                SQLiteTransactionError(beginError: error)
            )
        }

        var closureHasFinished = false

        do {
            let result = try await closure(connection)
            closureHasFinished = true

            do {
                try await connection.execute(query: "COMMIT;")
            }
            catch {
                throw DatabaseError.transaction(
                    SQLiteTransactionError(commitError: error)
                )
            }

            return result
        }
        catch {
            var txError = SQLiteTransactionError()

            if !closureHasFinished {
                txError.closureError = error

                do {
                    try await connection.execute(query: "ROLLBACK;")
                }
                catch {
                    txError.rollbackError = error
                }
            }
            else {
                txError.commitError = error
            }

            throw DatabaseError.transaction(txError)
        }
    }

    public func shutdown() async throws {
        try await connection.close()
    }
}
