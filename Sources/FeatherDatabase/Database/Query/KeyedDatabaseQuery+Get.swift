//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol KeyedDatabaseQueryGet: KeyedDatabaseQueryInterface {

    static func get(
        _ value: Key<Row>,
        on db: Database
    ) async throws -> Row?
}

extension KeyedDatabaseQueryGet {

    public static func get(
        _ value: Key<Row>,
        on db: Database
    ) async throws -> Row? {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column("*")
                .where(Self.primaryKey.sqlValue, .equal, SQLBind(value))
                .limit(1)
                .offset(0)
                .first(decoding: Row.self)
        }
    }
}
