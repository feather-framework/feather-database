//
//  MockDatabaseClient.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase

struct MockDatabaseClient: DatabaseClient {

    let state: MockDatabaseState
    let connection: MockDatabaseConnection

    func connection(
        isolation: isolated (any Actor)? = #isolation,
        _ closure: (MockDatabaseConnection) async throws -> sending MockDatabaseQueryResult
    ) async throws(DatabaseError) -> sending MockDatabaseQueryResult {
        await state.recordConnection()
        do {
            return try await closure(connection)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .connection(error)
        }
    }
    
    func transaction(
        isolation: isolated (any Actor)? = #isolation,
        _ closure: (MockDatabaseConnection) async throws -> sending MockDatabaseQueryResult
    ) async throws(DatabaseError) -> sending MockDatabaseQueryResult {
        await state.recordConnection()
        do {
            return try await closure(connection)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .connection(error)
        }
    }

}
