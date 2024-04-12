//
//  FeatherSQLDatabaseTests.swift
//  FeatherSQLDatabaseTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherComponent
import NIO
import SQLKit
import XCTest

final class MigrationTests: TestCase {

    func testExample() async throws {
        let db = try await components.database().connection()

        try await Test.Table.create(on: db)
    }
}
