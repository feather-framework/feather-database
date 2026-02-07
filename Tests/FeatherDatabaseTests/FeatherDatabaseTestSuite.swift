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
        let sequence = MockDatabaseRowSequence(
            rows: [
                MockDatabaseRow(storage: ["name": .string("alpha")])
            ]
        )
        let connection = MockDatabaseConnection(
            logger: Logger(label: "test"),
            state: state,
            mockSequence: sequence
        )
        let client = MockDatabaseClient(state: state, connection: connection)
        let query = DatabaseQuery(unsafeSQL: "SELECT 1", bindings: [])

        let decodedRows = try await client.withConnection { connection in
            try await connection.run(query: query) { sequence in
                try await sequence.collect()
                    .map {
                        try $0.decode(column: "name", as: String.self)
                    }
            }
        }
        #expect(decodedRows.count == 1)

        try await client.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT 1 WHERE 1 = \#(1)
                    """#
            ) { sequence in
                try await sequence.collect()
                    .map {
                        try $0.decode(column: "name", as: String.self)
                    }
            }
        }

        try await client.withConnection { connection in
            try await connection.run(query: query) { _ in
                // no value returned, no sequence iteration
            }
        }

        try await client.withTransaction { connection in
            try await connection.run(query: query) { sequence in
                try await sequence.collect()
                    .map {
                        try $0.decode(column: "name", as: String.self)
                    }
            }
            try await connection.run(query: query) { sequence in
                try await sequence.collect()
                    .map {
                        try $0.decode(column: "name", as: String.self)
                    }
            }
            return "ok"
        }

        #expect(await state.connectionCount() == 4)
        let executedQueries = await state.executedQueryList()
        #expect(executedQueries.count == 5)
        #expect(executedQueries.first?.sql == query.sql)
    }

    @Test
    func collectFirstReturnsFirstRow() async throws {
        let rows = [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ]
        let result = MockDatabaseRowSequence(rows: rows)

        let first = try await result.collect().first

        #expect(first != nil)
        #expect(
            try first?.decode(column: "name", as: String.self) == "alpha"
        )
    }

    @Test
    func collectFirstReturnsNilWhenEmpty() async throws {
        let result = MockDatabaseRowSequence(rows: [])

        let first = try await result.collect().first

        #expect(first == nil)
    }

    @Test
    func queryInterpolation() async throws {
        let table = "foo"
        let query: DatabaseQuery = #"""
            SELECT * FROM \#(table)
            """#

        #expect(query.sql == "SELECT * FROM {{1}}")
        #expect(query.bindings.count == 1)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("foo")))
    }

    @Test
    func queryInterpolationBindsIntsAndDoubles() async throws {
        let count = 7
        let ratio = 3.5
        let query: DatabaseQuery = #"""
            SELECT * FROM stats WHERE count > \#(count) AND ratio < \#(ratio)
            """#

        #expect(
            query.sql
                == "SELECT * FROM stats WHERE count > {{1}} AND ratio < {{2}}"
        )
        #expect(query.bindings.count == 2)
        #expect(query.bindings[0] == .init(index: 0, binding: .int(7)))
        #expect(query.bindings[1] == .init(index: 1, binding: .double(3.5)))
    }

    @Test
    func queryInterpolationMultipleBindings() async throws {
        let name = "alpha"
        let age = 42
        let score = 9.25
        let query: DatabaseQuery = #"""
            INSERT INTO people (name, age, score) VALUES (\#(name), \#(age), \#(score))
            """#

        #expect(
            query.sql
                == "INSERT INTO people (name, age, score) VALUES ({{1}}, {{2}}, {{3}})"
        )
        #expect(query.bindings.count == 3)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("alpha")))
        #expect(query.bindings[1] == .init(index: 1, binding: .int(42)))
        #expect(query.bindings[2] == .init(index: 2, binding: .double(9.25)))
    }

    @Test
    func queryInterpolationOptionalAndUnescaped() async throws {
        let table = "users"
        let name: String? = nil
        let query: DatabaseQuery = #"""
            SELECT * FROM \#(unescaped: table) WHERE name IS \#(name)
            """#

        #expect(query.sql == "SELECT * FROM users WHERE name IS NULL")
        #expect(query.bindings.isEmpty)
    }

    @Test
    func queryInterpolationOptionalBindsWhenPresent() async throws {
        let name: String? = "beta"
        let query: DatabaseQuery = #"""
            SELECT * FROM people WHERE name = \#(name)
            """#

        #expect(query.sql == "SELECT * FROM people WHERE name = {{1}}")
        #expect(query.bindings.count == 1)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("beta")))
    }

    @Test
    func queryUnsafeSQLInitializer() async throws {
        let bindings = [
            DatabaseQueryBindings(index: 0, binding: .string("alpha")),
            DatabaseQueryBindings(index: 1, binding: .int(9)),
        ]
        let query = DatabaseQuery(
            unsafeSQL: "SELECT * FROM demo WHERE name = {{1}} AND age > {{2}}",
            bindings: bindings
        )

        #expect(
            query.sql == "SELECT * FROM demo WHERE name = {{1}} AND age > {{2}}"
        )
        #expect(query.bindings == bindings)
    }

    @Test
    func queryStringLiteralInitializer() async throws {
        let query: DatabaseQuery = "SELECT 1"

        #expect(query.sql == "SELECT 1")
        #expect(query.bindings.isEmpty)
    }
}
