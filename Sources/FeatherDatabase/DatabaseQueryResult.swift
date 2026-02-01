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
}
