//
//  DatabaseQueryResult.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A result type returned from a database query.
///
/// Use this protocol to iterate rows asynchronously or collect them eagerly.
public protocol DatabaseQueryResult:
    AsyncSequence,
    Sendable
where
    Element == Row
{
    /// A row type produced by the query.
    ///
    /// This row must conform to `DatabaseRow` for decoding support.
    associatedtype Row: DatabaseRow

    /// Collect all rows from the sequence.
    ///
    /// This method consumes the sequence and returns all elements.
    /// - Throws: An error if iteration fails.
    /// - Returns: An array of all rows produced by the query.
    func collect() async throws -> [Element]

    /// Collect the first available row from the sequence.
    ///
    /// This method short-circuits after the first element is received.
    /// - Throws: An error if iteration fails.
    /// - Returns: The first row, or `nil` when the sequence is empty.
    func collectFirst() async throws -> Element?
}

extension DatabaseQueryResult {

    /// Collect the first available row from the sequence.
    ///
    /// This default implementation iterates until it finds the first element.
    /// - Throws: An error if iteration fails.
    /// - Returns: The first row, or `nil` when the sequence is empty.
    public func collectFirst() async throws -> Element? {
        for try await item in self {
            return item
        }
        return nil
    }
}
