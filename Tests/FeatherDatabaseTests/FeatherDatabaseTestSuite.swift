//
//  FeatherDatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging
import Testing

@testable import FeatherDatabase

@Suite
struct FeatherDatabaseTestSuite {

    @Test
    func executeUsesConnection() async throws {
        let state = MockDatabaseState()
        let result = MockDatabaseQueryResult(
            rows: [
                MockDatabaseRow(storage: ["name": .string("alpha")])
            ]
        )
        let connection = MockDatabaseConnection(
            logger: Logger(label: "test"),
            state: state,
            result: result
        )
        let client = MockDatabaseClient(state: state, connection: connection)
        let query = MockDatabaseQuery(sql: "SELECT 1", bindings: [])

        try await client.execute(query: query) { result in
            try await result.collect()
        }

        #expect(await state.connectionCount() == 1)
        let executedQueries = await state.executedQueryList()
        #expect(executedQueries.count == 1)
        #expect(executedQueries.first?.sql == query.sql)
    }

    @Test
    func collectFirstReturnsFirstRow() async throws {
        let rows = [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ]
        let result = MockDatabaseQueryResult(rows: rows)

        let first = try await result.collectFirst()

        #expect(first != nil)
        #expect(
            try first?.decode(column: "name", as: String.self) == "alpha"
        )
    }

    @Test
    func collectFirstReturnsNilWhenEmpty() async throws {
        let result = MockDatabaseQueryResult(rows: [])

        let first = try await result.collectFirst()

        #expect(first == nil)
    }

}
