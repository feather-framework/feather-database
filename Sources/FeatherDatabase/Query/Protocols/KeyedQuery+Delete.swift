//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol KeyedDatabaseTableQueryDelete: KeyedDatabaseTableQuery {

    func delete(
        _ value: Key<Row>
    ) async throws
}

extension KeyedDatabaseTableQueryDelete {

    public func delete(
        _ value: Key<Row>
    ) async throws {
        try await db.run { sql in
            try await sql
                .delete(from: Self.name)
                .where(Self.primaryKey.sqlValue, .equal, value)
                .run()
        }
    }
}
