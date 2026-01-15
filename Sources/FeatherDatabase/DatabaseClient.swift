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
#if compiler(>=6.2)
    /// Execute work using a managed connection.
    ///
    /// The connection is provided to the closure for the duration of the call.
    /// - Parameter closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if acquiring or using the connection fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func connection(
        _ closure: nonisolated(nonsending)(Connection) async throws ->
            sending Connection.Result,
    ) async throws(DatabaseError) -> sending Connection.Result

    /// Execute work inside a transaction.
    ///
    /// Implementations should wrap the closure in a transaction boundary.
    /// - Parameter closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if the transaction fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func transaction(
        _ closure: nonisolated(nonsending)(Connection) async throws ->
            sending Connection.Result,
    ) async throws(DatabaseError) -> sending Connection.Result
#else
    /// Execute work using a managed connection.
    ///
    /// The connection is provided to the closure for the duration of the call.
    /// - Parameter closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if acquiring or using the connection fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func connection(
        _ closure: (Connection) async throws -> Connection.Result,
    ) async throws(DatabaseError) -> Connection.Result

    /// Execute work inside a transaction.
    ///
    /// Implementations should wrap the closure in a transaction boundary.
    /// - Parameter closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if the transaction fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func transaction(
        _ closure: (Connection) async throws -> Connection.Result,
    ) async throws(DatabaseError) -> Connection.Result
#endif
    /// Execute a query using a managed connection.
    ///
    /// This is a convenience wrapper around `connection(_:)`.
    /// - Parameter query: The query to execute.
    /// - Throws: A `DatabaseError` if execution fails.
    /// - Returns: The query result.
    @discardableResult
    func execute(
        query: Connection.Query,
    ) async throws(DatabaseError) -> Connection.Result

}

extension DatabaseClient {

    /// Execute a query using a managed connection.
    ///
    /// This default implementation executes the query inside `connection(_:)`.
    /// - Parameter query: The query to execute.
    /// - Throws: A `DatabaseError` if execution fails.
    /// - Returns: The query result.
    @discardableResult
    public func execute(
        query: Connection.Query,
    ) async throws(DatabaseError) -> Connection.Result {
        try await connection { connection in
            try await connection.execute(query: query)
        }
    }
}
