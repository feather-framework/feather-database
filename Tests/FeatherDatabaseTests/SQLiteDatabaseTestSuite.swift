//
//  DatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import Logging
import PostgresNIO
import SQLiteNIO
import Testing

@testable import FeatherDatabase
@testable import FeatherDatabaseTesting

@Suite
struct SQLiteDatabaseTestSuite {

    private func getTestDatabase() async throws
        -> FeatherDatabase.SQLiteDatabase
    {
        var logger = Logger(label: "test")
        logger.logLevel = .debug

        let connection = try await SQLiteConnection.open(
            storage: .memory,
            logger: logger
        )

        return SQLiteDatabase(
            connection: connection,
            logger: logger
        )
    }

    @Test
    func foreignKeySupport() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: "PRAGMA foreign_keys = ON"
        )

        let result =
            try await database.execute(
                query: "PRAGMA foreign_keys"
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "foreign_keys", as: Int.self) == 1)
    }

    @Test
    func tableCreation() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE IF NOT EXISTS "galaxies" (
                    "id" INTEGER PRIMARY KEY,
                    "name" TEXT
                );
                """#
        )

        let results = try await database.execute(
            query: #"""
                SELECT name
                FROM sqlite_master
                WHERE type = 'table'
                ORDER BY name;
                """#
        )

        let resultArray = try await results.collect()
        #expect(resultArray.count == 1)

        let item = resultArray[0]
        let name = try item.decode(column: "name", as: String.self)
        #expect(name == "galaxies")
    }

    @Test
    func tableInsert() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE IF NOT EXISTS "galaxies" (
                    "id" INTEGER PRIMARY KEY,
                    "name" TEXT
                );
                """#
        )

        let name1 = "Andromeda"
        let name2 = "Milky Way"

        try await database.execute(
            query: #"""
                INSERT INTO "galaxies" 
                    ("id", "name")
                VALUES
                    (\#(nil), \#(name1)),
                    (\#(nil), \#(name2));
                """#
        )

        let results = try await database.execute(
            query: #"""
                SELECT * FROM "galaxies" ORDER BY "name" ASC;
                """#
        )

        let resultArray = try await results.collect()
        #expect(resultArray.count == 2)

        let item1 = resultArray[0]
        let name1result = try item1.decode(column: "name", as: String.self)
        #expect(name1result == name1)

        let item2 = resultArray[1]
        let name2result = try item2.decode(column: "name", as: String.self)
        #expect(name2result == name2)
    }

    @Test
    func rowDecoding() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "foo" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "value" TEXT
                );
                """#
        )

        try await database.execute(
            query: #"""
                INSERT INTO "foo" 
                    ("id", "value")
                VALUES
                    (1, 'abc'),
                    (2, NULL);
                """#
        )

        let result =
            try await database.execute(
                query: #"""
                    SELECT "id", "value"
                    FROM "foo"
                    ORDER BY "id";
                    """#
            )
            .collect()

        #expect(result.count == 2)

        let item1 = result[0]
        let item2 = result[1]

        #expect(try item1.decode(column: "id", as: Int.self) == 1)
        #expect(try item2.decode(column: "id", as: Int.self) == 2)

        #expect(try item1.decode(column: "id", as: Int?.self) == .some(1))
        #expect((try? item1.decode(column: "value", as: Int?.self)) == nil)

        #expect(try item1.decode(column: "value", as: String.self) == "abc")
        #expect((try? item2.decode(column: "value", as: String.self)) == nil)

        #expect(
            (try item1.decode(column: "value", as: String?.self))
                == .some("abc")
        )
        #expect((try item2.decode(column: "value", as: String?.self)) == .none)
    }

    @Test
    func queryEncoding() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        let tableName = "foo"
        let idColumn = "id"
        let valueColumn = "value"
        let row1: (Int, String?) = (1, "abc")
        let row2: (Int, String?) = (2, nil)

        try await database.execute(
            query: #"""
                CREATE TABLE \#(unescaped: tableName) (
                    \#(unescaped: idColumn) INTEGER NOT NULL PRIMARY KEY,
                    \#(unescaped: valueColumn) TEXT
                );
                """#
        )

        try await database.execute(
            query: #"""
                INSERT INTO \#(unescaped: tableName) 
                    (\#(unescaped: idColumn), \#(unescaped: valueColumn))
                VALUES
                    (\#(row1.0), \#(row1.1)),
                    (\#(row2.0), \#(row2.1));
                """#
        )

        let result =
            try await database.execute(
                query: #"""
                    SELECT \#(unescaped: idColumn), \#(unescaped: valueColumn)
                    FROM \#(unescaped: tableName)
                    ORDER BY \#(unescaped: idColumn) ASC;
                    """#
            )
            .collect()

        #expect(result.count == 2)

        let item1 = result[0]
        let item2 = result[1]

        #expect(try item1.decode(column: "id", as: Int.self) == 1)
        #expect(try item2.decode(column: "id", as: Int.self) == 2)

        #expect(try item1.decode(column: "value", as: String?.self) == "abc")
        #expect(try item2.decode(column: "value", as: String?.self) == nil)
    }

    @Test
    func example() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        let result = try await database.execute(
            query: #"""
                SELECT 
                    sqlite_version() AS "version" 
                WHERE 
                    1=\#(1);
                """#
        )

        let resultArray = try await result.collect()
        #expect(resultArray.count == 1)

        let item = resultArray[0]
        let version = try item.decode(column: "version", as: String.self)
        #expect(version.split(separator: ".").count == 3)
    }
}
