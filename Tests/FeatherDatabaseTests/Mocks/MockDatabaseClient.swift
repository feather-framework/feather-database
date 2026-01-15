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
        _ closure:
            nonisolated(nonsending)(MockDatabaseConnection) async throws ->
            sending MockDatabaseQueryResult
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
        _ closure:
            nonisolated(nonsending)(MockDatabaseConnection) async throws ->
            sending MockDatabaseQueryResult
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
