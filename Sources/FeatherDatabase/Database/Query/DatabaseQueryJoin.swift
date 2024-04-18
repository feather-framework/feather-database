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
        join: DatabaseJoin<T.ColumnNames, Row.ColumnNames>,
        orders: [DatabaseOrder<T.ColumnNames>],
        filter: DatabaseFilter<T.ColumnNames>?,
        on db: Database
    ) async throws -> [T]
}

extension DatabaseQueryJoin {

    public static func join<T: DatabaseModel>(
        _ res: T.Type,
        join: DatabaseJoin<T.ColumnNames, Row.ColumnNames>,
        orders: [DatabaseOrder<T.ColumnNames>] = [],
        filter: DatabaseFilter<T.ColumnNames>? = nil,
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
                    method: join.method,
                    on: SQLColumn(join.column.rawValue, table: T.tableName),
                    join.op,
                    SQLColumn(join.otherColumn.rawValue, table: Row.tableName)
                )
                .applyFilter(join.filter)
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: T.self)
        }
    }
}
