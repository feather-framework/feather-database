//
//  SQLiteConnection.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import SQLiteNIO

extension SQLiteConnection: DatabaseConnection {

    /// Execute a SQLite query on this connection.
    ///
    /// This wraps `SQLiteNIO` query execution and maps errors.
    /// - Parameter query: The SQLite query to execute.
    /// - Throws: A `DatabaseError` if the query fails.
    /// - Returns: A query result containing the returned rows.
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
