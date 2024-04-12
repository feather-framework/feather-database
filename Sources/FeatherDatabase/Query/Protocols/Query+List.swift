//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryList: DatabaseQuery {

    static func list(
        _ query: QueryList<Row.ColumnNames>,
        on db: Database
    ) async throws -> QueryList<Row.ColumnNames>.Result<Row>
}

extension DatabaseQueryList {

    public static func list(
        _ query: QueryList<Row.ColumnNames>,
        on db: Database
    ) async throws -> QueryList<Row.ColumnNames>.Result<Row> {
        try await db.run { sql in
            let total =
                try await sql
                .select()
                .from(Row.tableName)
                .column(SQLFunction("COUNT"), as: "count")
                .applyFilter(query.filter)
                .applyOrders(query.orders)
                .first(decoding: RowCount.self)?
                .count ?? 0

            let items =
                try await sql
                .select()
                .from(Row.tableName)
                .column("*")
                .applyFilter(query.filter)
                .applyOrders(query.orders)
                .applyPage(query.page)
                .all(decoding: Row.self)

            return .init(items: items, total: total)
        }
    }
}
