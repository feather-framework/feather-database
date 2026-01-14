import SQLiteNIO

extension SQLiteConnection: DatabaseConnection {

    @discardableResult
    public func execute(
        query: SQLiteQuery
    ) async throws -> SQLiteQueryResult {

        let result = try await self.query(
            query.sql,
            query.bindings
        )
        return SQLiteQueryResult(elements: result)
    }
}
