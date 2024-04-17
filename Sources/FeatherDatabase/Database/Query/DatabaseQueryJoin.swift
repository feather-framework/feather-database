//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

import SQLKit

public protocol DatabaseQueryJoin: DatabaseQueryInterface {
    static func join<T: DatabaseModel>(
        _ res: T.Type,
        join: (lhs: T.ColumnNames, rhs: Row.ColumnNames),
        orders: [DatabaseOrder<T.ColumnNames>],
        filter: DatabaseFilter<T.ColumnNames>?,
        filterJoin: DatabaseFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> [T]
}

extension DatabaseQueryJoin {

    public static func join<T: DatabaseModel>(
        _ res: T.Type,
        join: (lhs: T.ColumnNames, rhs: Row.ColumnNames),
        orders: [DatabaseOrder<T.ColumnNames>] = [],
        filter: DatabaseFilter<T.ColumnNames>? = nil,
        filterJoin: DatabaseFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> [T] {
        try await db.run { sql in
            try await sql
                .select()
                .column(
                    SQLColumn(
                        SQLLiteral.all,
                        table: SQLIdentifier(T.tableName)
                    )
                )
                .from(Row.tableName)
                .join(
                    T.tableName,
                    method: SQLJoinMethod.inner,
                    on: SQLColumn(join.lhs.rawValue),
                    .equal,
                    SQLColumn(join.rhs.rawValue)
                )
                .applyFilter(filterJoin)
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: T.self)
        }
    }
}
