//
//  DatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import Logging
import PostgresNIO
import Testing

@testable import FeatherDatabase
@testable import FeatherDatabaseTesting

@Suite
struct PostgresDatabaseTestSuite {

    @Test
    func connection() async throws {
        let logger = Logger(label: "test")

        let database: any Database = PostgresDatabase(
            client: .init(
                configuration: .init(
                    host: "localhost",
                    username: "postgres",
                    password: "postgres",
                    database: "postgres",
                    tls: .disable
                )
            ),
            logger: logger
        )

        #expect(true)
    }
}
