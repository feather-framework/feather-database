//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryFirst: DatabaseQueryInterface {

    static func first(
        filter: DatabaseFilter<Row.ColumnNames>,
        order: DatabaseOrder<Row.ColumnNames>?,
        on db: Database
    ) async throws -> Row?
}

extension DatabaseQueryFirst {

    public static func first(
        filter: DatabaseFilter<Row.ColumnNames>,
        order: DatabaseOrder<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> Row? {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column(SQLColumn(SQLLiteral.all))
                .applyFilter(filter)
                .applyOrder(order)
                .limit(1)
                .offset(0)
                .first(decoding: Row.self)
        }
    }
}

extension DatabaseQueryFirst where Row: KeyedDatabaseModel {

    public static func get(
        _ value: Row.KeyType,
        on db: Database
    ) async throws -> Row? {
        try await first(
            filter: .init(
                column: .init(rawValue: Row.keyName.rawValue)!,
                operator: .equal,
                value: value
            ),
            on: db
        )
    }
}
