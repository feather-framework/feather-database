//
//  PostgresQueryResult.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import PostgresNIO

/// A query result backed by a Postgres row sequence.
///
/// Use this type to iterate or collect Postgres query results.
public struct PostgresQueryResult: DatabaseQueryResult {

    var backingSequence: PostgresRowSequence

    /// An async iterator over Postgres rows.
    ///
    /// This iterator pulls rows from the backing sequence.
    public struct AsyncIterator: AsyncIteratorProtocol {
        var backingIterator: PostgresRowSequence.AsyncIterator

        @concurrent
        /// Return the next row in the sequence.
        ///
        /// This stops when the sequence ends or the task is cancelled.
        /// - Throws: An error if the underlying sequence fails.
        /// - Returns: The next `PostgresRow`, or `nil` when finished.
        public mutating func next() async throws -> PostgresRow? {
            guard !Task.isCancelled else {
                return nil
            }
            guard let postgresRow = try await backingIterator.next() else {
                return nil
            }
            return postgresRow
        }
    }

    /// Create an async iterator over the result rows.
    ///
    /// Use this to iterate the result as an `AsyncSequence`.
    /// - Returns: An iterator over the result rows.
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            backingIterator: backingSequence.makeAsyncIterator(),
        )
    }

    /// Collect all rows into an array.
    ///
    /// This consumes the sequence and returns all rows.
    /// - Throws: An error if iteration fails.
    /// - Returns: An array of `PostgresRow` values.
    public func collect() async throws -> [PostgresRow] {
        var items: [PostgresRow] = []
        for try await item in self {
            items.append(item)
        }
        return items
    }
}
