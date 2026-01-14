import Logging
import PostgresNIO

extension PostgresTransactionError: DatabaseTransactionError {}

public struct PostgresDatabaseClient: DatabaseClient {
    
    var client: PostgresClient
    var logger: Logger

    public init(
        client: PostgresClient,
        logger: Logger
    ) {
        self.client = client
        self.logger = logger
    }

    // MARK: - database api

    @discardableResult
    public func connection(
        _ closure: nonisolated(nonsending)(PostgresConnection) async throws -> sending PostgresQueryResult
    ) async throws(DatabaseError) -> sending PostgresQueryResult {
        do {
            return try await client.withConnection(closure)
        }
        catch {
            throw .connection(error)
        }
    }

    @discardableResult
    public func transaction(
        _ closure: nonisolated(nonsending)(PostgresConnection) async throws -> sending PostgresQueryResult
    ) async throws(DatabaseError) -> sending PostgresQueryResult {
        do {
            return try await client.withTransaction(logger: logger, closure)
        }
        catch let error as PostgresTransactionError {
            throw .transaction(error)
        }
        catch {
            throw .connection(error)
        }
    }
    
    // MARK: - service lifecycle

    public func run() async throws {
        await client.run()
    }
    
    public func shutdown() async throws(DatabaseError) {
        // nothing to do
    }
}
