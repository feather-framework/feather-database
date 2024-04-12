//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryAll: DatabaseQuery {

    static func all(
        orders: [QueryOrder<Row.ColumnNames>],
        filter: QueryFieldFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> [Row]
}

extension DatabaseQueryAll {

    public static func all(
        orders: [QueryOrder<Row.ColumnNames>] = [],
        filter: QueryFieldFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> [Row] {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column("*")
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: Row.self)
        }
    }
}
