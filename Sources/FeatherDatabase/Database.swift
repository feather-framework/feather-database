//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

/// The Database protocol.
public protocol Database: Sendable {
    associatedtype Result: DatabaseResult

    @discardableResult
    func connection(
        _: nonisolated(nonsending) (DatabaseConnection) async throws -> sending Result,
    ) async throws -> sending Result

    @discardableResult
    func transaction(
        _: nonisolated(nonsending) (DatabaseConnection) async throws -> sending Result,
    ) async throws -> sending Result
    
    @discardableResult
    func run(
        query: DatabaseQuery,
        on connection: DatabaseConnection
    ) async throws -> Result
    
    func shutdown() async throws
}

extension Database {

    public func run(
        query: any DatabaseQuery,
        on connection: any DatabaseConnection
    ) async throws -> Result {
        try await connection.run(query: query)
    }
    
    public func run(
        query: any DatabaseQuery
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
