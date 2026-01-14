import ServiceLifecycle

/// The database client protocol.
public protocol DatabaseClient: Service {

    associatedtype Connection: DatabaseConnection

    @discardableResult
    func connection(
        _: nonisolated(nonsending)(Connection) async throws -> sending Connection.Result,
    ) async throws(DatabaseError) -> sending Connection.Result

    @discardableResult
    func transaction(
        _: nonisolated(nonsending)(Connection) async throws -> sending Connection.Result,
    ) async throws(DatabaseError) -> sending Connection.Result

    @discardableResult
    func execute(
        query: Connection.Query,
    ) async throws(DatabaseError) -> Connection.Result
    
    func shutdown() async throws(DatabaseError)
}

extension DatabaseClient {

    @discardableResult
    public func execute(
        query: Connection.Query,
    ) async throws(DatabaseError) -> Connection.Result {
        try await connection { connection in
            try await connection.execute(query: query)
        }
    }
}
