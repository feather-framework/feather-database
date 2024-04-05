//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseTableQueryList: DatabaseTableQuery {

    func list(
        _ query: QueryList<Row.FieldKeys>
    ) async throws -> QueryList<Row.FieldKeys>.Result<Row>
}

extension DatabaseTableQueryList {

    public func list(
        _ query: QueryList<Row.FieldKeys>
    ) async throws -> QueryList<Row.FieldKeys>.Result<Row> {
        try await db.run { sql in
            let total =
                try await sql
                .select()
                .from(Self.name)
                .column(SQLFunction("COUNT"), as: "count")
                .applyFilter(query.filter)
                .applyOrders(query.orders)
                .first(decoding: RowCount.self)?
                .count ?? 0

            let items =
                try await sql
                .select()
                .from(Self.name)
                .column("*")
                .applyFilter(query.filter)
                .applyOrders(query.orders)
                .applyPage(query.page)
                .all(decoding: Row.self)

            return .init(items: items, total: total)
        }
    }
}
