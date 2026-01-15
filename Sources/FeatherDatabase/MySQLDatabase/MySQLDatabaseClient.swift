//
//  MySQLDatabaseClient.swift
//  Feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging
import MySQLNIO
import ServiceLifecycle

/// A MySQL-backed database client.
///
/// Use this client to execute queries and manage transactions on MySQL.
public struct MySQLDatabaseClient: DatabaseClient {

    var connection: MySQLConnection
    var logger: Logger

    /// Create a MySQL database client.
    ///
    /// Use this initializer to provide an already-open connection.
    /// - Parameters:
    ///   - connection: The MySQL connection to use.
    ///   - logger: The logger for database operations.
    public init(
        connection: MySQLConnection,
        logger: Logger
    ) {
        self.connection = connection
        self.logger = logger
    }

    // MARK: - database api

    /// Execute work using the stored connection.
    ///
    /// The closure is executed with the current connection.
    /// - Parameter closure: A closure that receives the MySQL connection.
    /// - Throws: A `DatabaseError` if the connection fails.
    /// - Returns: The query result produced by the closure.
    @discardableResult
    public func connection(
        _ closure:
            nonisolated(nonsending)(MySQLConnection) async throws
            -> sending MySQLQueryResult
    ) async throws(DatabaseError) -> sending MySQLQueryResult {
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

    /// Execute work inside a MySQL transaction.
    ///
    /// The closure runs between `START TRANSACTION` and `COMMIT` with rollback on failure.
    /// - Parameter closure: A closure that receives the MySQL connection.
    /// - Throws: A `DatabaseError` if transaction handling fails.
    /// - Returns: The query result produced by the closure.
    @discardableResult
    public func transaction(
        _ closure:
            nonisolated(nonsending)(MySQLConnection) async throws
            -> sending MySQLQueryResult
    ) async throws(DatabaseError) -> sending MySQLQueryResult {

        do {
            try await connection.execute(query: "START TRANSACTION;")
        }
        catch {
            throw DatabaseError.transaction(
                MySQLTransactionError(beginError: error)
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
                    MySQLTransactionError(commitError: error)
                )
            }

            return result
        }
        catch {
            var txError = MySQLTransactionError()

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
