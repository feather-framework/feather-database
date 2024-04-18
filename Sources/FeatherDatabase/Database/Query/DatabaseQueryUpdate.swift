//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//
//
import SQLKit

public protocol DatabaseQueryUpdate: DatabaseQueryInterface {

    //    static func update(
    //        _ value: Key<Row>,
    //        _ row: Row,
    //        on db: Database
    //    ) async throws
}

extension DatabaseQueryUpdate where Row: KeyedDatabaseModel {

    public static func update(
        _ value: Row.KeyType,
        _ row: Row,
        on db: Database
    ) async throws {
        try await db.run { sql in
            try await sql
                .update(Row.tableName)
                .set(model: row)
                .where(Row.keyName.sqlValue, .equal, SQLBind(value))
                .run()
        }
    }
}
