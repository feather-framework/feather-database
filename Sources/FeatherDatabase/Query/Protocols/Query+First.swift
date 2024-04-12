//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryFirst: DatabaseQuery {

    static func first(
        filter: QueryFieldFilter<Row.ColumnNames>,
        order: QueryOrder<Row.ColumnNames>?,
        on db: Database
    ) async throws -> Row?
}

extension DatabaseQueryFirst {

    public static func first(
        filter: QueryFieldFilter<Row.ColumnNames>,
        order: QueryOrder<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> Row? {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column("*")
                .applyFilter(filter)
                .applyOrder(order)
                .limit(1)
                .offset(0)
                .first(decoding: Row.self)
        }
    }
}
