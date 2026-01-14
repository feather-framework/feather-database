import Logging
import PostgresNIO

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
        _ closure:
            nonisolated(nonsending)(PostgresConnection) async throws ->
        sending PostgresQueryResult
    ) async throws -> sending PostgresQueryResult {
        try await client.withConnection(closure)
    }

    @discardableResult
    public func transaction(
        _ closure:
            nonisolated(nonsending)(PostgresConnection) async throws ->
        sending PostgresQueryResult
    ) async throws -> sending PostgresQueryResult {
        try await client.withTransaction(logger: logger, closure)
    }
    
    // MARK: - service lifecycle

    public func run() async throws {
        await client.run()
    }
    
    public func shutdown() async throws {
        // nothing to do
    }
}
