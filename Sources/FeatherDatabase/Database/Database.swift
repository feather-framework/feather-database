//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

@preconcurrency import SQLKit

public struct Database: Sendable {

    public let sqlDatabase: SQLDatabase

    public init(_ sqlDatabase: SQLDatabase) {
        self.sqlDatabase = sqlDatabase
    }

    public func run<T>(
        _ block: ((SQLDatabase) async throws -> T)
    ) async throws -> T {
        do {
            return try await block(sqlDatabase)
        }
        catch {
            throw Database.Error.query(error)
        }
    }
}
