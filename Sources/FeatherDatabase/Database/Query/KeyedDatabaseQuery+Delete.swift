//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol KeyedDatabaseQueryDelete: KeyedDatabaseQueryInterface {

    static func delete(
        _ value: Key<Row>,
        on db: Database
    ) async throws
}

extension KeyedDatabaseQueryDelete {

    public static func delete(
        _ value: Key<Row>,
        on db: Database
    ) async throws {
        try await db.run { sql in
            try await sql
                .delete(from: Row.tableName)
                .where(Self.primaryKey.sqlValue, .equal, value)
                .run()
        }
    }
}
