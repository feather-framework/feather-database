//
//  DatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import Testing
import Logging

import SQLiteNIO
@testable import FeatherDatabase
@testable import FeatherDatabaseTesting

extension String: DatabaseQuery {
    public var sql: String { self }
}

@Suite
struct SQLiteDatabaseTestSuite {

    @Test
    func example() async throws {
        let logger = Logger(label: "test")
        
        let connection = try await SQLiteConnection.open(
            storage: .memory,
            logger: logger
        )
        
        let database = SQLiteDatabase(
            connection: connection,
            logger: logger
        )

        let query = "SELECT sqlite_version() AS version;"
        
        do {

            
            let result = try await database.run(query: query)
            let elements = try await result.collect()
            for item in elements {
                print(try item.decode(column: "version", as: String.self))
            }
            for try await item in result {
                let version = try item.decode(column: "version", as: String.self)
                
                print(version)
            }
            print(type(of: result))
            print(result)
        }
        catch {
            print(error)
        }

        try await connection.close()
    }
}
