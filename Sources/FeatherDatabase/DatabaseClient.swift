//
//  DatabaseClient.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A database client that manages connections and transactions.
///
/// Implementations provide convenience APIs for executing queries.
public protocol DatabaseClient: Sendable {

    /// The connection type used by this client.
    ///
    /// Use this to define the query and result types.
    associatedtype Connection: DatabaseConnection

    /// Execute work using a managed connection.
    ///
    /// The connection is provided to the closure for the duration of the call.
    /// - Parameter: closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if acquiring or using the connection fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func withConnection<T>(
        _ closure: (Connection) async throws -> T,
    ) async throws(DatabaseError) -> T

    /// Execute work inside a transaction.
    ///
    /// Implementations should wrap the closure in a transaction boundary.
    /// - Parameter: closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if the transaction fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func withTransaction<T>(
        _ closure: (Connection) async throws -> T,
    ) async throws(DatabaseError) -> T
}
