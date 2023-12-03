//
//  SQLDatabaseTestSuite.swift
//  XCTFeatherSQLDatabase
//
//  Created by Tibor Bodecs on 17/11/2023.
//

import Foundation
//import FeatherRelationalDatabase
//
//public struct SQLDatabaseTestSuiteError: Error {
//
//    public let function: String
//    public let line: Int
//    public let error: Error?
//
//    init(
//        function: String = #function,
//        line: Int = #line,
//        error: Error? = nil
//    ) {
//        self.function = function
//        self.line = line
//        self.error = error
//    }
//}
//
//public struct SQLDatabaseTestSuite {
//
//    let sql-database: SQLDatabaseService
//
//    public init(_ sql-database: SQLDatabaseService) {
//        self.sql-database = sql-database
//    }
//
//    public func testAll(
//        from: String,
//        to: String
//    ) async throws {
//        async let tests: [Void] = [
//            testPlainText(from: from, to: to),
//            testHTML(from: from, to: to),
//            testAttachment(from: from, to: to),
//        ]
//        do {
//            _ = try await tests
//        }
//        catch let error as SQLDatabaseTestSuiteError {
//            throw error
//        }
//        catch {
//            throw SQLDatabaseTestSuiteError(error: error)
//        }
//    }
//}
//
//public extension SQLDatabaseTestSuite {
//
//    func getAttachmentUrl() -> URL? {
//        Bundle.module.url(forResource: "feather", withExtension: "png")
//    }
//
//    // MARK: - tests
//
//    func testPlainText(
//        from: String,
//        to: String
//    ) async throws {
//        let esql-database = try SQLDatabase(
//            from: .init(from),
//            to: [
//                .init(to),
//            ],
//            subject: "Test plain text esql-database",
//            body: "This is a plain text esql-database."
//        )
//        try await sql-database.send(esql-database)
//    }
//
//    func testHTML(
//        from: String,
//        to: String
//    ) async throws {
//        let esql-database = try SQLDatabase(
//            from: .init(from),
//            to: [
//                .init(to),
//            ],
//            subject: "Test HTML esql-database",
//            body: "This is a <b>HTML</b> esql-database.",
//            isHtml: true
//        )
//        try await sql-database.send(esql-database)
//    }
//
//    func testAttachment(
//        from: String,
//        to: String
//    ) async throws {
//        
//        guard 
//            let url = getAttachmentUrl(),
//            let data = try? Data(contentsOf: url)
//        else {
//            print("Attachment not found, skipping test case...")
//            return
//        }
//
//        let esql-database = try SQLDatabase(
//            from: .init(from),
//            to: [
//                .init(to),
//            ],
//            subject: "Test esql-database attachment",
//            body: "This is a test esql-database with an attachment.",
//            attachments: [
//                .init(
//                    name: "feather.png",
//                    contentType: "image/png",
//                    data: data
//                )
//            ]
//        )
//        try await sql-database.send(esql-database)
//    }
//}
