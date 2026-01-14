import PostgresNIO

extension PostgresConnection: DatabaseConnection {
    
    @discardableResult
    public func execute(
        query: PostgresQuery
    ) async throws(DatabaseError) -> PostgresQueryResult {
        do {
            let result = try await self.query(
                .init(
                    unsafeSQL: query.sql,
                    binds: query.bindings
                ),
                logger: logger
            )
            return PostgresQueryResult(backingSequence: result)
        }
        catch {
            throw DatabaseError.query(error)
        }
    }
}
