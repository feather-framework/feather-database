//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

/// The Database protocol.
public protocol Database: Sendable {

    associatedtype Query: DatabaseQuery
    associatedtype Result: DatabaseResult

    //    var dialect: String { get }

    func connection(
        _:
            nonisolated(nonsending)(DatabaseConnection) async throws ->
            sending Result,
    ) async throws -> sending Result

    func transaction(
        _:
            nonisolated(nonsending)(DatabaseConnection) async throws ->
            sending Result,
    ) async throws -> sending Result

    func run(
        query: Query,
    ) async throws -> Result

    func shutdown() async throws
}

extension Database {

    public func run(
        query: Query,
    ) async throws -> Result {
        try await connection { connection in
            try await connection.run(query: query)
        }
    }
}

//import SQLKit
//
//public struct Database: Sendable {
//
//    public let sqlDatabase: SQLDatabase
//
//    public init(_ sqlDatabase: SQLDatabase) {
//        self.sqlDatabase = sqlDatabase
//    }
//
//    public func run<T>(
//        _ block: ((SQLDatabase) async throws -> T)
//    ) async throws -> T {
//        do {
//            return try await block(sqlDatabase)
//        }
//        catch {
//            throw Database.Error.query(error)
//        }
//    }
//}
