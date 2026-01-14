//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging
import PostgresNIO

extension PostgresQuery: DatabaseQuery {
    public typealias Bindings = PostgresBindings

    public var bindings: PostgresBindings { binds }
}

extension PostgresConnection: DatabaseConnection {
    
    public typealias Query = PostgresQuery
    public typealias Result = RowSequence

    @discardableResult
    public func execute(
        query: Query
    ) async throws -> Result {
        let result = try await self.query(
            .init(
                unsafeSQL: query.sql,
                binds: query.bindings
            ),
            logger: logger
        )
        return RowSequence(backingSequence: result)
    }
}

public struct RowSequence: DatabaseResult {
    public typealias Element = PostgresRow

    var backingSequence: PostgresRowSequence

    public struct AsyncIterator: AsyncIteratorProtocol {
        var backingIterator: PostgresRowSequence.AsyncIterator

        @concurrent
        public mutating func next() async throws -> Element? {
            guard !Task.isCancelled else {
                return nil
            }
            guard let postgresRow = try await backingIterator.next() else {
                return nil
            }
            return postgresRow
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            backingIterator: backingSequence.makeAsyncIterator(),
        )
    }

    public func collect() async throws -> [Element] {
        var items: [Element] = []
        for try await item in self {
            items.append(item)
        }
        return items
    }
}

extension PostgresRow: DatabaseRow {

    public func decode<T: Decodable>(
        column: String,
        as type: T.Type
    ) throws(DecodingError) -> T {
        let row = self.makeRandomAccess()
        guard row.contains(column) else {
            throw .dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Missing data for column \(column)."
                )
            )
        }
        let cell = row[column]
        if let type = type as? any PostgresDecodable.Type {
            do {
                guard let value = try cell.decode(type, context: .default) as? T
                else {
                    throw DecodingError.typeMismatch(
                        T.self,
                        .init(
                            codingPath: [],
                            debugDescription:
                                "Could not convert data to \(T.self)."
                        )
                    )
                }
                return value
            }
            catch {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [],
                        debugDescription: "\(error)"
                    )
                )
            }
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

public struct PostgresDatabase: Sendable {

    public var client: PostgresClient
    public var logger: Logger

    public init(
        client: PostgresClient,
        logger: Logger
    ) {
        self.client = client
        self.logger = logger
    }
}

extension PostgresDatabase: Database {
    public typealias Connection = PostgresConnection

    @discardableResult
    public func connection(
        _ closure:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result
    ) async throws -> sending Connection.Result {
        try await client.withConnection(closure)
    }

    @discardableResult
    public func transaction(
        _ closure:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result
    ) async throws -> sending Connection.Result {
        try await client.withTransaction(logger: logger, closure)
    }

    public func shutdown() async throws {
        // no need for this
    }
}
