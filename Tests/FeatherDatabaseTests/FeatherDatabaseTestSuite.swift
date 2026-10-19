//
//  FeatherDatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Foundation
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
    func firstReturnsFirstRow() async throws {
        let rows = [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ]
        let result = MockDatabaseRowSequence(rows: rows)

        let first = try await result.first()

        #expect(first != nil)
        #expect(
            try first?.decode(column: "name", as: String.self) == "alpha"
        )
    }

    @Test
    func firstReturnsNilWhenEmpty() async throws {
        let result = MockDatabaseRowSequence(rows: [])

        let first = try await result.first()

        #expect(first == nil)
    }

    @Test
    func decodesFlatModelsWithSnakeCaseAndNulls() throws {
        struct Account: Decodable, Equatable {
            let displayName: String
            let nickname: String?
            let isActive: Bool
        }

        let row = MockDatabaseRow(storage: [
            "display_name": .string("Feather"),
            "nickname": .null,
            "is_active": .bool(true),
        ])

        let account = try row.decode(
            model: Account.self,
            with: .init(keyDecodingStrategy: .convertFromSnakeCase)
        )

        #expect(
            account
                == Account(
                    displayName: "Feather",
                    nickname: nil,
                    isActive: true
                )
        )
    }

    @Test
    func decodesFlatModelsWithColumnPrefixAndCustomKeys() throws {
        struct Account: Decodable, Equatable {
            let name: String
        }
        struct UppercaseKey: CodingKey {
            let stringValue: String
            let intValue: Int? = nil
            init(stringValue: String) {
                self.stringValue = stringValue.uppercased()
            }
            init?(intValue: Int) { return nil }
        }

        let row = MockDatabaseRow(storage: ["p_NAME": .string("Feather")])
        let decoder = DatabaseRowDecoder(
            prefix: "p_",
            keyDecodingStrategy: .custom { path in
                UppercaseKey(stringValue: path.last!.stringValue)
            }
        )

        #expect(
            try row.decode(model: Account.self, with: decoder)
                == Account(name: "Feather")
        )
    }

    @Test
    func decodesFlatDatabaseScalarTypesAndNullValues() throws {
        struct Record: Decodable, Equatable {
            let id: Int
            let enabled: Bool
            let score: Double
            let title: String
            let createdAt: Date
            let payload: Data?
            let nullableTitle: String?
            let missingTitle: String?
        }

        let createdAt = Date(timeIntervalSince1970: 1_760_000_000)
        let payload = Data([0x00, 0x2A, 0xFF])
        let row = MockDatabaseRow(storage: [
            "id": .int(42),
            "enabled": .bool(true),
            "score": .double(9.5),
            "title": .string("Feather"),
            "created_at": .date(createdAt),
            "payload": .data(payload),
            "nullable_title": .null,
        ])

        let record = try row.decode(
            model: Record.self,
            with: .init(keyDecodingStrategy: .convertFromSnakeCase)
        )

        #expect(
            record
                == Record(
                    id: 42,
                    enabled: true,
                    score: 9.5,
                    title: "Feather",
                    createdAt: createdAt,
                    payload: payload,
                    nullableTitle: nil,
                    missingTitle: nil
                )
        )
    }

    @Test
    func decodesFlatStringDictionaryWithPrefixAndSnakeCaseKeys() throws {
        let row = MockDatabaseRow(storage: [
            "p_display_name": .string("Feather"),
            "p_is_active": .string("true"),
        ])

        let values = try row.decode(
            model: [String: String].self,
            with: .init(
                prefix: "p_",
                keyDecodingStrategy: .convertFromSnakeCase
            )
        )

        #expect(values == ["displayName": "Feather", "isActive": "true"])
    }

    @Test
    func decoderPassesUserInfoToDecodableValues() throws {
        struct ContextValue: Decodable, Equatable {
            let source: String

            init(from decoder: any Decoder) throws {
                let key = CodingUserInfoKey(rawValue: "source")!
                source = decoder.userInfo[key] as? String ?? "missing"
            }
        }

        let row = MockDatabaseRow(storage: [:])
        let value = try row.decode(
            model: ContextValue.self,
            with: .init(userInfo: [
                CodingUserInfoKey(rawValue: "source")!: "database-row"
            ])
        )

        #expect(value.source == "database-row")
    }

    @Test
    func decodeNilErrorsIncludeTheModelCodingPath() throws {
        struct NullableValue: Decodable {
            let name: String?
        }

        struct FailingRow: DatabaseRow {
            var columns: [String] { ["name"] }
            func contains(column: String) -> Bool { column == "name" }
            func decodeNil(column: String) throws(DecodingError) -> Bool {
                throw .valueNotFound(
                    Optional<String>.self,
                    .init(
                        codingPath: [],
                        debugDescription: "Cannot inspect SQL NULL."
                    )
                )
            }
            func decode<T: Decodable>(column: String, as: T.Type)
                throws(DecodingError) -> T
            {
                throw .typeMismatch(
                    T.self,
                    .init(
                        codingPath: [],
                        debugDescription: "Unexpected decode call."
                    )
                )
            }
        }

        let error = #expect(throws: DecodingError.self) {
            try FailingRow().decode(model: NullableValue.self)
        }
        guard case .valueNotFound(_, let context) = error else {
            Issue.record("Expected the row's decodeNil error.")
            return
        }
        #expect(context.codingPath.map(\.stringValue) == ["name"])
    }

    @Test
    func rowDecoderReportsMissingColumnAndTypeMismatchPaths() throws {
        struct Required: Decodable { let name: String }
        struct WrongType: Decodable { let age: String }

        let emptyRow = MockDatabaseRow(storage: [:])
        let missingError = #expect(throws: DecodingError.self) {
            try emptyRow.decode(model: Required.self)
        }
        guard
            case .keyNotFound(let missingKey, let missingContext) = missingError
        else {
            Issue.record("Expected keyNotFound for a missing required column.")
            return
        }
        #expect(missingKey.stringValue == "name")
        #expect(missingContext.codingPath.isEmpty)

        let row = MockDatabaseRow(storage: ["age": .int(42)])
        let typeError = #expect(throws: DecodingError.self) {
            try row.decode(model: WrongType.self)
        }
        guard case .typeMismatch(_, let typeContext) = typeError else {
            Issue.record(
                "Expected typeMismatch for a column with the wrong type."
            )
            return
        }
        #expect(typeContext.codingPath.map(\.stringValue) == ["age"])
    }

    @Test
    func rowDecoderRejectsNestedObjects() {
        struct Address: Decodable { let city: String }
        struct Account: Decodable { let address: Address }

        let row = MockDatabaseRow(storage: [
            "address": .string("not a nested object")
        ])
        #expect(throws: DecodingError.self) {
            try row.decode(model: Account.self)
        }
    }

    @Test
    func sequenceDecodesModels() async throws {
        struct Account: Decodable, Equatable { let name: String }
        let rows = MockDatabaseRowSequence(rows: [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ])

        #expect(
            try await rows.decode(model: Account.self) == [
                Account(name: "alpha"), Account(name: "beta"),
            ]
        )
    }

    @Test
    func sequenceDecodesFirstModelWithoutCollectingAllRows() async throws {
        struct Account: Decodable, Equatable { let name: String }
        let rows = MockDatabaseRowSequence(rows: [
            MockDatabaseRow(storage: ["name": .string("alpha")]),
            MockDatabaseRow(storage: ["name": .string("beta")]),
        ])

        #expect(
            try await rows.first(decoding: Account.self)
                == Account(name: "alpha")
        )
        #expect(
            try await MockDatabaseRowSequence(rows: [])
                .first(decoding: Account.self) == nil
        )
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
    func queryInterpolationBindsBool() async throws {
        let isEnabled = true
        let query: DatabaseQuery = #"""
            SELECT * FROM features WHERE enabled = \#(isEnabled)
            """#

        #expect(query.sql == "SELECT * FROM features WHERE enabled = {{1}}")
        #expect(query.bindings.count == 1)
        #expect(query.bindings[0] == .init(index: 0, binding: .bool(true)))
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
    func queryInterpolationOptionalNumbersAndBool() async throws {
        let age: Int? = nil
        let ratio: Float? = 1.5
        let score: Double? = nil
        let isActive: Bool? = true
        let query: DatabaseQuery = #"""
            SELECT * FROM demo WHERE age IS \#(age) AND ratio = \#(ratio) AND score IS \#(score) AND active = \#(isActive)
            """#

        #expect(
            query.sql
                == "SELECT * FROM demo WHERE age IS NULL AND ratio = {{1}} AND score IS NULL AND active = {{2}}"
        )
        #expect(query.bindings.count == 2)
        #expect(query.bindings[0] == .init(index: 0, binding: .double(1.5)))
        #expect(query.bindings[1] == .init(index: 1, binding: .bool(true)))
    }

    @Test
    func queryInterpolationArrayValues() async throws {
        let names = ["alpha", "beta"]
        let ids = [1, 2, 3]
        let ratios: [Float] = [1.5, 2.25]
        let scores = [3.5, 4.75]
        let flags = [true, false]
        let query: DatabaseQuery = #"""
            SELECT * FROM demo WHERE name IN (\#(names)) AND id IN (\#(ids)) AND ratio IN (\#(ratios)) AND score IN (\#(scores)) AND enabled IN (\#(flags))
            """#

        #expect(
            query.sql
                == "SELECT * FROM demo WHERE name IN ({{1}}, {{2}}) AND id IN ({{3}}, {{4}}, {{5}}) AND ratio IN ({{6}}, {{7}}) AND score IN ({{8}}, {{9}}) AND enabled IN ({{10}}, {{11}})"
        )
        #expect(query.bindings.count == 11)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("alpha")))
        #expect(query.bindings[1] == .init(index: 1, binding: .string("beta")))
        #expect(query.bindings[2] == .init(index: 2, binding: .int(1)))
        #expect(query.bindings[3] == .init(index: 3, binding: .int(2)))
        #expect(query.bindings[4] == .init(index: 4, binding: .int(3)))
        #expect(query.bindings[5] == .init(index: 5, binding: .double(1.5)))
        #expect(query.bindings[6] == .init(index: 6, binding: .double(2.25)))
        #expect(query.bindings[7] == .init(index: 7, binding: .double(3.5)))
        #expect(query.bindings[8] == .init(index: 8, binding: .double(4.75)))
        #expect(query.bindings[9] == .init(index: 9, binding: .bool(true)))
        #expect(query.bindings[10] == .init(index: 10, binding: .bool(false)))
    }

    @Test
    func queryInterpolationOptionalArrayValues() async throws {
        let names: [String?] = ["alpha", nil, "beta"]
        let ids: [Int?] = [1, nil, 3]
        let ratios: [Float?] = [1.5, nil, 2.25]
        let scores: [Double?] = [3.5, nil, 4.75]
        let flags: [Bool?] = [true, nil, false]
        let query: DatabaseQuery = #"""
            SELECT * FROM demo WHERE name IN (\#(names)) AND id IN (\#(ids)) AND ratio IN (\#(ratios)) AND score IN (\#(scores)) AND enabled IN (\#(flags))
            """#

        #expect(
            query.sql
                == "SELECT * FROM demo WHERE name IN ({{1}}, NULL, {{2}}) AND id IN ({{3}}, NULL, {{4}}) AND ratio IN ({{5}}, NULL, {{6}}) AND score IN ({{7}}, NULL, {{8}}) AND enabled IN ({{9}}, NULL, {{10}})"
        )
        #expect(query.bindings.count == 10)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("alpha")))
        #expect(query.bindings[1] == .init(index: 1, binding: .string("beta")))
        #expect(query.bindings[2] == .init(index: 2, binding: .int(1)))
        #expect(query.bindings[3] == .init(index: 3, binding: .int(3)))
        #expect(query.bindings[4] == .init(index: 4, binding: .double(1.5)))
        #expect(query.bindings[5] == .init(index: 5, binding: .double(2.25)))
        #expect(query.bindings[6] == .init(index: 6, binding: .double(3.5)))
        #expect(query.bindings[7] == .init(index: 7, binding: .double(4.75)))
        #expect(query.bindings[8] == .init(index: 8, binding: .bool(true)))
        #expect(query.bindings[9] == .init(index: 9, binding: .bool(false)))
    }

    @Test
    func queryInterpolationUnescapedNumbersAndBool() async throws {
        let limit = 10
        let ratio = 2.75
        let isActive = false
        let query: DatabaseQuery = #"""
            SELECT * FROM metrics LIMIT \#(unescaped: limit) OFFSET \#(unescaped: 0) WHERE ratio > \#(unescaped: ratio) AND active = \#(unescaped: isActive)
            """#

        #expect(
            query.sql
                == "SELECT * FROM metrics LIMIT 10 OFFSET 0 WHERE ratio > 2.75 AND active = false"
        )
        #expect(query.bindings.isEmpty)
    }

    @Test
    func queryInterpolationUnescapedOptionalValuesAndFloat() async throws {
        let table: String? = nil
        let name: String? = "users"
        let age: Int? = 21
        let missingAge: Int? = nil
        let ratio: Float = 1.25
        let optionalRatio: Float? = nil
        let score: Double? = 3.75
        let missingScore: Double? = nil
        let isActive: Bool? = true
        let missingActive: Bool? = nil

        let query: DatabaseQuery = #"""
            SELECT * FROM \#(unescaped: table) \#(unescaped: name) WHERE age > \#(unescaped: age) AND missing_age IS \#(unescaped: missingAge) AND ratio = \#(unescaped: ratio) AND optional_ratio IS \#(unescaped: optionalRatio) AND score = \#(unescaped: score) AND missing_score IS \#(unescaped: missingScore) AND active = \#(unescaped: isActive) AND missing_active IS \#(unescaped: missingActive)
            """#

        #expect(
            query.sql
                == "SELECT * FROM NULL users WHERE age > 21 AND missing_age IS NULL AND ratio = 1.25 AND optional_ratio IS NULL AND score = 3.75 AND missing_score IS NULL AND active = true AND missing_active IS NULL"
        )
        #expect(query.bindings.isEmpty)
    }

    @Test
    func queryInterpolationUnescapedAndBoundMix() async throws {
        let table = "events"
        let name = "alpha"
        let query: DatabaseQuery = #"""
            SELECT * FROM \#(unescaped: table) WHERE name = \#(name)
            """#

        #expect(query.sql == "SELECT * FROM events WHERE name = {{1}}")
        #expect(query.bindings.count == 1)
        #expect(query.bindings[0] == .init(index: 0, binding: .string("alpha")))
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
