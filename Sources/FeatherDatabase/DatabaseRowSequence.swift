//
//  DatabaseRowSequence.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A sequence returned from a database query.
///
/// Use this protocol to iterate rows asynchronously or collect them eagerly.
public protocol DatabaseRowSequence:
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
}
