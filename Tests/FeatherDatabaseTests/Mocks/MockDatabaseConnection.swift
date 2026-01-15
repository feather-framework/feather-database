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

    func execute(
        query: MockDatabaseQuery
    ) async throws(DatabaseError) -> MockDatabaseQueryResult {
        await state.recordExecution(query)
        return result
    }
}
