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
public protocol DatabaseConnection {

    /// The query type supported by this connection.
    ///
    /// Use this to define the SQL and bindings type.
    associatedtype Query: DatabaseQuery
    /// The query result type produced by this connection.
    ///
    /// The result must conform to `DatabaseQueryResult`.
    associatedtype Result: DatabaseQueryResult

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
        _ handler: (Result.Row) async throws -> T
    ) async throws(DatabaseError) -> [T]

    func run(
        query: Query,
        _ handler: (Result.Row) async throws -> Void
    ) async throws(DatabaseError)
}
