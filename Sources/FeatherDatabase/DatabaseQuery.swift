//
//  DatabaseQuery.swift
//  Feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A query description with SQL text and bindings.
///
/// Conforming types provide a query string and its bound parameters.
public protocol DatabaseQuery: Sendable {
    /// The bindings type associated with this query.
    ///
    /// Use a `Sendable` type that represents bind parameters.
    associatedtype Bindings: Sendable

    /// The SQL text to execute.
    ///
    /// This is the raw SQL string for the query.
    var sql: String { get }
    /// The bound parameters for the SQL text.
    ///
    /// These bindings are passed alongside `sql`.
    var bindings: Bindings { get }
}
