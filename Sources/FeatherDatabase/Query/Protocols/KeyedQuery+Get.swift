//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol KeyedDatabaseTableQueryGet: KeyedDatabaseTableQuery {

    func get(_ value: Key<Row>) async throws -> Row?
}

extension KeyedDatabaseTableQueryGet {

    public func get(_ value: Key<Row>) async throws -> Row? {
        try await db.run { sql in
            try await sql
                .select()
                .from(Self.name)
                .column("*")
                .where(Self.primaryKey.sqlValue, .equal, SQLBind(value))
                .limit(1)
                .offset(0)
                .first(decoding: Row.self)
        }
    }
}
