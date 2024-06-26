//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryDelete: DatabaseQueryInterface {

    static func delete(
        filter: DatabaseFilter<Row.ColumnNames>,
        on db: Database
    ) async throws

    static func delete(
        filter: DatabaseTableFilter<Row.ColumnNames>,
        on db: Database
    ) async throws
}

extension DatabaseQueryDelete {

    public static func delete(
        filter: DatabaseFilter<Row.ColumnNames>,
        on db: Database
    ) async throws {
        try await delete(
            filter: .init(groups: [.init(columns: [filter])]),
            on: db
        )
    }

    public static func delete(
        filter: DatabaseTableFilter<Row.ColumnNames>,
        on db: Database
    ) async throws {
        try await db.run { sql in
            try await sql
                .delete(from: Row.tableName)
                .applyFilter(filter)
                .run()
        }
    }
}

extension DatabaseQueryDelete where Row: KeyedDatabaseModel {

    public static func delete(
        _ value: Row.KeyType,
        on db: Database
    ) async throws {
        try await delete(
            filter: .init(
                column: Row.keyName,
                operator: .equal,
                value: value
            ),
            on: db
        )
    }
}
