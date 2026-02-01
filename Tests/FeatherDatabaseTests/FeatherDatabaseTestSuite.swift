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
            mockResult: result.rows
        )
        let client = MockDatabaseClient(state: state, connection: connection)
        let query = MockDatabaseQuery(sql: "SELECT 1", bindings: [])

        let decodedRows = try await client.withConnection { connection in
            try await connection.run(query) { row in
                try row.decode(column: "name", as: String.self)
            }
        }
        print(decodedRows)

        var items: [String] = []
        try await client.withConnection { connection in
            try await connection.run(query) { row in
                items.append(try row.decode(column: "name", as: String.self))
            }
        }
        print(items)

        try await client.withTransaction { connection in
            try await connection.run(query) { row in
                try row.decode(column: "name", as: String.self)
            }
            try await connection.run(query) { row in
                try row.decode(column: "name", as: String.self)
            }
            return "ok"
        }

        #expect(await state.connectionCount() == 3)
        let executedQueries = await state.executedQueryList()
        #expect(executedQueries.count == 4)
        #expect(executedQueries.first?.sql == query.sql)
    }

    @Test
    func collectFirstReturnsFirstRow() async throws {
        let rows = [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ]
        let result = MockDatabaseQueryResult(rows: rows)

        let first = try await result.collect().first

        #expect(first != nil)
        #expect(
            try first?.decode(column: "name", as: String.self) == "alpha"
        )
    }

    @Test
    func collectFirstReturnsNilWhenEmpty() async throws {
        let result = MockDatabaseQueryResult(rows: [])

        let first = try await result.collect().first

        #expect(first == nil)
    }

}
