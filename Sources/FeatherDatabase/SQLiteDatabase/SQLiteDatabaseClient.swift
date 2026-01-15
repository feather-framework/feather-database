//
//  SQLiteDatabaseClient.swift
//  Feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging
import SQLiteNIO
import ServiceLifecycle

/// A SQLite-backed database client.
///
/// Use this client to execute queries and manage transactions on SQLite.
public struct SQLiteDatabaseClient: DatabaseClient {

    var connection: SQLiteConnection
    var logger: Logger

    /// Create a SQLite database client.
    ///
    /// Use this initializer to provide an already-open connection.
    /// - Parameters:
    ///   - connection: The SQLite connection to use.
    ///   - logger: The logger for database operations.
    public init(
        connection: SQLiteConnection,
        logger: Logger
    ) {
        self.connection = connection
        self.logger = logger
    }

    // MARK: - database api

    /// Execute work using the stored connection.
    ///
    /// The closure is executed with the current connection.
    /// - Parameter closure: A closure that receives the SQLite connection.
    /// - Throws: A `DatabaseError` if the connection fails.
    /// - Returns: The query result produced by the closure.
    @discardableResult
    public func connection(
        _ closure: nonisolated(nonsending)(SQLiteConnection) async throws
            -> sending SQLiteQueryResult
    ) async throws(DatabaseError) -> sending SQLiteQueryResult {
        do {
            return try await closure(connection)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .connection(error)
        }
    }

    /// Execute work inside a SQLite transaction.
    ///
    /// The closure runs between `BEGIN` and `COMMIT` with rollback on failure.
    /// - Parameter closure: A closure that receives the SQLite connection.
    /// - Throws: A `DatabaseError` if transaction handling fails.
    /// - Returns: The query result produced by the closure.
    @discardableResult
    public func transaction(
        _ closure: nonisolated(nonsending)(SQLiteConnection) async throws
            -> sending SQLiteQueryResult
    ) async throws(DatabaseError) -> sending SQLiteQueryResult {

        do {
            try await connection.execute(query: "BEGIN;")
        }
        catch {
            throw DatabaseError.transaction(
                SQLiteTransactionError(beginError: error)
            )
        }

        var closureHasFinished = false

        do {
            let result = try await closure(connection)
            closureHasFinished = true

            do {
                try await connection.execute(query: "COMMIT;")
            }
            catch {
                throw DatabaseError.transaction(
                    SQLiteTransactionError(commitError: error)
                )
            }

            return result
        }
        catch {
            var txError = SQLiteTransactionError()

            if !closureHasFinished {
                txError.closureError = error

                do {
                    try await connection.execute(query: "ROLLBACK;")
                }
                catch {
                    txError.rollbackError = error
                }
            }
            else {
                txError.commitError = error
            }

            throw DatabaseError.transaction(txError)
        }
    }
}
