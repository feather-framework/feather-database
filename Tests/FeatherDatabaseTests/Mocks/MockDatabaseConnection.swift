//
//  MockDatabaseConnection.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase
import Logging

struct MockDatabaseConnection: DatabaseConnection {

//    typealias Query = MockDatabaseQuery
    typealias RowSequence = MockDatabaseRowSequence

    let logger: Logger
    let state: MockDatabaseState
    let mockSequence: RowSequence

    @discardableResult
    func run<T: Sendable>(
        query: Query,
        _ handler: (RowSequence) async throws -> T
    ) async throws(DatabaseError) -> T {
        await state.recordExecution(query)
        do {
            return try await handler(mockSequence)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .query(error)
        }
    }

}
