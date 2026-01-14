import Logging
import SQLiteNIO
import ServiceLifecycle

public struct SQLiteDatabaseClient: DatabaseClient {
    
    var connection: SQLiteConnection
    var logger: Logger

    public init(
        connection: SQLiteConnection,
        logger: Logger
    ) {
        self.connection = connection
        self.logger = logger
    }

    // MARK: - database api

    @discardableResult
    public func connection(
        _ closure:
            nonisolated(nonsending)(SQLiteConnection) async throws ->
        sending SQLiteQueryResult
    ) async throws -> sending SQLiteQueryResult {
        try await closure(connection)
    }

    @discardableResult
    public func transaction(
        _ closure:
            nonisolated(nonsending)(SQLiteConnection) async throws ->
        sending SQLiteQueryResult
    ) async throws -> sending SQLiteQueryResult {

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
    
    // MARK: - service lifecycle

    public func run() async throws {
        // nothing to do
    }
    
    public func shutdown() async throws {
        try await connection.close()
    }
}
