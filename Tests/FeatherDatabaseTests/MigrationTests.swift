//
//  FeatherSQLDatabaseTests.swift
//  FeatherSQLDatabaseTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherDatabaseTesting
import XCTest

final class MigrationTests: TestCase {

    func testExample() async throws {
        let db = try await components.database().connection()

        try await Test.Table.create(on: db)

        try await Blog.Tag.Table.create(on: db)
        try await Blog.Category.Table.create(on: db)
        try await Blog.Post.Table.create(on: db)
        try await Blog.PostTag.Table.create(on: db)
    }
}
