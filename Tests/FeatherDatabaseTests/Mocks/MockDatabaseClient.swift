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

    func connection<T>(
        isolation: isolated (any Actor)? = #isolation,
        _ closure: (MockDatabaseConnection) async throws(DatabaseError) ->
            sending T
    ) async throws(DatabaseError) -> sending T {
        await state.recordConnection()

        return try await closure(connection)
    }

    func transaction<T>(
        isolation: isolated (any Actor)? = #isolation,
        _ closure: (MockDatabaseConnection) async throws(DatabaseError) ->
            sending T
    ) async throws(DatabaseError) -> sending T {
        await state.recordConnection()
        return try await closure(connection)
    }

}
