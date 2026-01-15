//
//  MySQLConnection.swift
//  Feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import MySQLNIO
import NIOCore

extension MySQLConnection: DatabaseConnection {

    /// Execute a MySQL query on this connection.
    ///
    /// This wraps `MySQLNIO` query execution and maps errors.
    /// - Parameter query: The MySQL query to execute.
    /// - Throws: A `DatabaseError` if the query fails.
    /// - Returns: A query result containing the returned rows.
    @discardableResult
    public func execute(
        query: MySQLQuery
    ) async throws(DatabaseError) -> MySQLQueryResult {
        do {
            let rows = try await self.query(query.sql, query.bindings).get()
            return MySQLQueryResult(elements: rows)
        }
        catch {
            throw .query(error)
        }
    }

    /// Close the underlying connection.
    ///
    /// Call this to release resources when the connection is no longer needed.
    /// - Throws: An error if closing the connection fails.
    /// - Returns: Nothing.
    public func close() async throws {
        let future: EventLoopFuture<Void> = self.close()
        try await future.get()
    }
}
