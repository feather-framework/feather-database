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
    /// - Parameters:
    ///   - isolation: The actor isolation to use for the duration of the call.
    ///   - closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if acquiring or using the connection fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func connection<T>(
        isolation: isolated (any Actor)?,
        _ closure: (Connection) async throws(DatabaseError) -> sending T,
    ) async throws(DatabaseError) -> sending T

    /// Execute work inside a transaction.
    ///
    /// Implementations should wrap the closure in a transaction boundary.
    /// - Parameters:
    ///   - isolation: The actor isolation to use for the duration of the call.
    ///   - closure: A closure that receives a connection and returns a result.
    /// - Throws: A `DatabaseError` if the transaction fails.
    /// - Returns: The result returned by the closure.
    @discardableResult
    func transaction<T>(
        isolation: isolated (any Actor)?,
        _ closure: (Connection) async throws(DatabaseError) -> sending T,
    ) async throws(DatabaseError) -> sending T

    /// Execute a query using a managed connection.
    ///
    /// This is a convenience wrapper around `connection(_:)`.
    /// - Parameters:
    ///   - isolation: The actor isolation to use for the duration of the call.
    ///   - query: The query to execute.
    ///   - handler: A closure that transforms the result into a generic value.
    /// - Throws: A `DatabaseError` if execution fails.
    /// - Returns: The query result.
    @discardableResult
    func execute<T>(
        isolation: isolated (any Actor)?,
        query: Connection.Query,
        _ handler:
            @Sendable (Connection.Result) async throws -> T
    ) async throws(DatabaseError) -> T

    func execute(
        isolation: isolated (any Actor)?,
        query: Connection.Query
    ) async throws(DatabaseError)

}

extension DatabaseClient {

    /// Execute a query using a managed connection.
    ///
    /// This default implementation executes the query inside `connection(_:)`.
    /// - Parameters:
    ///   - isolation: The actor isolation to use for the duration of the call.
    ///   - query: The query to execute.
    ///   - handler: A closure that transforms the result into a generic value.
    /// - Throws: A `DatabaseError` if execution fails.
    /// - Returns: The query result.
    @discardableResult
    public func execute<T>(
        isolation: isolated (any Actor)? = #isolation,
        query: Connection.Query,
        _ handler:
            @Sendable (Connection.Result) async throws -> T
    ) async throws(DatabaseError) -> T {
        try await connection(isolation: isolation) {
            connection async throws(DatabaseError) in
            do {
                return try await connection.execute(query: query, handler)
            }
            catch let error as DatabaseError {
                throw error
            }
            catch {
                throw .result(error)
            }
        }
    }

    public func execute(
        isolation: isolated (any Actor)? = #isolation,
        query: Connection.Query
    ) async throws(DatabaseError) {
        try await execute(isolation: isolation, query: query, { _ in })
    }
}
