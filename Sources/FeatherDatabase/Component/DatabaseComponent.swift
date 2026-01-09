//
//  Database.swift
//  feather-database
//
//  Created by Tibor Bodecs on 18/11/2023.
//

/// The Database protocol.
//public protocol Database: Sendable {
//
//    @discardableResult
//    func connection<Result: Sendable>(
//        _ closure: (PostgresConnection) async throws -> sending Result,
//        isolation: isolated (any Actor)? = #isolation
//    ) async throws
//
//    @discardableResult
//    func transaction<Result: Sendable>(
//        _ closure: (PostgresConnection) async throws -> sending Result,
//        isolation: isolated (any Actor)? = #isolation
//    ) async throws
//
//    @discardableResult
//    func run(
//        query: PostgresQuery,
//        on connection: PostgresConnection,
//        file: String = #fileID,
//        line: Int = #line
//    ) async throws
//
//    @discardableResult
//    func run(
//        query: PostgresQuery
//    ) async throws
//}
