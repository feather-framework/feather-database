//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseTableQueryAll: DatabaseTableQuery {

    func all(
        orders: [QueryOrder<Row.FieldKeys>],
        filter: QueryFieldFilter<Row.FieldKeys>?
    ) async throws -> [Row]
}

extension DatabaseTableQueryAll {

    public func all(
        orders: [QueryOrder<Row.FieldKeys>] = [],
        filter: QueryFieldFilter<Row.FieldKeys>? = nil
    ) async throws -> [Row] {
        try await db.run { sql in
            try await sql
                .select()
                .from(Self.name)
                .column("*")
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: Row.self)
        }
    }
}
