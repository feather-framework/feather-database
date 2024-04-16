//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

import SQLKit

public protocol DatabaseQueryJoin: DatabaseQueryInterface {
    static func join<T: DatabaseModel>(
        _ of: T.Type,
        _ valueField: T.ColumnNames,
        _ connectorField: Row.ColumnNames,
        orders: [DatabaseOrder<Row.ColumnNames>],
        filter: DatabaseFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> [T]
}

extension DatabaseQueryJoin {

    public static func join<T: DatabaseModel>(
        _ of: T.Type,
        _ valueField: T.ColumnNames,
        _ connectorField: Row.ColumnNames,
        orders: [DatabaseOrder<Row.ColumnNames>] = [],
        filter: DatabaseFilter<Row.ColumnNames>? = nil,
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
                    on: SQLColumn(valueField.rawValue),
                    .equal,
                    SQLColumn(connectorField.rawValue)
                )
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: T.self)
        }
    }
}
