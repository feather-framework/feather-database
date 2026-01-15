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

#if compiler(>=6.2)
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
#else
    func connection(
        _ closure:
            (MockDatabaseConnection) async throws -> MockDatabaseQueryResult
    ) async throws(DatabaseError) -> MockDatabaseQueryResult {
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
            (MockDatabaseConnection) async throws -> MockDatabaseQueryResult
    ) async throws(DatabaseError) -> MockDatabaseQueryResult {
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
#endif
        
    
}
