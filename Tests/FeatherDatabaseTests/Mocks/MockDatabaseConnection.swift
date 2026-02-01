//
//  MockDatabaseConnection.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase
import Logging

struct MockDatabaseConnection: DatabaseConnection {

    typealias Query = MockDatabaseQuery
    typealias Result = MockDatabaseQueryResult

    let logger: Logger
    let state: MockDatabaseState
    let mockResult: [MockDatabaseQueryResult.Row]

    @discardableResult
    func run<T: Sendable>(
        _ query: MockDatabaseQuery,
        _ handler: (MockDatabaseQueryResult.Row) async throws -> T
    ) async throws(DatabaseError) -> [T] {
        await state.recordExecution(query)
        do {
            var result: [T] = []
            for item in mockResult {
                result.append(try await handler(item))
            }
            return result
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .query(error)
        }
    }

    func run(
        _ query: Query,
        _ handler: (Result.Row) async throws -> Void
    ) async throws(DatabaseError) {
        await state.recordExecution(query)
        do {
            for item in mockResult {
                try await handler(item)
            }
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .query(error)
        }
    }

}
