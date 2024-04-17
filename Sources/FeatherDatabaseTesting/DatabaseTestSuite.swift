//
//  DatabaseTestSuite.swift
//  FeatherDatabaseTesting
//
//  Created by Tibor Bodecs on 17/11/2023.
//

import XCTest
import FeatherDatabase
import NanoID

/// database test suit error
public struct DatabaseTestSuiteError: Error {

    /// function
    public let function: String
    /// line
    public let line: Int
    /// error
    public let error: Error?

    init(
        function: String = #function,
        line: Int = #line,
        error: Error? = nil
    ) {
        self.function = function
        self.line = line
        self.error = error
    }
}

/// database test suite
public struct DatabaseTestSuite {

    let component: DatabaseComponent

    /// mail test suite init
    public init(_ component: DatabaseComponent) {
        self.component = component
    }

    /// test all mail sending
    public func testAll() async throws {
        do {
            let db = try await component.connection()
            
            async let tests: [Void] = [
                testMigration(db),
                testInsert(db),
                testCount(db),
                testGet(db),
            ]

            _ = try await tests
        }
        catch let error as DatabaseTestSuiteError {
            throw error
        }
        catch {
            throw DatabaseTestSuiteError(error: error)
        }
    }
}

public extension DatabaseTestSuite {

    // MARK: - tests

    func testMigration(_ db: Database) async throws {
        try await Blog.Tag.Table.create(on: db)
        try await Blog.Category.Table.create(on: db)
        try await Blog.Post.Table.create(on: db)
        try await Blog.PostTag.Table.create(on: db)
    }
    
    func testInsert(_ db: Database) async throws {
        let test = Blog.Tag.Model.mock()
        try await Blog.Tag.Query.insert(test, on: db)
    }
    
    func testCount(_ db: Database) async throws {
        let count1 = try await Blog.Tag.Query.count(on: db)
        
        let models: [Blog.Tag.Model] = (1...50).map {
            .mock($0)
        }
        try await Blog.Tag.Query.insert(models, on: db)

        let count2 = try await Blog.Tag.Query.count(on: db)
        XCTAssertEqual(count2, count1 + 50)
        

        let count3 = try await Blog.Tag.Query.count(
            filter: .init(
                column: .name,
                operator: .like,
                value: ["name-1%"]
            ),
            on: db
        )
        XCTAssertEqual(count3, 11)
    }
    
    func testGet(_ db: Database) async throws {

        let test = Blog.Tag.Model(
            id: NanoID.generateKey(),
            name: "foo"
        )
        try await Blog.Tag.Query.insert(test, on: db)
        
        let test1 = try await Blog.Tag.Query.get(
            test.id,
            on: db
        )
        
        XCTAssertEqual(test1?.id, test.id)
        
    }


}
