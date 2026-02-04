//
//  DatabaseConnection.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging

/// A connection that can execute database queries.
///
/// Implementations provide query execution and lifecycle management.
public protocol DatabaseConnection: Sendable {

    /// The query type supported by this connection.
    ///
    /// Use this to define the SQL and bindings type.
    associatedtype Query: DatabaseQuery

    /// The row sequence type produced by this connection.
    ///
    /// The result must conform to `DatabaseRowSequence`.
    associatedtype RowSequence: DatabaseRowSequence

    /// The logger used for connection operations.
    ///
    /// This is used to record database-related diagnostics.
    var logger: Logger { get }

    /// Runs a query using the database connection.
    ///
    /// - Parameters:
    ///  - query: The query to execute.
    ///  - handler: A closure that transforms the result into a generic value.
    /// - Throws: A `DatabaseError` if execution fails.
    /// - Returns: The result of the query execution.
    @discardableResult
    func run<T: Sendable>(
        query: Query,
        _ handler: (RowSequence) async throws -> T
    ) async throws(DatabaseError) -> T
}
