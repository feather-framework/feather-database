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
        _ handler: (MockDatabaseQueryResult) async throws -> T
    ) async throws(DatabaseError) -> T {
        await state.recordExecution(query)
        do {
            return try await handler(result)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .result(error)
        }
    }
}
