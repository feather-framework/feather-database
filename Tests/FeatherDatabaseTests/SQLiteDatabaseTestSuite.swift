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
    func unsafeSQLBindings() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "widgets" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "name" TEXT NOT NULL
                );
                """#
        )

        let insert = SQLiteQuery(
            unsafeSQL: #"""
                INSERT INTO "widgets"
                    ("id", "name")
                VALUES
                    (?, ?);
                """#,
            bindings: [.integer(1), .text("gizmo")]
        )

        try await database.execute(query: insert)

        let result =
            try await database.execute(
                query: #"""
                    SELECT "name"
                    FROM "widgets"
                    WHERE "id" = 1;
                    """#
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "name", as: String.self) == "gizmo")
    }

    @Test
    func optionalStringInterpolationNil() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "notes" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "body" TEXT
                );
                """#
        )

        let body: String? = nil
        let insert: SQLiteQuery = #"""
            INSERT INTO "notes"
                ("id", "body")
            VALUES
                (1, \#(body));
            """#

        try await database.execute(query: insert)

        let result =
            try await database.execute(
                query: #"""
                    SELECT "body"
                    FROM "notes"
                    WHERE "id" = 1;
                    """#
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "body", as: String?.self) == nil)
    }

    @Test
    func sqliteDataInterpolation() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "tags" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "label" TEXT NOT NULL
                );
                """#
        )

        let label: SQLiteData = .text("alpha")
        let insert: SQLiteQuery = #"""
            INSERT INTO "tags"
                ("id", "label")
            VALUES
                (1, \#(label));
            """#

        try await database.execute(query: insert)

        let result =
            try await database.execute(
                query: #"""
                    SELECT "label"
                    FROM "tags"
                    WHERE "id" = 1;
                    """#
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "label", as: String.self) == "alpha")
    }

    @Test
    func resultSequenceIterator() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "numbers" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "value" TEXT NOT NULL
                );
                """#
        )

        try await database.execute(
            query: #"""
                INSERT INTO "numbers"
                    ("id", "value")
                VALUES
                    (1, 'one'),
                    (2, 'two');
                """#
        )

        let result = try await database.execute(
            query: #"""
                SELECT "id", "value"
                FROM "numbers"
                ORDER BY "id";
                """#
        )

        var iterator = result.makeAsyncIterator()
        let first = await iterator.next()
        let second = await iterator.next()
        let third = await iterator.next()

        #expect(first != nil)
        #expect(second != nil)
        #expect(third == nil)

        if let first {
            #expect(try first.decode(column: "id", as: Int.self) == 1)
            #expect(try first.decode(column: "value", as: String.self) == "one")
        }
        else {
            Issue.record("Expected first iterator element to exist.")
        }

        if let second {
            #expect(try second.decode(column: "id", as: Int.self) == 2)
            #expect(try second.decode(column: "value", as: String.self) == "two")
        }
        else {
            Issue.record("Expected second iterator element to exist.")
        }
    }

    @Test
    func transactionSuccess() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "items" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "name" TEXT NOT NULL
                );
                """#
        )

        try await database.transaction { connection in
            try await connection.execute(
                query: SQLiteQuery(unsafeSQL: #"""
                    INSERT INTO "items"
                        ("id", "name")
                    VALUES
                        (1, 'widget');
                    """#)
            )
        }

        let result =
            try await database.execute(
                query: #"""
                    SELECT "name"
                    FROM "items"
                    WHERE "id" = 1;
                    """#
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "name", as: String.self) == "widget")
    }

    @Test
    func transactionFailurePropagates() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        enum TestError: Error {
            case expected
        }

        do {
            _ = try await database.transaction { _ in
                throw TestError.expected
            }
            Issue.record("Expected transaction error to be thrown.")
        }
        catch TestError.expected {
            #expect(true)
        }
        catch {
            Issue.record("Expected TestError.expected to be thrown.")
        }
    }

    @Test
    func doubleRoundTrip() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "measurements" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "value" REAL NOT NULL
                );
                """#
        )

        let expected = 1.5

        try await database.execute(
            query: #"""
                INSERT INTO "measurements"
                    ("id", "value")
                VALUES
                    (1, \#(expected));
                """#
        )

        let result =
            try await database.execute(
                query: #"""
                    SELECT "value"
                    FROM "measurements"
                    WHERE "id" = 1;
                    """#
            )
            .collect()

        #expect(result.count == 1)
        #expect(try result[0].decode(column: "value", as: Double.self) == expected)
    }

    @Test
    func missingColumnThrows() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "items" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "value" TEXT
                );
                """#
        )

        try await database.execute(
            query: #"""
                INSERT INTO "items"
                    ("id", "value")
                VALUES
                    (1, 'abc');
                """#
        )

        let result =
            try await database.execute(
                query: #"""
                    SELECT "id"
                    FROM "items";
                    """#
            )
            .collect()

        #expect(result.count == 1)

        do {
            _ = try result[0].decode(column: "value", as: String.self)
            Issue.record("Expected decoding a missing column to throw.")
        }
        catch DecodingError.dataCorrupted {
            #expect(true)
        }
        catch {
            Issue.record("Expected a dataCorrupted error for missing column.")
        }
    }

    @Test
    func typeMismatchThrows() async throws {
        let database = try await getTestDatabase()
        defer { Task { try await database.shutdown() } }

        try await database.execute(
            query: #"""
                CREATE TABLE "items" (
                    "id" INTEGER NOT NULL PRIMARY KEY,
                    "value" TEXT
                );
                """#
        )

        try await database.execute(
            query: #"""
                INSERT INTO "items"
                    ("id", "value")
                VALUES
                    (1, 'abc');
                """#
        )

        let result =
            try await database.execute(
                query: #"""
                    SELECT "value"
                    FROM "items";
                    """#
            )
            .collect()

        #expect(result.count == 1)

        do {
            _ = try result[0].decode(column: "value", as: Int.self)
            Issue.record("Expected decoding a string as Int to throw.")
        }
        catch DecodingError.typeMismatch {
            #expect(true)
        }
        catch {
            Issue.record("Expected a typeMismatch error when decoding a string as Int.")
        }
    }

    @Test
    func versionCheck() async throws {
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
