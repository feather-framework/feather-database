import SQLiteNIO

extension SQLiteConnection: DatabaseConnection {

    @discardableResult
    public func execute(
        query: SQLiteQuery
    ) async throws(DatabaseError) -> SQLiteQueryResult {
        do {
            let result = try await self.query(
                query.sql,
                query.bindings
            )
            return SQLiteQueryResult(elements: result)
        }
        catch {
            throw .query(error)
        }
    }
}
