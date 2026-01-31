//
//  MockDatabaseConnection.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase
import Logging

struct MockDatabaseConnection: DatabaseConnection {

    let logger: Logger
    let state: MockDatabaseState
    let result: MockDatabaseQueryResult

    func execute<T>(
        query: MockDatabaseQuery,
        _ handler: (MockDatabaseQueryResult) async throws(DatabaseError) -> T
    ) async throws -> T {
        await state.recordExecution(query)
        return try await handler(result)
    }
}
