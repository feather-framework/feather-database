//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

import SQLKit

public protocol KeyedDatabaseTableQueryUpdate: KeyedDatabaseTableQuery {

    func update(_ value: Key<Row>, _ row: Row) async throws
}

extension KeyedDatabaseTableQueryUpdate {

    public func update(_ value: Key<Row>, _ row: Row) async throws {
        try await db.run { sql in
            try await sql
                .update(Self.name)
                .set(model: row)
                .where(Self.primaryKey.sqlValue, .equal, SQLBind(value))
                .run()
        }
    }
}
