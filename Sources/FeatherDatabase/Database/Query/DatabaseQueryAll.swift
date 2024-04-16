//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryAll: DatabaseQueryInterface {

    static func all(
        orders: [DatabaseOrder<Row.ColumnNames>],
        filter: DatabaseFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> [Row]
}

extension DatabaseQueryAll {

    public static func all(
        orders: [DatabaseOrder<Row.ColumnNames>] = [],
        filter: DatabaseFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> [Row] {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column(SQLColumn(SQLLiteral.all))
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: Row.self)
        }
    }
}
