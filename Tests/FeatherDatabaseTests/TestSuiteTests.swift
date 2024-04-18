//
//  FeatherSQLDatabaseTests.swift
//  FeatherSQLDatabaseTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherDatabaseTesting
import XCTest

final class TestSuiteTests: TestCase {

    func testTestSuite() async throws {

        let db = try await components.database()
        let testSuite = DatabaseTestSuite(db)
        try await testSuite.testAll()
    }
}
