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

    @discardableResult
    func withConnection<T>(
        _ closure: (MockDatabaseConnection) async throws -> T
    ) async throws(DatabaseError) -> T {
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

    @discardableResult
    func withTransaction<T>(
        _ closure: (MockDatabaseConnection) async throws -> T
    ) async throws(DatabaseError) -> T {
        await state.recordConnection()
        do {
            return try await closure(connection)
        }
        catch let error as DatabaseError {
            throw error
        }
        catch let error as DatabaseTransactionError {
            throw .transaction(error)
        }
        catch {
            throw .query(error)
        }
    }

}
