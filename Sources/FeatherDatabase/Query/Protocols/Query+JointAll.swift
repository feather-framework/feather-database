//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

import SQLKit

public protocol DatabaseQueryJointAll: DatabaseQuery {

    associatedtype ReferenceModel: DatabaseModel
    associatedtype ConnectorModel: DatabaseModel

    static var referenceField: ReferenceModel.ColumnNames { get }
    static var connectorField: ConnectorModel.ColumnNames { get }
    static var valueField: Row.ColumnNames { get }

    static func all(
        referenceId: Key<ReferenceModel>,
        orders: [QueryOrder<Row.ColumnNames>],
        filter: QueryFieldFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> [Row]
}

extension DatabaseQueryJointAll {

    public static func all(
        referenceId: Key<ReferenceModel>,
        orders: [QueryOrder<Row.ColumnNames>] = [],
        filter: QueryFieldFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> [Row] {
        try await db.run { sql in
            try await sql
                .select()
                .column(table: Row.tableName, column: "*")
                .from(ConnectorModel.tableName)
                .join(
                    Row.tableName,
                    method: SQLJoinMethod.inner,
                    on: SQLColumn(valueField.rawValue),
                    .equal,
                    SQLColumn(connectorField.rawValue)
                )
                .where(referenceField.rawValue, .equal, SQLBind(referenceId))
                .applyFilter(filter)
                .applyOrders(orders)
                .all(decoding: Row.self)
        }
    }
}
